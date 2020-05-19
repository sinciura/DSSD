module master(

input clock,

input reset,

input [6:0]slave_add,

input [7:0]data,

input start_cond,

input r_w,

output reg scl,

inout sda);

wire [4:0]cont_clk;

sda SDA (

.r_w (r_w),
.reset (reset),
.data (data),
.slave_a (slave_add),
.clk (clock),
.contador (cont_clk),
.start (start_cond),
.sda_m (sda)

);

reloj SCL(

.clk (clock),
.start_cond (start_cond),
.contador(cont_clk),
.scl (scl)

);

endmodule
























