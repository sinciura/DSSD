`timescale 1ns/1ns

module test_i2c;

reg clock, reset, r_w, start_cond;

reg [6:0]s_add;

reg [7:0]data;


i2c dut(clock, reset, r_w, start_cond, s_add, data);

initial clock=0;
always #500 clock=~clock;

initial 

begin

reset = 0;
start_cond = 0;
r_w = 0;
s_add =7'b1110101;
data = 8'b11101001; 

#10000;

reset = 1;
start_cond = 1;

#20000;

start_cond = 0;

#50000000;

$stop;

end
endmodule
