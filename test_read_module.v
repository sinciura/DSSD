`timescale 1ns/1ns

module test_read_module;

reg rclk, Rrst_n, rempty;

reg [15:0]rdata;

wire rinc;

read_module dut(rdata,rempty,rclk,Rrst_n,rinc);

initial rclk =0;
always #10 rclk=~rclk;

initial rdata = 15'd10;
always #40 rdata=rdata+1;

initial
begin

Rrst_n = 0;
rempty =0;
#30;

Rrst_n = 1;
#60;

rempty = 1;
#60

rempty = 0;
#400
$stop;

end
endmodule

