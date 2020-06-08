`timescale 1ns/1ns

module test_contador8bits;

reg clk, rst_n, en;

wire [7:0] out;

contador8bits dut(clk,rst_n,en,out);

always 

begin

#25 clk=!clk;

end

initial
begin

clk = 0;
en=0;
rst_n=0;
#50;

clk = 0;
en=0;
rst_n=1;
#50;

clk = 0;
en=1;
rst_n=0;
#50;

clk = 0;
en=1;
rst_n=1;
#50;

clk = 1;
en=0;
rst_n=0;
#50;

clk = 1;
en=0;
rst_n=1;
#50;

clk = 1;
en=1;
rst_n=0;
#50;

clk = 1;
en=1;
rst_n=1;


end
endmodule

