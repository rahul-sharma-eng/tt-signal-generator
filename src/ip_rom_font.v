// The message, one 7-pixel column at a time. Bit 0 is the top row of the letter.
`default_nettype none

module ip_font_rom (
    input  wire [5:0] col,
    output reg  [6:0] pixels
);
    always @(*) begin
        case (col)
            // U
            6'd0:  pixels = 7'h3F;  6'd1:  pixels = 7'h40;  6'd2:  pixels = 7'h40;
            6'd3:  pixels = 7'h40;  6'd4:  pixels = 7'h3F;
            // N
            6'd6:  pixels = 7'h7F;  6'd7:  pixels = 7'h04;  6'd8:  pixels = 7'h08;
            6'd9:  pixels = 7'h10;  6'd10: pixels = 7'h7F;
            // I
            6'd13: pixels = 7'h41;  6'd14: pixels = 7'h7F;  6'd15: pixels = 7'h41;
            // C
            6'd18: pixels = 7'h3E;  6'd19: pixels = 7'h41;  6'd20: pixels = 7'h41;
            6'd21: pixels = 7'h41;  6'd22: pixels = 7'h22;
            // H
            6'd24: pixels = 7'h7F;  6'd25: pixels = 7'h08;  6'd26: pixels = 7'h08;
            6'd27: pixels = 7'h08;  6'd28: pixels = 7'h7F;
            // I
            6'd31: pixels = 7'h41;  6'd32: pixels = 7'h7F;  6'd33: pixels = 7'h41;
            // P
            6'd36: pixels = 7'h7F;  6'd37: pixels = 7'h09;  6'd38: pixels = 7'h09;
            6'd39: pixels = 7'h09;  6'd40: pixels = 7'h06;
            default: pixels = 7'h00;    // gaps, and blank columns 41-47 before it repeats
        endcase
    end
endmodule
