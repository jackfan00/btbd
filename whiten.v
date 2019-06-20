module whiten(
clk_6M, rstz,
whiteningEnable,
loadini_p, datvalid_p,
whitening_ini,
whitening
);

input clk_6M, rstz;
input whiteningEnable;
input loadini_p, datvalid_p;
input [6:0] whitening_ini;
output [6:0] whitening;

reg [6:0] whitening;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     whitening <= 0;
  else if (!whiteningEnable)
     whitening <= 0;
  else if (loadini_p)
     whitening <= whitening_ini;
//header+payload
  else if (datvalid_p)
    begin
     whitening <= {whitening[5:4],whitening[3]^whitening[6],whitening[2:0],whitening[6]};
    end                
end

endmodule