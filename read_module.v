module read_module(

input [15:0]rdata,

input rempty, rclk, Rrst_n,//1 quan la memoria està buida.

output reg rinc,

output reg [15:0]sortida_lectura);

parameter [2:0]

reset = 3'b000,
idle = 3'b001,
s1 = 3'b010;

reg [2:0]state, next;

always @(posedge rclk or negedge Rrst_n) begin

if (!Rrst_n) state <= reset;

else state <= next;

end

always @(Rrst_n, rinc, rempty, rdata, state, next) begin

case(state) 

reset: begin //estat del reset

rinc = 0;

sortida_lectura=0;

if (Rrst_n == 1) next = s1;
else next = reset;

end

idle: begin

rinc = 0;

sortida_lectura = sortida_lectura;

if (rempty == 1) begin

next = idle;

end

else next = s1;

end

s1: begin

rinc = 1;

sortida_lectura = rdata;

if (rempty == 1) next = idle;

else next = s1;

end

endcase
end
endmodule

 



