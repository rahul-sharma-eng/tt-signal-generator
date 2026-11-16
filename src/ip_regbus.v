// A register bus: every command is two bytes from the UART, an address and then a value.
// Writing address 0 to 3 stores the value in reg0 to reg3.
`default_nettype none

module ip_regbus #(
    parameter [7:0] INIT0 = 8'd0,
    parameter [7:0] INIT1 = 8'd0,
    parameter [7:0] INIT2 = 8'd0,
    parameter [7:0] INIT3 = 8'd0
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx_valid,
    input  wire [7:0] rx_data,
    output reg  [7:0] reg0,
    output reg  [7:0] reg1,
    output reg  [7:0] reg2,
    output reg  [7:0] reg3
);
    reg       have_addr;
    reg [1:0] addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            have_addr <= 1'b0;
            addr      <= 2'd0;
            reg0      <= INIT0;
            reg1      <= INIT1;
            reg2      <= INIT2;
            reg3      <= INIT3;
        end else if (rx_valid) begin
            if (have_addr==1'b0) begin
                addr[1:0] <= rx_data[1:0];
                have_addr <= 1'b1;
            end else begin
                have_addr <= 1'b0;
                case (addr)
                    2'b00: reg0<=rx_data;
                    2'b01: reg1<=rx_data;
                    2'b10: reg2<=rx_data;
                    2'b11: reg3<=rx_data;
                endcase
            end
        end
    end
endmodule
