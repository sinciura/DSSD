`timescale 1ns/1ns

module test_shift_r;

reg clk, rst_n, en, in;

wire out;

shift_reg dut(clk, rst_n, en, in, out);

initial clk =0;
always #20 clk=~clk;

initial
begin

in =1;
en=1;
rst_n=0;
#20;

rst_n=1;
#20;

in = 1;
en=1;
rst_n=1;
#500;

in=1;
en=1;
rst_n=0;
#600;

in=1;
en=0;
rst_n=1;
#1200

$stop;

end
endmodule



