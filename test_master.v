`timescale 1ns/1ns

module test_master;

reg clock;

reg reset;

reg [6:0]slave_add;

reg [7:0]data;

reg start_cond;

reg r_w;

wire scl;

wire sda; //sortida

wire [4:0]contador_sa;

wire stop_cond;

wire [2:0]state,next;

//assign sda = 

master dut(clock, reset, slave_add, data, start_cond, r_w, scl, sda, state, next,contador_sa);

initial clock=0;
always #50 clock=~clock;

initial
begin

reset=0;

slave_add=7'b1110101;
r_w=0;
//contador_sa=0;
data=7'b101001;

#200;

reset=1;
start_cond = 0;

#200;

start_cond=1;

#500

start_cond=0;

#20000;

$stop;
end
endmodule
