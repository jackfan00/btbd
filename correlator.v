module correlator(
clk_6M, rstz, p_1us,
pk_encode, conns,
correWindow,
sync_in, ref_sync,
regi_correthreshold,
//
corre_threshold,
corre_tslotdly_endp, corre_halftslotdly_endp,
corre_trgp,
rx_trailer_st_p,
rxCAC, prerx_trans,
psrxfhs_corwin

);

input clk_6M, rstz, p_1us;
input pk_encode, conns;
input correWindow;
input [63:0] sync_in, ref_sync;
input [5:0] regi_correthreshold;
//
output corre_threshold;
output corre_tslotdly_endp, corre_halftslotdly_endp;
output corre_trgp;
output rx_trailer_st_p;
output rxCAC, prerx_trans;
output psrxfhs_corwin;

wire [63:0] corrbits = ref_sync!=64'b0 ? ~(sync_in ^ ref_sync) : 64'b0;

integer i;
reg [6:0] pscorres;
always @*
begin
  pscorres = 7'd0;
  for (i=0;i<64;i=i+1)
    begin
      pscorres = pscorres + corrbits[i];
    end
end


reg corre_threshold;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     corre_threshold <= 0;
  else if ((pscorres > regi_correthreshold) && correWindow & p_1us)
     corre_threshold <= 1'b1 ;
  else if (corre_tslotdly_endp)
     corre_threshold <= 1'b0 ;
end

reg corre_trgp;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     corre_trgp <= 1'b0;
  else if ((pscorres > regi_correthreshold) &&  correWindow & p_1us)
     corre_trgp <= 1'b1 ;
  else if (p_1us)
     corre_trgp <= 1'b0 ;
end

assign rx_trailer_st_p = (pscorres > regi_correthreshold) &&  correWindow & p_1us;


wire tslotdly_endp;
reg [9:0] counter_1us;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     counter_1us <= 0;
  else if (corre_trgp & p_1us)  
     counter_1us <= 10'h47;     //4(premable) + 64 (syncword) + some-delay-pipe
  else if (tslotdly_endp)  
     counter_1us <= 0;
  else if (p_1us)
     counter_1us <= counter_1us + 1'b1;
end
assign tslotdly_endp = (counter_1us == 10'd624) & p_1us;   
wire halftslotdly_endp = (counter_1us == 10'd312) & p_1us;   

//
assign corre_tslotdly_endp =  tslotdly_endp ;
assign corre_halftslotdly_endp = halftslotdly_endp ;   

//
reg rxCAC;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxCAC <= 1'b0;
  else if (corre_trgp & p_1us & !pk_encode & conns)  
     rxCAC <= 1'b1;     
  else if (pk_encode)  
     rxCAC <= 1'b0;
end

reg prerx_trans;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     prerx_trans <= 1'b0;
  else if (rxCAC & p_1us & pk_encode & conns)  
     prerx_trans <= 1'b1;     
  else if (!pk_encode)  
     prerx_trans <= 1'b0;
end

// pstxid correWindow
reg psrxfhs_corwin;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     psrxfhs_corwin <= 1'b0;
  else if ((counter_1us == 10'd302) & p_1us)  
     psrxfhs_corwin <= 1'b1;     
  else if ((counter_1us == 10'd390) & p_1us)  // just wider window
     psrxfhs_corwin <= 1'b0;
end
endmodule
