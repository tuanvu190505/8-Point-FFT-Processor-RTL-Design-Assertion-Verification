`timescale 1ns/1ns
module testbench;
// ===================== clock / reset =====================
logic clk;
logic rst_n;
initial clk = 1'b0;
always #5 clk = ~clk;
task automatic apply_reset();
rst_n = 1'b0;
repeat (3) @(posedge clk);
rst_n = 1'b1;
@(posedge clk);
endtask
//
=========================================================
// 1) UNIT TEST: full_adder
//
=========================================================
logic fa_a, fa_b, fa_cin;
logic fa_sum, fa_cout;
full_adder u_fa (
.a(fa_a), .b(fa_b), .c_in(fa_cin),
.sum(fa_sum), .c_out(fa_cout)
);
property p_full_adder;
@(posedge clk)
{fa_cout, fa_sum} == (fa_a + fa_b + fa_cin);
endproperty
assert property(p_full_adder)
else $error("full_adder FAIL: a=%0b b=%0b cin=%0b => sum=%0b
cout=%0b",
fa_a,fa_b,fa_cin,fa_sum,fa_cout);
//
=========================================================
// 2) UNIT TEST: full_adder_32bit
//
=========================================================
logic [31:0] fa32_a, fa32_b;
logic fa32_cin;
logic [31:0] fa32_sum;
logic fa32_cout;
full_adder_32bit u_fa32 (
.a(fa32_a), .b(fa32_b), .c_in(fa32_cin),
.sum(fa32_sum), .c_out(fa32_cout)
);
property p_fa32;
@(posedge clk)
({fa32_cout, fa32_sum} == ({1'b0,fa32_a} + {1'b0,fa32_b} + fa32_cin));
endproperty
assert property(p_fa32)
else $error("fa32 FAIL: a=%h b=%h cin=%0b => sum=%h cout=%0b",
fa32_a,fa32_b,fa32_cin,fa32_sum,fa32_cout);
//
=========================================================
// 3) UNIT TEST: sub_32bit
//
=========================================================
logic [31:0] sub_a, sub_b;
logic [31:0] sub_sum;
logic sub_cout;
sub_32bit u_sub32 (
.a(sub_a), .b(sub_b),
.sum(sub_sum), .c_out(sub_cout)
);
property p_sub32;
@(posedge clk)
({sub_cout, sub_sum} == ({1'b0,sub_a} + {1'b0,(~sub_b)} + 33'd1));
endproperty
assert property(p_sub32)
else $error("sub32 FAIL: a=%h b=%h => sum=%h cout=%0b",
sub_a,sub_b,sub_sum,sub_cout);
//
=========================================================
// 4) UNIT TEST: butter_fly_1 (sum=a+b, sub=a-b)
//
=========================================================
logic [31:0] bf_a, bf_b;
logic [31:0] bf_sum, bf_sub;
butter_fly_1 u_bf1 (
.a(bf_a), .b(bf_b),
.sum(bf_sum), .sub(bf_sub)
);
property p_bf1;
@(posedge clk)
(bf_sum == (bf_a + bf_b)) && (bf_sub == (bf_a - bf_b));
endproperty
assert property(p_bf1)
else $error("bf1 FAIL: a=%h b=%h => sum=%h sub=%h",
bf_a,bf_b,bf_sum,bf_sub);
//
=========================================================
// 5) UNIT TEST: delay (dout = din delayed 9 cycles)
// FIX: only assert after pipeline warmed up (>=9 cycles)
//
=========================================================
logic signed [31:0] d_din;
logic signed [31:0] d_dout;
delay u_delay (
.clk(clk),
.rst_n(rst_n),
.din(d_din),
.dout(d_dout)
);
int delay_cnt;
always_ff @(posedge clk or negedge rst_n) begin
if (!rst_n)
delay_cnt <= 0;
else if (delay_cnt < 9)
delay_cnt <= delay_cnt + 1;
end
property p_delay9;
@(posedge clk)
(delay_cnt >= 9) |-> (d_dout == $past(d_din, 9));
endproperty
assert property(p_delay9)
else $error("delay FAIL: din_now=%h dout=%h expected=%h",
d_din, d_dout, $past(d_din,9));
//
=========================================================
// 6) TOP TEST: fft (your module)
//
=========================================================
logic [31:0] x0,x1,x2,x3,x4,x5,x6,x7;
logic [31:0] re0,re1,re2,re3,re4,re5,re6,re7;
logic [31:0] im0,im1,im2,im3,im4,im5,im6,im7;
fft dut (
.clk(clk),
.rst_n(rst_n),
.x0(x0),.x1(x1),.x2(x2),.x3(x3),.x4(x4),.x5(x5),.x6(x6),.x7(x7),
.re0(re0),.re1(re1),.re2(re2),.re3(re3),.re4(re4),.re5(re5),.re6(re6),.re7(re7),
.im0(im0),.im1(im1),.im2(im2),.im3(im3),.im4(im4),.im5(im5),.im6(im6),.im7(im7)
);
function automatic bit all_fft_outputs_zero();
return (re0==0 && re1==0 && re2==0 && re3==0 && re4==0 && re5==0
&& re6==0 && re7==0 &&
im0==0 && im1==0 && im2==0 && im3==0 && im4==0 &&
im5==0 && im6==0 && im7==0);
endfunction
task automatic check_fft_all_zero_after(input int cycles);
int n;
for (n = 0; n < cycles; n++) @(posedge clk);
if (!all_fft_outputs_zero()) begin
$error("FFT FAIL: expected all zero after %0d cycles", cycles);
$display("re: %h %h %h %h %h %h %h %h",
re0,re1,re2,re3,re4,re5,re6,re7);
$display("im: %h %h %h %h %h %h %h %h",
im0,im1,im2,im3,im4,im5,im6,im7);
$fatal;
end else begin
$display("FFT PASS: all zero after %0d cycles", cycles);
end
endtask
//
=========================================================
// Stimulus
//
=========================================================
int t;
initial begin
// init everything (avoid X)
rst_n = 1'b1;
fa_a=0; fa_b=0; fa_cin=0;
fa32_a=0; fa32_b=0; fa32_cin=0;
sub_a=0; sub_b=0;
bf_a=0; bf_b=0;
d_din='0;
x0=0; x1=0; x2=0; x3=0; x4=0; x5=0; x6=0; x7=0;
apply_reset();
// -------- UNIT: full_adder exhaustive --------
$display("[TB] full_adder exhaustive");
for (t=0; t<8; t++) begin
{fa_a,fa_b,fa_cin} = t[2:0];
@(posedge clk);
end
// -------- UNIT: fa32 random --------
$display("[TB] full_adder_32bit random");
repeat (50) begin
fa32_a = $urandom();
fa32_b = $urandom();
fa32_cin = $urandom_range(0,1);
@(posedge clk);
end
// -------- UNIT: sub32 random --------
$display("[TB] sub_32bit random");
repeat (50) begin
sub_a = $urandom();
sub_b = $urandom();
@(posedge clk);
end
// -------- UNIT: bf1 random --------
$display("[TB] butter_fly_1 random");
repeat (50) begin
bf_a = $urandom();
bf_b = $urandom();
@(posedge clk);
end
// -------- UNIT: delay ramp --------
$display("[TB] delay ramp");
d_din = 0;
repeat (30) begin
d_din <= d_din + 1;
@(posedge clk);
end
// -------- TOP: FFT zero (flush đủ lâu rồi check) --------
$display("[TB] FFT test: all zeros");
x0=0; x1=0; x2=0; x3=0; x4=0; x5=0; x6=0; x7=0;
check_fft_all_zero_after(40);
// -------- TOP: FFT impulse (quan sát) --------
$display("[TB] FFT test: impulse x0");
x0=32'd1000; x1=0; x2=0; x3=0; x4=0; x5=0; x6=0; x7=0;
repeat (50) @(posedge clk);
$display("[TB] DONE.");
$finish;
end
endmodule