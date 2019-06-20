module correlator_page(
clk_6M, rstz, p_1us,
page_rx_endp,
correWindow,
sync_in, ref_sync,
regi_correthreshold,
ps_corre_threshold
//corre_tslotdly_endp, corre_halftslotdly_endp,
//corr_2tslotdly_endp, corr_3tslotdly_endp, corr_4tslotdly_endp,
//pscorr_trgp

);

input clk_6M, rstz, p_1us;
input page_rx_endp;
input correWindow;
input [63:0] sync_in, ref_sync;
input [5:0] regi_correthreshold;
//
output ps_corre_threshold;
//output corre_tslotdly_endp, corre_halftslotdly_endp;
//output corr_2tslotdly_endp, corr_3tslotdly_endp, corr_4tslotdly_endp;
//output pscorr_trgp;

wire corre_tslotdly_endp;
reg [2:0] counter_tslot;

wire [63:0] corrbits = ~(sync_in ^ ref_sync);

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

wire [6:0] pscorres_ff=7'd0;


reg ps_corre_threshold;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     ps_corre_threshold <= 0;
  else if ((pscorres > regi_correthreshold) && (pscorres > pscorres_ff) & correWindow & p_1us)
     ps_corre_threshold <= 1'b1 ;
  else if (corre_tslotdly_endp)
     ps_corre_threshold <= 1'b0 ;
end

reg pscorr_trgp;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pscorr_trgp <= 1'b0;
//  else if (pscorr_trgp & p_1us)
//     pscorr_trgp <= 1'b0;
  else if ((pscorres > regi_correthreshold) && (pscorres > pscorres_ff) & correWindow & p_1us)
     pscorr_trgp <= 1'b1 ;
  else if (p_1us)
     pscorr_trgp <= 1'b0 ;
end

//wire tslotdly_endp;
//reg [9:0] counter_1us;
//always @(posedge clk_6M or negedge rstz)
//begin
//  if (!rstz)
//     counter_1us <= 0;
//  else if (pscorr_trgp & p_1us)  
//     counter_1us <= 10'h47;     //4(premable) + 64 (syncword) + some-delay-pipe
//  else if (tslotdly_endp)  
//     counter_1us <= 0;
//  else if (p_1us)
//     counter_1us <= counter_1us + 1'b1;
//end
//assign tslotdly_endp = (counter_1us == 10'd624) & p_1us;   
//wire halftslotdly_endp = (counter_1us == 10'd302) & p_1us;   //312 - 10us
//
//
//always @(posedge clk_6M or negedge rstz)
//begin
//  if (!rstz)
//     counter_tslot <= 0;
//  else if (pscorr_trgp & p_1us)
//     counter_tslot <= 0;
//  else if (tslotdly_endp)
//     counter_tslot <= counter_tslot + 1'b1;
//end

//assign corr_4tslotdly_endp = tslotdly_endp && (counter_tslot==3'd3);   
//assign corr_3tslotdly_endp = tslotdly_endp && (counter_tslot==3'd2);   
//assign corr_2tslotdly_endp = tslotdly_endp && (counter_tslot==3'd1);   
assign corre_tslotdly_endp = page_rx_endp; //tslotdly_endp ;   
//assign corre_halftslotdly_endp = halftslotdly_endp ;   //312 - 10us

endmodule