// --------------- BF_1 ---------------
module butter_fly_1 (
input logic [31:0] a,
input logic [31:0] b,
output logic [31:0] sum,
output logic [31:0] sub
);
full_adder_32bit fa2(
.a (a),
.b (b),
.c_in (1'b0),
.sum (sum),
.c_out ()
);
sub_32bit sub1(
.a (a),
.b (b),
.sum (sub),
.c_out ()
);
endmodule