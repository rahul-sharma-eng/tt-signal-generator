// A tick generator: one pulse every DIV enabled clock cycles.
`default_nettype none

module ip_tick #(
    parameter DIV = 4
) (
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output wire tick
);
    reg [19:0] count;

    assign tick = en&(count==DIV-1);

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 20'd0;
        end else if (en) begin
            if (count==DIV-1)
                count <= 0;
            else
                count <= count+1;
        end
    end
endmodule
