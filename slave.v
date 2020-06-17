module slave(

inout sda_s, //port bidireccional sda.

input scl, //el scl es l'entrada del esclau.

input reset, //reset

input clk, //rellotge del esclau

input [3:0]freq_MHz,

output reg [7:0]dada); //registre per guardar la dada que envia el master.

reg sda; //registre que es fa servir per escriure a la línia
//de SDA del bus i2c.

reg stop;

reg[2:0]state,next; //registre d'estat actual i estat futur.

reg [7:0]add; //registre que es fa servir per comprovar que l'adreça que envia el master
//coincideix amb l'adreça del dispositiu slave. Es de 7 bits perque tambe es guarda el bit de r_w.

//reg [7:0]dada; //registre per guardar la dada que envia el master.

reg [5:0]c,contador; //c es fa servir per guardar el bit que ve en un interval de rellotge a la
//posicio determinada dels vectors add i dada. Contador sincronitza les dades del slave amb el SCL.
//Contador va entre 0 i 10, ja que un interval del SCL equival a 10 intervals del slave. (1 MHz).

reg [4:0]igualtat; //aquesta variable determina si l'adreça d'esclau enviada pel master es correspon amb la del esclau.

reg scl_previ; //registre que es fa servir per sincronitzar l'esclau amb el scl.

reg sda_previ;

wire[5:0]canvi,c_high,c_low; //maxim valor del contador a un cicle.

assign canvi = (freq_MHz == 1) ? 5'd4 : (freq_MHz == 2) ? 5'd9 : (freq_MHz == 3)  ? 5'd14 : 5'd0;

assign c_high = (canvi-(5'd2*freq_MHz))-5'd1;//(SCL 1)

assign c_low = (canvi+(5'd2*freq_MHz));//provisional.(SCL 0)

parameter [3:0]

idle = 4'b0000,
s1 = 4'b0001,
s2 = 4'b0010,
s3 = 4'b0011,
s4 = 4'b0100,
s5 = 4'b0101,
s6 = 4'b0110,
s7 = 4'b0111;

parameter esclau = 7'b1110101; //adreça del esclau.

parameter dato_esc = 8'b10100110; //dada guardada al esclau.

assign sda_s = (sda == 1)?  1'bz : sda;

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

always @(contador or reset or state or igualtat or sda or sda_s or c or add or c_high or c_low) begin

case(state)

//Si l'esclau no detecta cap condició de start es queda al idle. 
//Si detecta una condició de start mitjançant la línia sda, el sistema passa
//al següent estat.

idle: begin

if(sda_s == 0) begin

next = s1; 

end

else next = idle;

end

//Es passa al següent estat quan c val 8 i contador val 5. Quan c val 8 el vector add està ple
// i quan contador val 5 ens trobem a un estat baix del scl, lo que vol dir que la última dada s'ha llegit
//i guardat a add (quan contador val 1). 

s1: begin

if(c == 8 && contador == (c_low-1)) next = s3;

else next = s1;

end

//Si igualtat val 1 es passa a l'estat 4, sino es passa a l'estat 2.

s3: begin

if(igualtat==1) next=s4;

else next = s2;

end

//Es passa al següent estat quan contador es igual a 2. Això succeeix perquè,
//el master llegeix el bit de ack quan SCL es troba en un estat alt, concretament, quan
//el seu contador de rellotge val 2. Tenint en compte que el master llegeix el bit d'ack
//quan el seu contador de rellotge (c_clk) val 2, i que el contador de rellotge del slave
//va un cicle de clk retrasat amb el master, si contador val 2 es passa al següent estat un cicle
//de rellotge després de que el master hagi llegit del bit de ack. El següent estat depen del
//bit de r_w, que està guardada a la posició de menys pes de add.

s4: begin

if(igualtat == 1 && contador == c_low) begin

if (add[0]==1) next = s6;

else next = s5;

end 

else next = s4;

end

//Quan c val 8 s'ha omplert el registre de 8 posicions anomenat dada.
//Quan contador val 6 la última dada guardada al registre dada ha estat activada
//un cicle de rellotge, per tant és hora de passar al següent estat.

s5: begin

if(c == 8 && contador == c_low) next = s7;

else next=s5;

end

//Quan c val 8 s'han enviat tots els bits de la dada dato_esc.
//Quan contador val 6 la última  dada ha estat activada
//un cicle de rellotge, per tant és hora de passar al següent estat.

s6: begin

if(c == 8 && contador == c_low) next = s7;

else next=s6;

end

//l'ack es fa quan SCL està a nivell alt, i després es passa al següent estat.
 
s7: begin

if(contador == c_low) next = s2;

else next = s7;

end

//Quan SDA es possi a alta impedància passem a l'estat idle, on s'espera una nova condició de start.

s2: begin

if(stop == 1) next = idle;

else begin

if(contador == c_low) begin

if(add[0] == 0) next = s5;

else next = s4;

end

else next = s2;

end

end

default: begin

next=idle;

end

endcase

end

//////////////////////////////////////////////////////////////////

always @(posedge clk or negedge reset) begin

if(reset == 0) begin

contador<=0;
igualtat<=0;
sda<=1;
stop<=0;
c<=0;

end

else begin

//per que el contador de rellotge es reinici cada cop que hi hagi un flanc de pujada
//de scl es guarda el valor de scl a un registre anomenat scl previ. Després, al flanc de 
//rellotge següent es compara el valor anterior de scl amb l'actual: si l'anterior val 0
//i l'actual val 1 es que s'ha produit un flanc de pujada i el contador es reseteja un clock
//després de que s'hagi produit un flanc de pujada a scl. Si no s'ha produit cap flanc el contador
//es va incrementant. 

scl_previ<=scl;

if((scl_previ == 0) && (scl==1)) contador<=0;

//if((scl_previ == 1) && (scl==0)) canvi<=(contador-1); //4 en este caso.

else contador<=contador + 5'd1;

case(next)

idle: begin

sda<=1;
contador<=contador;
c<=c;
stop<=0;

end

//El que fa el slave a s1 es guardar la informació que li ve per la línia SDA
//a un registre de 8 bits. En aquest registre es guarda la direcció d'esclau i el
//bit de r_w.

s1: begin 

if(contador == c_low) c<= c+5'd1; //Quan contador val 6 s'avança una posició del registre. 

if(contador == c_high && c > 0) begin //la dada es guarda al registre quan contador val 1 pq SCL
                                 //es troba en un estat alt, que és on les dades són estables.
if (c<=8) add[8-(c)]<=sda_s;     

end

end

//a s3 es mira si els 7 últims bits coincideixen amb la direcció d'esclau del dispositiu.
//si coincideixen el regitres igualtat es posa a 1, sino val 0.

s3: begin

if(add[7:1] == esclau) igualtat <= 1;

else igualtat <=0;

end

//en aquest estat es fa l'acknowledge. El slave posa sda a 0 per fer-li saber al master que ha reconegut les
//dades que ha enviat per sda. També es reseteja c.

s4: begin

if(igualtat == 1) begin

sda <= 0;
c<=0;

end

end

//si r_w = 0, es passa a aquest estat. En aquest estat es guarda sda al registre dada.

s5: begin 

sda<=1;

if(contador == c_high) begin //quan contador sigui 1 SCL es troba en estat alt, es guarda SDA a una posició de dada
		        //que va augmentant, però només es guarda SDA a dada si c es menor que 8. Quan aquest
                        //sigui igual a 8 es canvia d'estat.

if(c<8) dada[7-c]<=sda_s ;

c<=c+5'd1;

end

end

//si r_w = 1 es passa a aquest estat. En aquest estat el esclau envia al master una dada.

s6: begin 

if(contador == c_low) begin //quan contador sigui 6 SCL es troba en estat baix i per tant es canvia 
			//el bit que s'envia per SDA.

if(c<8) sda<=dato_esc[7-c]; //Mentre c sigui menor que 8 s'aniràn enviant els bits de la dada de l'esclau.

c<=c+5'd1;

end

end

//En aquest estat es fa el segon ack. el contador de posició es posa a 0 i sda també.

s7: begin //2ndo ack.

c<=0;
sda<=0;

end

//Estat de condició de stop. SDA s'allibera, ja que la condició de stop la genera el master.

s2: begin

sda<=1;

sda_previ<=sda_s;

//if(contador != c_low) begin

if(contador >= 0 && contador << canvi) begin

if(sda_previ == 0 && sda_s==1) begin

stop <=1;
sda<=1;

end

else stop <=0;

end

//end

end

default: begin

sda<=1;

end

endcase

end

end

endmodule

















