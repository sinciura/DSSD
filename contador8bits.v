module contador8bits(

input clk, rst_n, en,

output reg [7:0] out);

reg [7:0] contador; //registro interno.
 
always @(posedge clk or negedge rst_n) begin

if (rst_n == 0) begin

contador = 0;

out = contador;

end

else begin

case(en)

1'b0: begin
out = 0;
contador = contador;
end

1'b1: begin
contador = contador + 1;
out = contador;
end
endcase

end
end
endmodule



