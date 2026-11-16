// The signal generator core: a phase accumulator steps through a wave, and a register you set
// over the UART sets the frequency (register 0) and the amplitude (register 1).
`default_nettype none

module siggen_core #(
    parameter CPB     = 217,   // clocks per UART bit: 25 MHz / 115200
    parameter TICKDIV = 32,     // clocks per sample
    parameter COLDIV  = 62500  // samples per text column: 62500 / 781250 Hz = 80 ms
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,        // UART receive pin
    input  wire [1:0] sel,       // 0 sine, 1 saw, 2 triangle, 3 square
    input  wire       spec,      // 1 = scroll the text, 0 = signal generator
    output wire       pwm,       // PWM output
    output wire       sd,        // sigma delta output
    output wire [7:0] level      // the sample, for the screen
);
    // 1. commands from the PC: two bytes, an address and then a value
    wire       rx_valid;
    wire [7:0] rx_data;
    ip_uart_rx #(.CPB(CPB)) uart (.clk(clk), .rst_n(rst_n), .rx(rx), .valid(rx_valid), .data(rx_data));

    wire [7:0] step_reg, amp_reg, reg2, reg3;
    ip_regbus #(.INIT0(8'd42), .INIT1(8'hFF), .INIT3(8'd1)) bus (.clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), .rx_data(rx_data), .reg0(step_reg), .reg1(amp_reg), .reg2(reg2), .reg3(reg3));

    // 2. a sample every TICKDIV clocks, and the phase moves on by step_reg each time
    wire tick;
    ip_tick #(.DIV(TICKDIV)) sample_tick (.clk(clk), .rst_n(rst_n), .en(1'b1), .tick(tick));

    wire [15:0] phase;
    ip_phase_acc #(.W(16)) acc (.clk(clk), .rst_n(rst_n), .en(tick), .step({8'd0, step_reg}), .phase(phase));

    // 3. four wave shapes from the same phase
    wire [7:0] sine;
    ip_rom_sine rom (.addr(phase[15:12]), .data(sine));

    // SPECTROGRAM: switch on ui_in[2], synchronised to the clock
    reg spec_s1, spec_mode;
    always @(posedge clk) begin
        spec_s1   <= spec;
        spec_mode <= spec_s1;
    end

    // which column of the message is playing: move on one column every COLDIV samples
    wire col_tick;
    ip_tick #(.DIV(COLDIV)) column_tick (.clk(clk), .rst_n(rst_n), .en(tick), .tick(col_tick));

    reg [5:0] col;
    always @(posedge clk) begin
        if (!rst_n)        col <= 6'd0;
        else if (col_tick) col <= (col == 6'd47) ? 6'd0 : col + 6'd1;
    end

    wire [6:0] pixels;
    ip_font_rom font (.col(col), .pixels(pixels));

    // seven square waves at 8 to 14 times the base frequency, all from the one phase
    wire [7:0] p   = phase[15:8];
    wire [7:0] m8  = p * 4'd8;
    wire [7:0] m9  = p * 4'd9;
    wire [7:0] m10 = p * 4'd10;
    wire [7:0] m11 = p * 4'd11;
    wire [7:0] m12 = p * 4'd12;
    wire [7:0] m13 = p * 4'd13;
    wire [7:0] m14 = p * 4'd14;
    wire [6:0] tones = {m8[7], m9[7], m10[7], m11[7], m12[7], m13[7], m14[7]};  // bit 0 = highest

    // add up the tones whose pixel is lit: 0 to 7
    wire [6:0] lit   = tones & pixels;
    wire [2:0] count = {2'b00, lit[0]} + {2'b00, lit[1]} + {2'b00, lit[2]} + {2'b00, lit[3]}
                     + {2'b00, lit[4]} + {2'b00, lit[5]} + {2'b00, lit[6]};
    reg [7:0] wave;
    always @(*) begin
        if (spec_mode) wave={count,5'b00000};
        else case (sel)
            2'b00: wave = sine;
            2'b01: wave = phase[15:8];
            2'b10: wave = phase[15] ? ~phase[14:7] : phase[14:7];
            2'b11: wave = phase[15] ? 8'd255 : 0;
            default: wave = 8'd0;
        endcase
    end

    // 4. amplitude, then the two outputs
    wire [7:0] scaled;
    ip_fixed_mul amplitude (.a(wave),.b(amp_reg),.y(scaled));
    // TODO 8: ip_pwm and ip_sigma_delta, both fed from scaled.
    ip_pwm pwm_out (.clk(clk), .rst_n(rst_n), .duty(scaled), .out(pwm));
    ip_sigma_delta sd_out (.clk(clk), .rst_n(rst_n), .in(scaled), .out(sd));
    assign level = scaled;

    wire _unused = &{reg2, reg3, rx_valid, rx_data, tick, phase, sine, scaled, step_reg, amp_reg, sel, 1'b0};
endmodule
