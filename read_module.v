module read_module(//definició de les variables d'entrada i sortida del mòdul.

input [15:0]rdata, 

input rempty, rclk, Rrst_n,

output reg rinc,

output reg [15:0]sortida_lectura);

parameter //defició dels registres interns del mòdul.

idle = 1'b0,
s1 = 1'b1;

reg state, next;

always @(posedge rclk or negedge Rrst_n) begin //els estats varien amb els flancs de pujada del rellotge.

if (!Rrst_n) state <= idle; //si es produeix un reset el sistema va al idle.

else state <= next; //sino es va variant d'estat segons la situació del mòdul.

end

always @(Rrst_n, rinc, rempty, rdata, state, next) begin //mòdul per calcular quin seria l'estat següent depenent de l'estat actual.

case(state) 

idle: begin

if (rempty == 1) next = idle;

else next = s1;

end

s1: begin

if (rempty == 1) next = idle;

else next = s1;

end

endcase
end

always @(posedge rclk or negedge Rrst_n) begin //always per calcular que s'ha de fer dins de cada estat.

if(Rrst_n==0) begin

sortida_lectura=0;
rinc=0;

end

else begin

case(next)

idle: begin

rinc <= 0;

sortida_lectura <= sortida_lectura;

end

s1: begin

rinc <= 1;

sortida_lectura <= rdata;

end

endcase
end
end

endmodule

 



