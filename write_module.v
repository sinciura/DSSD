module write_module( //definició d'entrades i sortides del mòdul.

input wclk, wrst_n,

output reg winc,

output reg [15:0]wdata,

input wfull);

parameter [2:0] //definició dels estats de la màquina d'estats.

idle = 3'b001,
s2 = 3'b010,
s3 = 3'b011,
s4 = 3'b100;

reg [2:0]state, next; //tenim un estat i un estat  següent.

wire paritat; //la manera de calcular la paritat de wdata és amb una xor bit a bit, si el resultat és 1 té un nombre imparell de uns, si és zero té un nombre parell de uns.

assign paritat = wdata[0]^wdata[1]^wdata[2]^wdata[3]^wdata[4]^wdata[5]^wdata[6]^wdata[7]^wdata[8]^wdata[9]^wdata[10]^wdata[11]^wdata[12]^wdata[13]^wdata[14]^wdata[15];

//3 blocs always, un per indicar que s'ha de canviar d'estat als flancs de pujada i que quan el reset estigui activat vagi al idle.

always @(posedge wclk or negedge wrst_n) begin

if (!wrst_n) state <= idle;

else state <= next;

end

//un altre per calcular quin estat és el següent a partir de l'estat al que ens trobem actualment.
always @(paritat or winc or wdata or wrst_n or wfull or state) begin

case(state)

idle: begin

if (wfull == 1) next = idle;
else next = s2;

end

s2: begin

if(wfull == 0) next = s3;
else next = idle;

end

s3 : begin

if(paritat == 1) next = s4;
else next = s2;

end

s4: begin //escriure a la memoria
next = s2;

end

default: begin

next=idle;

end
endcase
end

always @(posedge wclk or negedge wrst_n) begin

if(wrst_n==0) begin

wdata=0;
winc=0;

end

else begin

case(next)

idle: begin
winc<= 0;
wdata<=wdata;

end

s2: begin

winc <= 0;
wdata<=wdata+16'd1;

end

s3: begin

wdata<=wdata;
winc<= 0;

end

s4: begin

wdata <= wdata;
winc <= 1; //enviar a la fifo.

end
endcase
end
end
endmodule














 




