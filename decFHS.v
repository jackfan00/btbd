module decFHS (
clk_6M, rstz,
dec_py_st_p, daten, dec_py_period, py_datvalid_p, pydecdatout,
rxfhs,
Pbits,
LAP,
EIR,
SR,
SP,
UAP,
NAP,
CoD,
LT_ADDR,
CLK,
PSM
);

input clk_6M, rstz;
input dec_py_st_p, daten, dec_py_period, py_datvalid_p, pydecdatout;
input rxfhs;
output [33:0] Pbits;
output [23:0] LAP;
output EIR;
output [1:0] SR;
output [1:0] SP;
output [7:0] UAP;
output [15:0] NAP;
output [23:0] CoD;
output [2:0] LT_ADDR;
output [27:2] CLK;
output [2:0] PSM;


//
reg [12:0] bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     bitcount <= 0;
  else if (dec_py_st_p)
     bitcount <= 11'd0;
  else if (daten & dec_py_period & py_datvalid_p)
     bitcount <= bitcount + 1'b1 ;
end

////////reg [33:0] pydecdatout_d;
////////always @(posedge clk_6M or negedge rstz)
////////begin
////////  if (!rstz)
////////     pydecdatout_d <= 0;
////////  else if (py_datvalid_p)
////////     pydecdatout_d <= {pydecdatout,pydecdatout_d[33:1]};
////////end

reg [33:0] Pbits;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     Pbits <= 0;
  else if (py_datvalid_p & bitcount<=12'd33 & daten & dec_py_period & rxfhs)
     Pbits <= {pydecdatout,Pbits[33:1]};
end

reg [23:0] LAP;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     LAP <= 0;
  else if (py_datvalid_p & bitcount>12'd33 & bitcount<=12'd57 & daten & dec_py_period & rxfhs)  //33+24
     LAP <= {pydecdatout,LAP[23:1]};
end

reg EIR;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     EIR <= 0;
  else if (py_datvalid_p & bitcount==12'd58 & daten & dec_py_period & rxfhs)  //33+24+1
     EIR <= {pydecdatout};
end

reg [1:0] SR;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     SR <= 0;
  else if (py_datvalid_p & bitcount>12'd59 & bitcount<=12'd61 & daten & dec_py_period & rxfhs)  //33+24+1+1+2
     SR <= {pydecdatout,SR[1]};
end

reg [1:0] SP;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     SP <= 0;
  else if (py_datvalid_p & bitcount>12'd61 & bitcount<=12'd63 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2
     SP <= {pydecdatout,SP[1]};
end

reg [7:0] UAP;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     UAP <= 0;
  else if (py_datvalid_p & bitcount>12'd63 & bitcount<=12'd71 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8
     UAP <= {pydecdatout,UAP[7:1]};
end

reg [15:0] NAP;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     NAP <= 0;
  else if (py_datvalid_p & bitcount>12'd71 & bitcount<=12'd87 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8+16
     NAP <= {pydecdatout,NAP[15:1]};
end

reg [23:0] CoD;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     CoD <= 0;
  else if (py_datvalid_p & bitcount>12'd87 & bitcount<=12'd111 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8+16+24
     CoD <= {pydecdatout,CoD[23:1]};
end

reg [2:0] LT_ADDR;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     LT_ADDR <= 0;
  else if (py_datvalid_p & bitcount>12'd111 & bitcount<=12'd114 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8+16+24+3
     LT_ADDR <= {pydecdatout,LT_ADDR[2:1]};
end

reg [27:2] CLK;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     CLK <= 0;
  else if (py_datvalid_p & bitcount>12'd114 & bitcount<=12'd140 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8+16+24+3+26
     CLK <= {pydecdatout,CLK[27:3]};
end

reg [2:0] PSM;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     PSM <= 0;
  else if (py_datvalid_p & bitcount>12'd140 & bitcount<=12'd143 & daten & dec_py_period & rxfhs)  //33+24+1+1+2+2+8+16+24+3+26+3
     PSM <= {pydecdatout,PSM[2:1]};
end

endmodule
