module sda(

input r_w, reset, //bit d'entrada que indica si es vol
//llegir o escriura al slave i bit de reset.

input[7:0] data, //dada que es vol escriure al esclau.

input altre_byte,//entrada que indica si es vol enviar un altre byte o no

input[6:0] slave_a,//direcció del esclau. 7 bits.

input clk, //clock del master.

input [5:0]contador, //contador es una variable d'entrada que ve
//del bloc que genera el SCL a partir del rellotge del master.
//El bloc SDA es sincronitza amb el bloc SCL segons el valor del contador.

input start, //condició de començament de comunicació

input [5:0]canvi,final_,

input [3:0] f_MHz,

inout sda_m, //port SDA

output reg stop_cond); //condició de stop que genera el bloc sda del master
//quan rep l'últim ack del slave. Està posada com a sortida perquè va
//al bloc SCL del master.

reg [3:0]state, next; //registre d'estat actual i estat futur.

reg[4:0]contador_sa; //contador que es fa servir per gaurdar o enviar
//dades bit a bit.

wire [5:0]c_low, c_high;

reg sda,ack, a_b; //registre que es fa servir per escriure a la línia
//de SDA del bus i2c.

reg [7:0] lectura; //registre per guardar dades del slave.

assign sda_m = (sda == 1)?  1'bz : sda; //el que fa aquest assign es
//posar sda a alta impedància quan val 1.

assign c_low = (final_-5'd2*f_MHz); //(SCL BAIX)

assign c_high = ((canvi-5'd2*f_MHz))-1; //(SDA ALT)

parameter [3:0] //3 bits per definir estats.

idle = 4'b0000,
s1 = 4'b0001,
s2 = 4'b0010,
s3 = 4'b0011,
s4 = 4'b0100,
s5 = 4'b0101,
s6 = 4'b0110,
s7 = 4'b0111,
s8 = 4'b1000;

always @(posedge clk or negedge reset) begin 

//bloc always que indica que es  canvia d'estat al flanc de pujada del rellotge 
//quan el reset està desactivat.Si el reset està activat l'estat
//al que passa el bloc és al idle.

if (!reset) state <= idle;

else state <= next;

end

//bloc always que s'encarrega de calcular quin sera l'estat següent a partir
//de l'estat actual i el valor de les variables que es troben a la llista de
//sensibilitat.

always @(state or reset or contador or start or contador_sa or sda_m or stop_cond or r_w or c_high or c_low or altre_byte) begin

case(state)

//El sistema roman al bloc idle fins que la variable d'entrada
//start es posa a 1.

idle: begin

if(start== 1) next = s1;

else next = idle;

end

//Quan el contador del rellotge val 4 es passa al següent estat.
//La condició de start es genera quan contador = 2. Per tant, es passa
//a l'estat 2 2 cicles de rellotge del master després.

s1: begin

if(contador == c_high) next = s2;

else next = s1;

end

//quan contador_sa val 8 i el contador de rellotge val 7
//significa que s'ha transmet l'adreça i el bit de r_w i es 
//pot passar al següent estat. 

s2: begin

if(contador_sa == 8 && contador == c_low) next = s3;

else next = s2;

end

//l'avaluacio del bit d'acknowledge s'ha de fer mentre el SCL
//estigui en estat alt (contador = 2). Contador_sa val 0.
//Si després d'enviar la direcció d'esclau sda val 0, el esclau
//ha fet l'ack. Si val 1, vol dir que l'intent de comunicació
//amb l'esclau no ha donat resultat.

s3: begin

if(contador == c_high && contador_sa == 0) begin

if(sda_m!= 0 & sda_m!= 1) next = idle; //si sda te un valor indeterminat
// el sistema va al idle.

else begin

if(sda_m == 0) begin //si s'ha fet ack per part del slave es passa a 
//avaluar el bit de r_w. Si val 0 es passa a l'estat d'escriptura,
//sino a l'estat de lectura.

//sda<=sda_m;

if(r_w == 0) next = s4;

else next = s5;

end

else next = s7; //Si el slave no ha fer l'ack, (sda val 1) es passaÃ
//a l'estat s7, on es genera la condició de stop.

end

end

else next = s3;//Si el contador del rellotge no val 2 es manté el s3.

end

//Es passa al següent estat quan s'ha trasnmes la dada per complet. Això
//passa quan contador_sa val 8, ja que la dada es de 8 bits, i quan contador val 7,
//ha que quan contador val 7 es quan es começa o s'acaba de transmetre un bit.

s4: begin

if(contador_sa == 8 && contador == c_low) next = s6;

else next = s4;

end

//Es passa al següent estat quan s'ha llegit la dada per complet. Això
//passa quan contador_sa val 8, ja que la dada es de 8 bits, i quan contador val 7,
//ha que quan contador val 7 es quan es começa o s'acaba de transmetre un bit.

s5: begin

if(contador_sa == 8 && contador == c_low) next = s6;

else next = s5;

end

//En aquest estat s'avalua el bit s'ack que prové del slave
//l'avaluacio del bit d'acknowledge s'ha de fer mentre el SCL
//estigui en estat alt (contador = 1).

s6: begin

if(contador == c_low) begin

if(ack!= 0 && ack!= 1) next = idle;

else next = s6;

if(ack == 0 && altre_byte == 1) begin 

if(r_w == 0) next = s4;

else next = s5;

end

else next = s7;

end

else next = s6;

end

//just després de fer el ack es passa a l'estat de la condició de stop.
//Quan aquesta s'ha produit (sda a 1) i el bit de stop cond s'ha posat a 1 es passa
//al estat idle, on es roman fins que es vulgui fer una alta comunicació.
//Si la condició de stop no s'ha fet encara es roman al estat 7.

s7: begin

if(sda_m == 1 && stop_cond == 1) next = idle;

else next = s7;

end

default: begin

next=idle;

end

endcase

end

always @(posedge clk or negedge reset) begin

if (reset == 0) begin

sda <= 1;
contador_sa<=0;
stop_cond<=0;

end

else begin

case(next)

//A l'estat idle sda mante el valor que tenia previament
//i la condició de stop val 0.

idle: begin

stop_cond<=0;

sda<=sda;

end

//Al passar al estat 1, el sistema s'espera fins que SCL
//es troba en un estat alt per posar SDA a nivell baix.
//Quan el contador del rellotge val 2 es troba al mig de
//l'estat alt de scl.

s1: begin

sda<=0;

end

//En aquest estat es transmet la direccio d'esclau.
//En un bus i2c les dades varien quan SCL val 0 i son estables
//quan SCL val 1.
//Cada cop que el contador val 7 el SCL es troba al mig de l'estat
//baix, per tant, cada cop que el contador es troba en aquest estat 
//es transmet un bit nou de l'adreça.

s2: begin

//sda<=1;

if(contador == c_low) begin
 
if(contador_sa == 7) begin //Quan es trasmeten els 7 bits d'adreça
//es transmet el bit que indica que a continuació es vol fer una lectura
//o escriptura.

sda<=r_w; 

contador_sa <= contador_sa + 1'd1; //s'incrementa el comptador per passar al
//següent estat.

end

if(contador_sa<7) begin //es trasnmeten els 7 bits d'adreça.

sda<=slave_a[6-contador_sa]; 

contador_sa<=contador_sa+1'd1;

end

end

end

//En aquest estat s'avalua l'ack del slave i 
//es reseteja el contador de posició. sda es posa en
//estat alt per rebre el bit d'ack del slave.

s3: begin 

contador_sa<=0;
//sda<=1;

if(contador == c_high) sda<=sda_m;

else sda<=1;

end

s4: begin //Quan s'ha fet el ack per part del slave i r_w = 0
//s'entra a aquest estat.

if(contador == c_low) begin //Quan el SCL es troba en estat baix es 
//transmet un nou bit del vector de dades d'entrades per el SCL.

if(contador_sa>0 || contador_sa<8) begin //va del de 1 a 7

sda<=data[7-contador_sa]; //sda passa a valer data bit a bit.

contador_sa<=contador_sa+5'd1; //el contador es va incrementant fins a 7.

end

end

end

s5: begin //Quan s'ha fet el ack per part del slave i r_w = 1
//s'entra a aquest estat.

sda<=1; //es posa sda a estat alt per llegir les dades que provenen de l'esclau.

if(contador == c_low) contador_sa<= contador_sa+5'd1; //cada cop que contador val 7 s'incrementa la posició del registre.

//antes 2

if((contador == c_high) && (contador_sa > 0 && contador_sa <=8)) begin //Quan contador val 2 SCL es troba en estat alt i la dada es estable.
								  //la posició anira entre 1 y 8, i com que les posicions del registre
                                                                  //van de 0 a 7, se li resta 1 a la posició. contador_sa ha d'estar entre 1 i 8
                                                                  //i no 0 i 7 perquè l primera dada de l'esclau arriba quan contador_sa val 1.
lectura[7-(contador_sa-1)]<=sda_m; 
 
end

end


//a s6 es llegeix el bit d'ack que envia el slave.

s6: begin 

contador_sa<=0;

sda<=1;

if(contador == (c_high-1)) ack<=sda_m;

else ack<=ack;

end

//a s7 s'envia la condició de stop al slave. SDA es posa a 1, i el stop_cond també.
//el contador de posició es reseteja.

s7: begin //condición de stop.

if(contador == c_high+1) begin

sda<=1;
stop_cond<=1;
contador_sa <=0;

end

else sda<=sda_m;

end

default: begin

sda<=1;

end

endcase

end

end

endmodule

























