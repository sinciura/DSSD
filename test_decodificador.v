`timescale 1ns/1ns

module test_decodificador; //necesitamos un reset global.

reg en;
reg [1:0] sel;
  
wire [3:0] out;
  
reg enab;
  
reg [1:0] bit_sel;
  
wire [3:0] sort;
  
decodificador dut(en,sel,out,enab,bit_sel,sort);

initial 
begin

en = 1'b1;
sel = 2'b00;
#50;

enab = 1'b1;
bit_sel = 2'b00;
#50;

en = 1'b1;
sel = 2'b01;  
#50;

enab = 1'b1;
bit_sel = 2'b01;
#50;

en = 1'b1;
sel = 2'b10;
#50;

enab = 1'b1;
bit_sel = 2'b10;
#50;

en = 1'b1;
sel = 2'b11;
#50;

enab = 1'b1;
bit_sel = 2'b11;
#50;

en = 1'b0;
sel = 2'b00;
#50;

enab = 1'b0;
bit_sel = 2'b00;
#50;

en = 1'b0;
sel = 2'b01;
#50;

enab = 1'b0;
bit_sel = 2'b01;
#50;

en = 1'b0;
sel = 2'b10;
#50;

enab = 1'b1;
bit_sel = 2'b10;
#50;

en = 1'b0;
sel = 2'b11;

end
endmodule








 





