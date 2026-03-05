// ------------------ delay -----------------
module delay (
	input logic clk,
	input logic rst_n, // reset active LOW
	input logic signed [31:0] din,
	output logic signed [31:0] dout
);
// có 8 biến nên delay 9 clk để tính đúng kết quả
	logic signed [31:0] pipe [0:8];
	integer i;
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for (i = 0; i < 9; i++)
			pipe[i] <= '0;
		end else begin
			pipe[0] <= din;
			for (i = 1; i < 9; i++)
			pipe[i] <= pipe[i-1];
			end
	end
	assign dout = pipe[8];
endmodule