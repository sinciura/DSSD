module reloj(

input clk, start_cond, stop_cond,reset, //entrades i sortides del mòdul.

input [3:0]r_MHz, //(de 1 a 3 MHz)

inout scl_t,

output reg [5:0]contador,

output [5:0]canvi,final_);

reg [2:0]state,next; //registres que guarden el valor de l'estat actual i de l'estat futur

reg scl; //registre per guardar el valor de scl.

parameter [2:0]

idle = 3'b000,
s1 = 3'b001,
s2 = 3'b010;

assign scl_t = (scl == 1)?  1'bz : scl;//el que fa aquest assign es
//posar scl_t a alta impedància quan val 1 

assign canvi = (r_MHz == 1) ? 5'd4 : (r_MHz == 2) ? 5'd9 : (r_MHz == 3)  ? 5'd14 : 5'd0;

assign final_ = (((canvi)<<1)+5'd1);

//bloc always que indica que es  canvia d'estat al flanc de pujada del rellotge 
//quan el reset està desactivat.Si el reset està activat l'estat
//al que passa el bloc és al idle.

always @(posedge clk or negedge reset) begin

if (!reset) state <= idle;

else state <= next;

end

//bloc always que s'encarrega de calcular quin sera l'estat següent a partir
//de l'estat actual i el valor de les variables que es troben a la llista de
//sensibilitat.
always @(start_cond or contador or state or stop_cond) begin

case(state)

//si la variable d'entrada start_cond, que ve del bloc sda, val 1, es passa
//a s1, sino es roman al idle.
idle: begin

if(start_cond==1) next = s1;

else next = idle;

end

//Si mentre ens trobem a l'estat 1 es rep una condició de stop del bloc SDA
//es passa a l'estat 2, sino es segueix a l'estat 1.
s1: begin

if(stop_cond==1) next = s2;

else next = s1;

end

//Després de fer la condició de stop es passa al idle, per esperar una altra condició de start.
s2: begin

next = idle;

end

default: begin

next = idle;

end

endcase

end

always @(posedge clk or negedge reset) begin

//Si es produeix un reset el contador es posa a 0 i el scl es posa en estat alt.

if (reset == 0) begin

scl = 1;
contador<=0;

end

else begin

case(next)

//Al idle el contador i el scl mantenen el seu valor.

idle: begin

scl<=scl;
contador<=contador;

end

//A l'estat 1 es forma el scl a partir de rellotge del master. El SCL va amb una freqüència de 
//100 kHz i el master a una de 1MHz, per tant 1 cicle del SCL son 10 cicles del rellotge principal.
s1: begin

contador <= contador + 5'd1; //el comptador es va incrementant fins que arriba a 10.

if(contador>=canvi) begin

scl<=1'b0;

end

if(contador<canvi) begin

scl<=1'b1;

end

if(contador == final_ ) begin

contador <= 1'b0;
scl<=1'b1;

end

end

//En aquest estat es genera la condició de stop: SCL es posa a 1 i el contador es reinicia.

s2: begin

contador <= 1'b0;
scl<=1'b1;

end

default: begin

contador<=contador;
scl<=1;

end

endcase

end

end

endmodule

