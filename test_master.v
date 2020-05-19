`timescale 1ns/1ns

module test_master;

reg clock;

reg reset;

reg [6:0]slave_add;

reg [7:0]data;

reg start_cond;

reg r_w;

wire scl;

wire sda;

//assign sda = 

master dut(clock, reset, slave_add, data, start_cond, r_w, scl, sda);

initial clock=0;
always #50 clock=~clock;

initial
begin

reset=0;

slave_add=6'b010101;
r_w=0;
data=7'b101001;

#200;

reset=1;
start_cond = 1;

#10000;

$stop;
end
endmodule
