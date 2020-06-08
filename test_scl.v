`timescale 1ns/1ns

module test_scl;

reg clk, start_cond, reset;

wire scl;

wire [4:0] contador;

reloj dut(clk,start_cond,reset,scl,contador);

initial clk=0;
always #50 clk=~clk;

initial
begin

reset=0;
#100;

reset=1;
start_cond=1;
//stop_cond=0;
//reset=1;
#300;

start_cond=0;
#1500

//stop_cond=1;
//#2000;

$stop;
end
endmodule
