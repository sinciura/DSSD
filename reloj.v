module reloj(

input clk, start_cond,

output reg scl);

reg [4:0]contador=5'd0;

always @(posedge clk) begin

case(start_cond)

1'b1: begin

contador <= contador + 1;

if(contador>=5'd5) begin

scl<=1;

end

if(contador<5'd5) begin

scl<=0;

end

if(contador == 5'd10) begin

contador <= 0;
scl<=0;

end

end

1'b0: begin

contador = 0;
scl = 1;

end
endcase

end

endmodule

