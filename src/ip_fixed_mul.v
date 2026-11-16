// Fixed point multiply. a and b are fractions from 0 to 255/256: the value is the number divided by 256.
// The answer is the same kind of fraction, so a * b is divided by 256 again by dropping the low 8 bits.
`default_nettype none

module ip_fixed_mul (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire [7:0] y
);
    wire [15:0] mid;

    assign mid = (a*b);
    assign y = mid[15:8];
endmodule
