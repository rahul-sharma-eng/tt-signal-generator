// A UART receiver: 8 data bits, no parity, 1 stop bit, least significant bit first.
// CPB is the number of clock cycles in one bit (clock / baud rate, 25 MHz / 115200 is about 217).
`default_nettype none

module ip_uart_rx #(
    parameter CPB = 217
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg        valid,
    output reg  [7:0] data
);
    localparam IDLE = 2'd0, START = 2'd1, BITS = 2'd2, STOP = 2'd3;

    reg [1:0]  state;
    reg [15:0] count;
    reg [2:0]  bit_index;
    reg        rx1, rx2;

    always @(posedge clk) begin
        rx1   <= rx;
        rx2   <= rx1;
        valid <= 1'b0;
        if (!rst_n) begin
            state     <= IDLE;
            count     <= 16'd0;
            bit_index <= 3'd0;
            data      <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (!rx2) begin
                        count <= 16'd0;
                        state <= START;
                    end
                end
                START: begin
                    if (count == CPB / 2 - 1) begin
                        count <= 16'd0;
                        if (!rx2) begin
                            bit_index <= 3'd0;
                            state     <= BITS;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        count <= count + 16'd1;
                    end
                end
                BITS: begin
                    if (count == CPB - 1) begin
                        count <= 16'd0;
                        data[bit_index] <= rx2;
                        if (bit_index == 3'd7) state <= STOP;
                        else                   bit_index <= bit_index + 3'd1;
                    end else begin
                        count <= count + 16'd1;
                    end
                end
                STOP: begin
                    if (count == CPB - 1) begin
                        count <= 16'd0;
                        valid <= 1'b1;
                        state <= IDLE;
                    end else begin
                        count <= count + 16'd1;
                    end
                end
            endcase
        end
    end
endmodule
