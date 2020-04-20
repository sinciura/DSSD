`timescale 1ns/1ns

module test_TOP;

reg Clk, Reset;

wire [7:0]Hex0, Hex1, Hex2, Hex3;

TOP dut(Reset, Clk, Hex0, Hex1, Hex2, Hex3);

initial Clk =0;
always #10 Clk=~Clk;

initial
begin

Reset = 0;
#50

Reset = 1;
#10000
$stop;

end
endmodule