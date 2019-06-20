module crc16 (
clk_6M, rstz,
crc16_datin, datvalid_p,
loadini_p, shift_in, shift_out,
crc16ini,
//
crc16rem

);

input clk_6M, rstz;
input crc16_datin, datvalid_p;
input loadini_p, shift_in, shift_out;
input [7:0] crc16ini;
//
output [15:0] crc16rem;

wire crc16out;
reg [15:0] crc16rem;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     crc16rem <= 0;
  else if (loadini_p)
     crc16rem <= {8'b0,crc16ini[7:0]};
  else if (shift_in)          //shift in
    begin   
      if (datvalid_p)
        crc16rem <= {crc16rem[14:12], crc16out^crc16rem[11], crc16rem[10:5], crc16out^crc16rem[4], crc16rem[3:0], crc16out};
    end                
  else if (shift_out)   //shift out
    begin
      if (datvalid_p)
         crc16rem <= {crc16rem[14:0], 1'b0};
    end                
end

assign crc16out = crc16_datin ^ crc16rem[15] ;

endmodule