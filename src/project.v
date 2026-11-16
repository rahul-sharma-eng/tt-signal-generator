// The Tiny Tapeout top module for the signal generator track (the shell). It is given and you do not edit it.
//
//   ui_in[1:0]  picks the wave: 0 sine, 1 saw, 2 triangle, 3 square (keys 0 and 1 in the VGA view)
//   ui_in[7]    the UART receive pin. It idles HIGH, so hold it high (key 7 in the VGA view)
//   uio[0]      the PWM output: the sound you listen to
//   uio[1]      the sigma delta output: the same wave, made a different way
//   the screen  a picture of the wave you picked, from ui_in[1:0] only. It does not show the data.
//
// To try it: hold ui_in[7] high, change ui_in[1:0], and listen to uio[0].
`default_nettype none

module tt_um_rahul_sharma_eng_signal_generator (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // bidirectional pins, input path
    output wire [7:0] uio_out,  // bidirectional pins, output path
    output wire [7:0] uio_oe,   // bidirectional pins, 1 = drive
    input  wire       ena,      // high when the design is powered, ignore
    input  wire       clk,      // clock
    input  wire       rst_n     // reset, active low
);
    wire        hsync, vsync, active, frame;
    wire [9:0]  x, y;
    wire [5:0]  rgb;
    wire [7:0]  level;
    wire        pwm, sd;

    vga_sync vga (.clk(clk), .rst_n(rst_n), .hsync(hsync), .vsync(vsync), .active(active), .x(x), .y(y), .frame(frame));

    siggen_core core (
        .clk(clk), .rst_n(rst_n),
        .rx(ui_in[7]), .sel(ui_in[1:0]), .spec(ui_in[2]),
        .pwm(pwm), .sd(sd), .level(level)
    );

    // The screen draws the wave that ui_in[1:0] picks, as a picture of the choice. It does not
    // use the level, so the picture is the same whatever frequency or amplitude is set.
    vga_wave_shape shape (.x(x), .y(y), .active(active), .sel(ui_in[1:0]), .rgb(rgb));

    // TinyVGA PMOD pin order: {hsync, B0, G0, R0, vsync, B1, G1, R1}
    assign uo_out = {hsync, rgb[0], rgb[2], rgb[4], vsync, rgb[1], rgb[3], rgb[5]};
    assign uio_out = {6'd0, sd, pwm};
    assign uio_oe  = 8'b0000_0011;

    wire _unused = &{ena, uio_in, ui_in[6:3], frame, level, 1'b0};
endmodule
