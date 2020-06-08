module decodificador(
  input en,
  input [1:0] sel,
  output reg [3:0] out,
  input enab,
  input [1:0] bit_sel,
  output [3:0] sort);

 
  always@(*)begin
    if (en == 1'b1) begin
      case(sel)

        2'b00: out = 4'b1110;
        2'b01: out = 4'b1101;
        2'b10: out = 4'b1011;
        2'b11: out = 4'b0111;
      endcase
    end
    else out = 4'b1111;
  end
   
  assign sort = (enab == 1'b0) ? 4'b1111 :
                  (bit_sel == 2'b00) ? 4'b1110 :
                    (bit_sel == 2'b01) ? 4'b1101 :
                      (bit_sel == 2'b10) ? 4'b1011 : 4'b0111;

endmodule

