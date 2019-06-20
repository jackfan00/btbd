module fec32(
clk_6M, rstz,
loadini_p, shift_in, shift_out, datvalid_p,
fec32_datin,
fec32rem,
syndrome

);

input clk_6M, rstz;
input loadini_p, shift_in, shift_out, datvalid_p;
input fec32_datin;
output [4:0] fec32rem;
output [4:0] syndrome;         

// fec32 encode
wire fec32remout_fb;
reg [4:0] fec32rem;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec32rem <= 0;
  else if (loadini_p)
     fec32rem <= 0;
  else if (shift_in & datvalid_p)
    begin
     fec32rem <= {fec32remout_fb^fec32rem[3], fec32rem[2], fec32remout_fb^fec32rem[1], fec32rem[0], fec32remout_fb};
    end                
  else if (shift_out & datvalid_p)
    begin
     fec32rem <= {fec32rem[3:0], 1'b0};
    end                
end

assign fec32remout_fb = fec32rem[4] ^ fec32_datin;

//
reg [4:0] syndrome;         
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     syndrome <= 0;
  else if (loadini_p)
     syndrome <= 0;
  else if (shift_in & loadini_p) // & (!pk_encode))
     syndrome <= {fec32remout_fb^fec32rem[3], fec32rem[2], fec32remout_fb^fec32rem[1], fec32rem[0], fec32remout_fb};
end

endmodule