// ------------------ 8_point_fft -----------------
module fft (
	input logic clk,
	input logic rst_n,
	input logic [31:0] x0,x1,x2,x3,x4,x5,x6,x7,
	output logic [31:0] re0,re1,re2,re3,re4,re5,re6,re7,
	output logic [31:0] im0,im1,im2,im3,im4,im5,im6,im7
);
logic [31:0] a0,a4;
butter_fly_1 bf1_1 (
.a(x0),
.b(x4),
.sum(a0),
.sub(a4)
);
logic [31:0] a2,a6;
butter_fly_1 bf1_2 (
.a(x2),
.b(x6),
.sum(a2),
.sub(a6)
);
logic [31:0] a1,a5;
butter_fly_1 bf1_3 (
.a(x1),
.b(x5),
.sum(a1),
.sub(a5)
);
logic [31:0] a3,a7;
butter_fly_1 bf1_4 (
.a(x3),
.b(x7),
.sum(a3),
.sub(a7)
);
// tầng 2
logic [31:0] b0,b2;
butter_fly_1 bf1_5 (
.a(a0),
.b(a2),
.sum(b0),
.sub(b2)
);
logic [31:0] b4,b6;
butter_fly_1 bf1_10 (
.a(a4),
.b(a6),
.sum(b4),
.sub(b6) // phần ảo chưa nhân -1
);
logic [31:0] b1,b3;
butter_fly_1 bf1_6 (
.a(a1),
.b(a3),
.sum(b1),
.sub(b3)
);
logic [31:0] b5,b7;
butter_fly_1 bf1_7 (
.a(a5),
.b(a7),
.sum(b5),
.sub(b7) // phần ảo chua nhân -1
);
logic [31:0] re_b5,im_b5;
cm1 cm1(
.a (b5),
.b (32'd0),
.re (re_b5),
.im (im_b5) // giữ nguyên: phần ảo của X1, nhân -1: phần ảo của x5
);
logic [31:0] re_b7,im_b7;
cm2 cm2(
.a (b7),
.b (32'd0),
.re (re_b7), // giữ nguyên: phần thực của x7, nhân -1: phần thực của x3
.im (im_b7)
);
// tầng 3: delay
logic [31:0] tmp0,tmp2;
delay d1 (
.clk (clk),
.rst_n (rst_n),
.din (b0),
.dout (tmp0)
);
delay d2 (
.clk (clk),
.rst_n (rst_n),
.din (b2),
.dout (tmp2)
);
logic [31:0] tmp4,tmp6;
delay d3 (
.clk (clk),
.rst_n (rst_n),
.din (b4),
.dout (tmp4)
);
delay d4 (
.clk (clk),
.rst_n (rst_n),
.din (b6),
.dout (tmp6)
);
logic [31:0] tmp1,tmp3;
delay d5 (
.clk (clk),
.rst_n (rst_n),
.din (b1),
.dout (tmp1)
);
delay d6 (
.clk (clk),
.rst_n (rst_n),
.din (b3),
.dout (tmp3)
);
logic [31:0] tmp5,tmp7;
delay d7 (
.clk (clk),
.rst_n (rst_n),
.din (re_b5),
.dout (tmp5)
);
delay d8 (
.clk (clk),
.rst_n (rst_n),
.din (im_b7),
.dout (tmp7)
);
logic [31:0] tmp7_re,tmp5_im;
delay d9 (
.clk (clk),
.rst_n (rst_n),
.din (re_b7),
.dout (tmp7_re)
);
delay d10 (
.clk (clk),
.rst_n (rst_n),
.din (im_b5),
.dout (tmp5_im)
);
// tầng 4: kết quả
logic [31:0] rs0,rs4;
butter_fly_1 bf1_8 (
.a(tmp0),
.b(tmp1),
.sum(rs0),
.sub(rs4)
);
logic [31:0] rs1,rs5;
butter_fly_1 bf1_9 (
.a(tmp4),
.b(tmp5),
.sum(rs1),
.sub(rs5)
);
logic [31:0] rs2,rs6;
butter_fly_1 bf1_11 (
.a(tmp2),
.b(tmp3),
.sum(rs2),
.sub(rs6) // kết quả này là phần ảo của x6
);
logic [31:0] rs3,rs7;
butter_fly_1 bf1_9_1 (
.a(tmp7),
.b(tmp6),
.sum(rs7), // phần ảo của x3
.sub(rs3) // phần ảo của x7
);
// phần thực:
assign re0 = rs0;
assign re1 = rs1;
assign re2 = rs2;
assign re3 = -1*tmp7_re;
assign re4 = rs4;
assign re5 = rs5;
assign re6 = 32'd0; // chỉ có phần ảo
assign re7 = tmp7_re;
// phần ảo:
assign im0 = 32'd0;
assign im1 = tmp5_im;
assign im2 = 32'd0;
assign im3 = rs3;
assign im4 = 32'd0;
assign im5 = -1*tmp5_im;
assign im6 = rs6;
assign im7 = rs7;
endmodule