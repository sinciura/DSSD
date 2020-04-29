module shift_reg(

input clk, rst_n, en, in,

output reg out);

reg [9:0]bits=0;

always @(posedge clk or negedge rst_n) begin

if (~rst_n) begin

bits[9:0] <= 0;

//bits[9:1] <= bits[8:0];

out <= 0;

end

else begin

case(en)

1'b0: begin

bits[0] <= in;

bits[9:1]<=bits[8:0];

out <= 0;

end

1'b1: begin

bits[0] <= in;

bits[9:1]<=bits[8:0];

out <= bits[9];

end

endcase
end
end
endmodule


