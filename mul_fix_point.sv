module mul_fix_point (
	input logic [31:0] a,
	input logic [31:0] b,
	output logic [63:0] out
);
	logic [63:0] acc;
	logic [63:0] partial [31:0];
	genvar i;
	generate
		for (i = 0; i < 32; i++) begin : GEN_PARTIAL
		assign partial[i] = b[i] ? ({{32{1'b0}}, a} << i) : 64'd0;
		end
	endgenerate
	// cộng dồn (combinational)
	integer k;
	always_comb begin
	acc = 64'd0;
		for (k = 0; k < 32; k++) begin
		acc = acc + partial[k];
		end
	end
	assign out = acc;
endmodule