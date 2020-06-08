module master(

input clock,

input reset,

input [6:0]slave_add,

input [7:0]data,

input start_cond,

input r_w,

output scl,

inout sda,

output [3:0]state,next,

output [4:0]contador_sa);

wire [4:0]cont_clk;

wire stop;

sda SDA (

.r_w (r_w),
.reset (reset),
.data (data),
.slave_a (slave_add),
.clk (clock),
.contador (cont_clk),
.start (start_cond),
.sda_m (sda),
.state (state),
.stop_cond(stop),
.next (next),
.contador_sa (contador_sa)

);

reloj RELLOTGE(

.clk (clock),
.start_cond (start_cond),
.stop_cond (stop),
.reset(reset),
.scl (scl),
.contador(cont_clk)

);




endmodule
























