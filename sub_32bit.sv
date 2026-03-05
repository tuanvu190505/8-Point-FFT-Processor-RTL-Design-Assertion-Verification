// --------------- sub 32 bit ---------------
module sub_32bit (
input logic [31:0] a,
input logic [31:0] b,
output logic [31:0] sum,
output logic c_out
);
logic [31:0] b_1;
assign b_1 = ~b;
full_adder_32bit fa1(
.a (a),
.b (b_1),
.c_in (1'b1),
.sum (sum),
.c_out (c_out)
);
endmodule