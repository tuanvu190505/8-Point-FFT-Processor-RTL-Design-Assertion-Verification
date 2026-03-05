// --------------------- complex multiplier 1 ------------------
module cm1 (
	input logic [31:0] a,
	input logic [31:0] b,
	output logic [31:0] re,
	output logic [31:0] im
);
	logic [31:0] tmp1;
	full_adder_32bit fa1(
	.a (a),
	.b (b),
	.c_in (1'b0),
	.sum (tmp1),
	.c_out ()
	);
	logic [63:0] tmp2,tmp3;
	// 1/sqrt(2) = 0.7071 (Q0.32)
	localparam logic signed [31:0] W = 32'hB504F333;
	mul_fix_point mul1(
	.a (tmp1),
	.b (W),
	.out (tmp2)
	);
	mul_fix_point mul2(
	.a (tmp1),
	.b (W),
	.out (tmp3)
	);
	assign re = tmp2 [47:16];
	assign im = tmp3 [47:16];
endmodule