`timescale 1ns/1ns

module test_rm;

reg wclk, wrst_n, wfull;

wire [15:0]wdata;

wire winc;

write_module dut(wclk,wrst_n,winc,wdata,wfull);

initial wclk =0;
always #10 wclk=~wclk;

initial
begin

wrst_n = 0;
wfull = 0;
#25;

wrst_n = 1;
wfull = 1;
#60;

wrst_n=1;
wfull=0;
#1000;
$stop;


end
endmodule


