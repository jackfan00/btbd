module hec(
clk_6M, rstz,
loadini_p,
hecremini,
shift_in, shift_out, datvalid_p, hec_datin,
hecrem
);

input clk_6M, rstz;
input loadini_p;
input [7:0] hecremini;
input shift_in, shift_out, datvalid_p, hec_datin;
output [7:0] hecrem;

wire hecremout;
reg [7:0] hecrem;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     hecrem <= 0;
  else if (loadini_p)
     hecrem <= hecremini[7:0];
  else if (shift_in & datvalid_p)
    begin
     hecrem <= {hecremout^hecrem[6], hecrem[5], hecremout^hecrem[4], hecrem[3], hecrem[2], hecremout^hecrem[1], hecremout^hecrem[0], hecremout};
    end                
  else if (shift_out & datvalid_p)
    begin
     hecrem <= {hecrem[6:0], 1'b0};
    end                
end

assign hecremout = hec_datin ^ hecrem[7] ;

endmodule