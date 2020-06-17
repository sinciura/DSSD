module i2c(

input clock_master,clock_slave,reset,r_w,start_cond,

input [3:0] valor_clk_MHz,freq_slave,

input [6:0]s_add,

input [7:0]data,

input a_b

);

pullup (scl); //Es posa la resistència de pull up a SCL i SDA.
pullup (sda);

wire stop;

wire [5:0]cont_clk; //uneix la sortida del bloc scl amb l'entrada del bloc sda.

wire [5:0]canvi,final_;

//ESCLAU

slave ESCLAU(

.sda_s(sda), 
.scl(scl),
.reset(reset),
.clk(clock_slave),
.freq_MHz(freq_slave),
.dada(dada)

);

//MESTRE

//SDA i SCL

sda SDA (

.r_w (r_w),
.reset (reset),
.data (data),
.altre_byte(a_b),
.slave_a (s_add),
.clk (clock_master),
.contador (cont_clk),
.start (start_cond),
.canvi(canvi),
.final_(final_),
.f_MHz(valor_clk_MHz),
.sda_m (sda),
.stop_cond(stop)

);

reloj SCL(

.clk (clock_master),
.start_cond (start_cond),
.stop_cond(stop),
.reset(reset),
.r_MHz(valor_clk_MHz),
.scl_t (scl),
.contador(cont_clk),
.canvi(canvi),
.final_(final_)

);

endmodule


