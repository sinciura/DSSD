module write_module(

input wclk, wrst_n,

output reg winc,

output reg [15:0]wdata,

input wfull);

parameter [2:0] 

reset = 3'b000,
idle = 3'b001,
s2 = 3'b010,
s3 = 3'b011,
s4 = 3'b100;

reg [2:0]state, next;

wire paritat;

assign paritat = wdata[0]^wdata[1]^wdata[2]^wdata[3]^wdata[4]^wdata[5]^wdata[6]^wdata[7]^wdata[8]^wdata[9]^wdata[10]^wdata[11]^wdata[12]^wdata[13]^wdata[14]^wdata[15];

always @(posedge wclk or negedge wrst_n) begin

if (!wrst_n) state <= reset;

else state <= next;

end

always @(winc,wdata,wrst_n,wfull,state,next,paritat) begin

case(state)

reset : begin

winc = 0;
wdata = 0;

if (wrst_n == 1) next = s2;
else next = reset;

end

idle: begin

winc = 0;
wdata = wdata;

if (wfull == 1) next <= idle;
else next <= s2;

end

s2: begin

if(wfull == 0) begin

winc = 0;
wdata = wdata + 16'd1;
next = s3;

end

else next = idle;

end

s3 : begin

if(wfull == 0) begin

winc = 0;

if(paritat == 1) next = s4;

if(paritat == 0) next = s2;

end

else next = idle;

end

s4: begin //escriure a la memoria

winc = 1; //enviar a la fifo.
next = s2;

end

endcase
end
endmodule














 




