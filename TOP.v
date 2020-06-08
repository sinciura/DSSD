module TOP(

input Reset,

input Clk,

output [7:0]Hex0, Hex1, Hex2, Hex3);

wire clk20;

wire winc;

wire [15:0] dada;

wire wfull;

wire [15:0]rxData;

wire rempty;

wire clk10;

wire rinc;

wire [15:0]s_l;

pll CLKGEN(
   .inclk0                 (Clk)
  ,.c0                     (clk10)
  ,.c1                     (clk20)
);


fifo #(16,12) BUFFER(
   .rdata                  (rxData)
  ,.wfull                  (wfull)
  ,.rempty                 (rempty)
  ,.wdata                  (dada)
  ,.winc                   (winc)
  ,.wclk                   (clk20)
  ,.wrst_n                 (Reset)
  ,.rinc                   (rinc)
  ,.rclk                   (clk10)
  ,.rrst_n                 (Reset)
);


write_module GENERA (

.wclk(clk20),

.wrst_n(Reset),

.winc(winc),

.wdata(dada),

.wfull(wfull)

);

read_module LLEGEIX (

.rdata(rxData),

.rempty(rempty),

.rclk(clk10),

.Rrst_n(Reset),

.rinc(rinc),

.sortida_lectura(s_l)

);

hex2seg I_HEX0(
	.Clk (Clk),
	.Rst_n (Reset),
	.Data	 (s_l[3:0]),
	.seg	 (Hex0[7:0])
	);
hex2seg I_HEX1(
	.Clk (Clk),
	.Rst_n (Reset),
	.Data	 (s_l[7:4]),
	.seg	 (Hex1[7:0])
	);

hex2seg I_HEX2(
	.Clk (Clk),
	.Rst_n (Reset),
	.Data	 (s_l[11:8]),
	.seg	 (Hex2[7:0])
	);
hex2seg I_HEX3(
	.Clk (Clk),
	.Rst_n (Reset),
	.Data	 (s_l[15:12]),
	.seg	 (Hex3[7:0])
	);


endmodule
