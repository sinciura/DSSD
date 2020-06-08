`timescale 1ns/1ns

module test_contador8bits;

reg clk, rst_n, en;

wire [7:0] out;

contador8bits dut(clk,rst_n,en,out);

initial clk =0;
always #20 clk=~clk;

initial
begin

en=0;
rst_n=0;
#50;

en=1;
rst_n=1;
#300;

en=0;
rst_n=1;
#100;

en=0;
rst_n=0;
#50;

en=1;
rst_n=1;
#50;

end
endmodule

