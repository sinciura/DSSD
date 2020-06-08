module i2c(

input clock, reset, r_w, start_cond,

input [6:0]s_add,

input [7:0]data

);

pullup (scl); //Es posa la resistència de pull up a SCL i SDA.

pullup (sda);

wire stop;

wire [4:0]cont_clk;

//ESCLAU

slave ESCLAU(

.sda_s(sda), 
.scl(scl),
.reset(reset),
.clk(clock),
.dada(dada)

);

//MESTRE

//SDA i SCL

sda SDA (

.r_w (r_w),
.reset (reset),
.data (data),
.slave_a (s_add),
.clk (clock),
.contador (cont_clk),
.start (start_cond),
.sda_m (sda),
.stop_cond(stop)

);

reloj SCL(

.clk (clock),
.start_cond (start_cond),
.stop_cond(stop),
.reset(reset),
.scl_t (scl),
.contador(cont_clk)

);

endmodule


