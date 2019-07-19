//
// 2019/05/09
// Link Controller : core5.1 Spec Chapter 8.3.1 Page Scan substate
//

module ps_ctrl(
clk_6M, rstz, tslot_p, p_1us,
regi_Tpsinterval, regi_Tpswindow,
regi_psinterlace,
PageScanEnable,
ps, gips, spr,
pstxid, ps_corr_halftslotdly_endp,
//
PageScanWindow,
pagerespTO,
PageScanWindow1more,
PageScanWindow_endp
);

input clk_6M, rstz, tslot_p, p_1us;
input [15:0] regi_Tpsinterval, regi_Tpswindow;
input regi_psinterlace;
input PageScanEnable;
input ps, gips, spr;
input pstxid, ps_corr_halftslotdly_endp;
//
output PageScanWindow;
output pagerespTO;
output PageScanWindow1more;
output PageScanWindow_endp;

reg [15:0] pswindow_counter_tslot;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pswindow_counter_tslot <= 0;
  else if (!PageScanEnable)
     pswindow_counter_tslot <= 0;
  else if (pswindow_counter_tslot==regi_Tpsinterval)
     pswindow_counter_tslot <= 0;
//  else if (pagerespTO)
//     pswindow_counter_tslot <= 0;
  else if (tslot_p)
     pswindow_counter_tslot <= pswindow_counter_tslot + 1'b1;
end

wire NorPageScanWindow = (pswindow_counter_tslot < regi_Tpswindow);

wire InterPageScanWindow = (pswindow_counter_tslot < {regi_Tpswindow,1'b0}) ;

assign PageScanWindow_raw =  regi_psinterlace & (regi_Tpsinterval >= {regi_Tpswindow,1'b0}) ? InterPageScanWindow : NorPageScanWindow;

wire PageScanWindow_t = PageScanWindow_raw & PageScanEnable;  //(ps | gips) ;
//
reg PageScanWindow_d1;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     PageScanWindow_d1 <= 0;
  else 
     PageScanWindow_d1 <= PageScanWindow_t;
end

assign PageScanWindow_endp = !PageScanWindow_t & PageScanWindow_d1;
assign PageScanWindow = PageScanWindow_d1;

reg [3:0] pagerespTO_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pagerespTO_count <= 0;
  else if ((pstxid & ps_corr_halftslotdly_endp) | (!spr))
     pagerespTO_count <= 0;
  else if (tslot_p & spr)
     pagerespTO_count <= pagerespTO_count + 1'b1;
end

assign pagerespTO = (pagerespTO_count==4'h8) & tslot_p;

assign PageScanWindow1more = NorPageScanWindow;

endmodule