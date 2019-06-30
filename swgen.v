//
// sync word generate
// Vol2 Part B, sec 6.3.3, Figure 6.5
//
module swgen(
clk_6M, rstz,
regi_scwdLAP,
regi_cal_scwd_p,
//
pbits,
pbitsready,
syncword

);

input clk_6M, rstz;
input [23:0] regi_scwdLAP;
input regi_cal_scwd_p;
//
output [33:0] pbits;
output pbitsready;
output [63:0] syncword;

wire inb;
reg [4:0] bitcnt;
reg shift_in;
wire [32:0] inbxor;

wire [34:0] gD = 35'o260534236651; //left-most bit is g34, right-most bit is g0

wire [63:0] pD      = 64'h3f2a33dd69b121c1;  //lest-most bis is p0, right-most bit is p63
wire [63:0] pDprime = 64'h83848d96bbcc54fc;  //lest-most bis is p63, right-most bit is p0

wire [5:0] append_lap = regi_scwdLAP[23] ? 6'b010011 : 6'b101100 ;//6'b110010 : 6'b001101 ;

wire [29:0] x = {append_lap, regi_scwdLAP[23:0]};
wire [29:0] x_bar = {append_lap^pDprime[63:58], regi_scwdLAP[23:0]^pDprime[57:34]};

//
// x_bar mod gD
//
reg [33:0] pbits_lfsr;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pbits_lfsr <= 0;
  else if (regi_cal_scwd_p)
     pbits_lfsr <= 0;
  else if (shift_in)
     pbits_lfsr <= {pbits_lfsr[32:0]^inbxor[32:0], inb};           
end

assign inbxor = {33{inb}} & gD[33:1];
assign inb = x_bar[5'd29-bitcnt] ^ pbits_lfsr[33] ;
//
//
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     bitcnt <= 0;
  else if (regi_cal_scwd_p | !shift_in)
     bitcnt <= 0;
  else if (shift_in)
     bitcnt <= bitcnt+1'b1;           
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     shift_in <= 0;
  else if (regi_cal_scwd_p)
     shift_in <= 1'b1;
  else if (bitcnt==5'd29)
     shift_in <= 1'b0;           
end
reg valid_p;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     valid_p <= 0;
  else 
     valid_p <= bitcnt==5'd29;           
end

//
wire [34:0] dd1 = pbits_lfsr ^ pD[63:30];
//
reg [33:0] pbits;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pbits <= 0;
  else if (valid_p)
     pbits <= pbits_lfsr^pDprime[33:0];           
end
reg pbitsready;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pbitsready <= 0;
  else if (regi_cal_scwd_p)
     pbitsready <= 0;
  else if (valid_p)
     pbitsready <= 1'b1;           
end

assign syncword = {pbits[0],pbits[1],pbits[2],pbits[3],pbits[4],pbits[5],pbits[6],pbits[7],pbits[8],pbits[9],
                   pbits[10],pbits[11],pbits[12],pbits[13],pbits[14],pbits[15],pbits[16],pbits[17],pbits[18],pbits[19],
                   pbits[20],pbits[21],pbits[22],pbits[23],pbits[24],pbits[25],pbits[26],pbits[27],pbits[28],pbits[29],
                   pbits[30],pbits[31],pbits[32],pbits[33],
                   x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],
                   x[10],x[11],x[12],x[13],x[14],x[15],x[16],x[17],x[18],x[19],
                   x[20],x[21],x[22],x[23],x[24],x[25],x[26],x[27],x[28],x[29]
                  };

endmodule
