// --------------------- BF2 ------------------
module butter_fly_2 (
input logic [31:0] r,
input logic [31:0] i,
output logic [31:0] r1,
output logic [31:0] r2,
output logic [31:0] i1,
output logic [31:0] i2 // i2 = -i1;
);
assign r1 = r;
assign r2 = r;
assign i1 = i;
sub_32bit u1 (
.a (32'd0),
.b (i),
.sum (i2),
.c_out ()
);
endmodule