module sda(

input r_w, reset,

input[7:0] data, //dada i direcció de registre

input[6:0] slave_a,//direcció del esclau.

input clk, //nose.

input [4:0]contador,

input start,

inout sda_m); //sda entrada i sortida

reg [2:0]state,next;

reg [4:0]contador_sa;

reg sda;

assign sda_m = (sda == 1)?  1'bz : sda;

parameter [2:0] //3 bits per definir estats.

idle = 3'b000,
s1 = 3'b001,
s2 = 3'b010,
s3 = 3'b011,
s4 = 3'b100,
s5 = 3'b101,
s6 = 3'b100;

always @(posedge clk or negedge reset) begin

if (!reset) state <= idle;

else state <= next;

end

always @(state or reset or contador or start) begin

case(state)

idle: begin

if(start==1) next=s1;

else next = idle;

end

s1: begin

next=s2;

end

s2: begin

if(contador==7) next=s3;

else next = s2;

end

s3: begin

if(sda==0) next = s4;

else next = s6;

end

s4: begin

if(contador_sa == 8) next = s5;

else next = s4;

end

s5: begin

next = s6;

end

s6: begin

next = idle;

end

endcase

end

//if(sda == 1) begin

//if(contador == 5) next = idle;

//end

always @(posedge clk or negedge reset) begin

if (reset == 0) sda = 1;

case(next)

idle: begin

sda<=sda;

end

s1: begin //condició de start

//scl<=1'bz;
sda<=0;

end

s2: begin //transmitir dirección de esclavo

if(contador == 7) begin
 
if(contador_sa==7) begin

sda<=r_w;

contador_sa<=0;

end

else begin

sda<=slave_a[6-contador_sa];

contador_sa<=contador_sa+1;

end

end

end

s3: begin //evaluar ack

if (contador == 3) sda<=1;
//scl<=1'bz;

end

s4: begin //enviar datos.

if(contador == 7) begin

if(contador_sa == 8) contador_sa <=0;

else begin

sda<=slave_a[7-contador_sa];

contador_sa<=contador_sa+1;

end

end

end

s5: begin // segundo ack.

if(contador == 3) sda<=1;
//scl<=1'bz;
end

s6: begin //condición de stop.

if(contador == 3) sda<=1;

end

endcase

end

endmodule

























