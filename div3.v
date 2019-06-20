module div3(
clk_6M, rstz,
en_p,
len,
out
);

input clk_6M, rstz;
input en_p;
input [11:0] len;
output [10:0] out;

reg counten;
reg [11:0] bitcount;
reg [2:0] count;
wire sym8psken;

reg [10:0] out;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     out <= 0;
  else if (gfsk_endp & p_ius)
     out <= 0;
  else if (sym8psken)
     out <= out + 1'b1 ;
end

assign sym8psken = count==3'd2 | bitcount==(len-1'b1);  // add rem
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     count <= 0;
  else if (sym8psken)
     count <= 0;
  else if (counten)
     count <= count + 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     bitcount <= 0;
  else if (bitcount==(len-1'b1))
     bitcount <= 0;
  else if (counten)
     bitcount <= bitcount + 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     counten <= 0;
  else if (bitcount==(len-1'b1))
     counten <= 0;
  else if (en_p)
     counten <= 1'b1 ;
end

endmodule