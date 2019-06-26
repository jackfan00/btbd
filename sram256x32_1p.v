module sram256x32_1p (
A,
DIN,
WE, CS, CLK,
DOUT
);

input [7:0] A;
input [31:0] DIN;
input WE, CS, CLK;
output [31:0] DOUT;

//
reg [31:0] Mem[0:255];
//
reg [7:0] A_i;
always @(posedge CLK)
begin
  if (CS)
     A_i <= A ;
end

always @(posedge CLK)
begin
  if (CS & WE)
     Mem[A] <= DIN ;
end
//

assign #3 DOUT = Mem[A_i];

endmodule
