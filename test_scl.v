`timescale 1us/1us

module test_scl;

reg clk, start_cond;

wire scl;

reloj dut(clk,start_cond,scl);

initial clk=0;
always #50 clk=~clk;

initial
begin

start_cond=0;
#300;

start_cond=1;
#2000;

$stop;
end
endmodule
