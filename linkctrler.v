//
// 2019/04/26
// Link Controller : core5.1 Spec Chapter 8
//
module linkctrler(
clk_6M, rstz, p_1us, s_tslot_p,
regi_pagetruncated,
regi_InquiryEnable_oneshot,  regi_PageEnable_oneshot, 
regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot,
Master_TX_tslot_endp, Master_RX_tslot_endp, m_tslot_p, m_half_tslot_p, ms_tslot_p,
CLKE, CLK, CLKN,
Slave_TX_tslot_endp, Slave_RX_tslot_endp,
m_page_uncerWindow, m_conns_uncerWindow, s_conns_uncerWindow, spr_correWin,
regi_extendedInquiryResponse,
Inquiry_Complete_status,
regi_Tpsinterval, regi_Tpswindow,
regi_Tisinterval, regi_Tiswindow,
regi_correthreshold,
regi_psinterlace, regi_isinterlace,
regi_syncword_DAC,
regi_syncword_GIAC, regi_syncword_CAC,
regi_inquiryDIAC, regi_syncword_DIAC,
sync_in,
regi_Npage,
regi_slave_SRmode,
regi_Tsco,
regi_scolink_num,
regi_Page_Timeout,
regi_isMaxRand,
regi_PageScanEnable_oneshot, regi_PageScanCancel_oneshot, 
regi_InquiryScanEnable_oneshot, regi_InquiryScanCancel_oneshot,
rxispoll, lt_addressed,
regi_Ninquiry,
regi_Inquiry_Length, regi_Extended_Inquiry_Length,
dec_iscanEIR,
regi_isMaster,
extendslot,
m_acltxcmd_p, s_acltxcmd_p,
//
ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns,
ps_corre_sync_p, conns_corre_sync_p,
pageAB_2Npage_count,
counter_isFHS,
Atrain,
ps_N_incr_p,
prs_clock_frozen, prm_clock_frozen,
tx_packet_st_p,
psrxfhs, inquiryrxfhs,
rx_trailer_st_p,
pagetxfhs, istxfhs, connsnewmaster, connsnewslave,
pk_encode,
pssyncCLK_p,
conns_1stslot,
pk_encode_1stslot,
ms_txcmd_p

);

input clk_6M, rstz, p_1us, s_tslot_p;
input regi_pagetruncated;
input regi_InquiryEnable_oneshot,  regi_PageEnable_oneshot;
input regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot;
input Master_TX_tslot_endp, Master_RX_tslot_endp, m_tslot_p, m_half_tslot_p, ms_tslot_p;
input [27:0] CLKE, CLK, CLKN;
input Slave_TX_tslot_endp, Slave_RX_tslot_endp;
input m_page_uncerWindow, m_conns_uncerWindow, s_conns_uncerWindow, spr_correWin;
input regi_extendedInquiryResponse;
input Inquiry_Complete_status;
input [15:0] regi_Tpsinterval, regi_Tpswindow;
input [15:0] regi_Tisinterval, regi_Tiswindow;
input [5:0] regi_correthreshold;
input regi_psinterlace, regi_isinterlace;
input [63:0] regi_syncword_DAC, regi_syncword_GIAC, regi_syncword_CAC, regi_syncword_DIAC;
input regi_inquiryDIAC;
input [63:0] sync_in;
input [9:0] regi_Npage;
input [1:0] regi_slave_SRmode;
input [2:0] regi_Tsco;
input [1:0] regi_scolink_num;
input [15:0] regi_Page_Timeout;
input [9:0] regi_isMaxRand;
input regi_PageScanEnable_oneshot, regi_PageScanCancel_oneshot;
input regi_InquiryScanEnable_oneshot, regi_InquiryScanCancel_oneshot;
input rxispoll, lt_addressed;
input [9:0] regi_Ninquiry;
input [15:0] regi_Inquiry_Length, regi_Extended_Inquiry_Length;
input dec_iscanEIR;
input regi_isMaster;
input extendslot;
input m_acltxcmd_p, s_acltxcmd_p;
//
output ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns;
output ps_corre_sync_p, conns_corre_sync_p;
output [3:0] pageAB_2Npage_count;
output [4:0] counter_isFHS;
output Atrain;
output ps_N_incr_p;
output prs_clock_frozen, prm_clock_frozen;
output tx_packet_st_p;
output psrxfhs, inquiryrxfhs;
output rx_trailer_st_p;
output pagetxfhs, istxfhs, connsnewmaster, connsnewslave;
output pk_encode;
output pssyncCLK_p;
output conns_1stslot;
output pk_encode_1stslot;
output ms_txcmd_p;

wire is_randwin_endp;
wire PageScanWindow, InquiryScanWindow;
wire corre_threshold;
wire ps_corre_threshold    =  corre_threshold ;//& ps;
wire p_corre_threshold     =  corre_threshold ;//& page;
wire is_corre_threshold    =  corre_threshold ;//& is;
wire conns_corre_threshold =  corre_threshold ;//& conns;
wire corr_tslotdly_endp, corr_halftslotdly_endp;
wire ps_corr_halftslotdly_endp = corr_halftslotdly_endp;
wire pageTO_status, inquiryTO;
wire is_corr_4tslotdly_endp, is_corr_3tslotdly_endp, is_corr_2tslotdly_endp, is_corr_tslotdly_endp;
wire ps_pagerespTO, page_pagerespTO;
wire pstxid;
wire PageScanWindow1more;
wire psrxfhs;
wire istxfhs_tslotdly_endp, istxfhs_tslot2dly_endp, isextfhs_tslotdly_endp;
reg m_corre, s_corre;
wire newconnectionTO;
wire inqExt_tslotdly_endp, inqExt_tslot2dly_endp;
reg m_txcmd, s_txcmd;
reg m_conns_1stslot, s_conns_1stslot;


parameter STANDBY_STATE=5'd0, Inquiry_STATE=5'd1, InquiryScan_STATE=5'd2, Page_STATE=5'd3, PageScan_STATE=5'd4,
          CONNECTIONActive_STATE=5'd5, CONNECTIONHold_STATE=5'd6, CONNECTIONSniff_STATE=5'd7, CONNECTIONPark_STATE=5'd8,
          PageMasterResp_STATE=5'd9, PageMasterResp_rxid_STATE=5'd10, PageMasterResp_txfhs_STATE=5'd11,
          PageMasterResp_rxackfhs_STATE=5'd12, PageScan1more_STATE=5'd13, PageSlaveResp_txid_STATE=5'd14,
          PageSlaveResp_rxfhs_STATE=5'd15, PageSlaveResp_ackfhs_STATE=5'd16, InquiryScanRand_STATE=5'd17,
          InquiryScantxFHS_STATE=5'd18, InquiryScantxExtIRP_STATE=5'd19, CONNECTIONnewslave_STATE=5'd20, CONNECTIONnewmaster_STATE=5'd21,
          InquiryEIR_STATE=5'd22, Inquiryintern_STATE=5'd23, Pagetmp_STATE=5'd24, PageSlaveResp_rxfhsdone_STATE=5'd25,
          CONNECTIONnewslave_ackpoll_STATE=5'd26, Inquiryrsp_STATE=5'd27;

reg [4:0] cs, ns, pre_state_ff, pre_state;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
      cs <= 0;
      pre_state_ff <= 0;
    end 
  else if (p_1us)
    begin
      cs <= ns;
      pre_state_ff <= pre_state;
    end
end

always @*
begin
  ns = cs;
  pre_state = pre_state_ff;
  case(cs)
    STANDBY_STATE:
      begin
        pre_state = STANDBY_STATE;
        if (regi_InquiryEnable_oneshot)
          ns = Inquiry_STATE;
//        else if (is_randwin_endp)
//          ns = InquiryScanRand_STATE;
        else if (InquiryScanWindow)  //regi_InquiryScanEnable_oneshot)
          ns = InquiryScan_STATE;
        else if (regi_PageEnable_oneshot)
          ns = Page_STATE;
        else if (PageScanWindow)  //regi_PageScanEnable_oneshot)
          ns = PageScan_STATE;
      end  
    CONNECTIONnewslave_STATE:
      begin
        if (s_corre & rxispoll & s_tslot_p & lt_addressed)   //receive master send poll packet
          ns = CONNECTIONnewslave_ackpoll_STATE;
        else if (newconnectionTO)
          ns = PageScan_STATE;
      end
    CONNECTIONnewslave_ackpoll_STATE:
      begin
        if (s_tslot_p)                 //send master null packet for ack poll
          ns = CONNECTIONActive_STATE;
      end
    CONNECTIONnewmaster_STATE:
      begin
        if (m_corre & m_tslot_p)
          ns = CONNECTIONActive_STATE;        //receive slave ack poll
        else if (newconnectionTO)
          ns = Page_STATE;
      end
    CONNECTIONActive_STATE:
      begin
        pre_state = CONNECTIONActive_STATE;
        if (regi_ConnHold_oneshot)
          ns = CONNECTIONHold_STATE;
        else if (regi_ConnSniff_oneshot)
          ns = CONNECTIONSniff_STATE;
        else if (regi_ConnPark_oneshot)
          ns = CONNECTIONPark_STATE;
        else if (regi_InquiryEnable_oneshot)
          ns = Inquiry_STATE;
//        else if (is_randwin_endp)
//          ns = InquiryScanRand_STATE;
        else if (InquiryScanWindow)  //regi_InquiryScanEnable_oneshot)
          ns = InquiryScan_STATE;
        else if (regi_PageEnable_oneshot)
          ns = Page_STATE;
        else if (PageScanWindow)  //regi_PageScanEnable_oneshot)
          ns = PageScan_STATE;
      end  
    CONNECTIONHold_STATE:
      begin
        pre_state = CONNECTIONHold_STATE;
        if (regi_InquiryEnable_oneshot)
          ns = Inquiry_STATE;
//        else if (is_randwin_endp)
//          ns = InquiryScanRand_STATE;
        else if (InquiryScanWindow)  //regi_InquiryScanEnable_oneshot)
          ns = InquiryScan_STATE;
        else if (regi_PageEnable_oneshot)
          ns = Page_STATE;
        else if (PageScanWindow)  //regi_PageScanEnable_oneshot)
          ns = PageScan_STATE;        
      end
    Page_STATE:   //wait for slave pageescan response  
      begin
        if (pageTO_status)
          ns = pre_state_ff;
        else if (p_corre_threshold & CLKE[1])
          ns = Pagetmp_STATE; //PageMasterResp_STATE;
      end  
    Pagetmp_STATE:   //tmp state for transit to PageMasterResp_txfhs_STATE
      begin
        if (m_tslot_p)
          ns = PageMasterResp_txfhs_STATE; //PageMasterResp_STATE;
      end  
    PageMasterResp_txfhs_STATE:  //master send FHS to slave
      begin        
        if (pageTO_status)
          ns = pre_state_ff;
        else if (!CLKE[1] & m_tslot_p)
          ns = PageMasterResp_rxackfhs_STATE;
      end  
    PageMasterResp_rxackfhs_STATE:  //wait for ackFHS(ID) from slave 
      begin        
        if (pageTO_status)
          ns = pre_state_ff;
        else if (m_corre & CLKE[1] & m_tslot_p)
          ns = CONNECTIONnewmaster_STATE;
        else if (page_pagerespTO)
          ns = Page_STATE;
        else if (m_tslot_p)
          ns = PageMasterResp_txfhs_STATE;
      end  
    PageScan_STATE:
      begin
        if (!PageScanWindow)
          ns = pre_state_ff;
        else if (ps_corre_threshold & corr_tslotdly_endp)
          ns = PageSlaveResp_txid_STATE; 
      end  
    PageScan1more_STATE:
      begin        
        if (!PageScanWindow1more)
          ns = pre_state_ff;
        else if (ps_corre_threshold & corr_tslotdly_endp)   
          ns = PageSlaveResp_txid_STATE;
      end  
    PageSlaveResp_txid_STATE:   // send ID to Master
      begin        
        if (ps_corr_halftslotdly_endp)  //delay 312.5us - 10us
          ns = PageSlaveResp_rxfhs_STATE;
      end  
    PageSlaveResp_rxfhs_STATE:   // wait for master's fhs response until pagerespTO and update Slave CLK offset
      begin        
        if (ps_pagerespTO)
          ns = PageScan1more_STATE;
        else if (ps_corre_threshold ) //& s_tslot_p) 
          ns = PageSlaveResp_rxfhsdone_STATE;
      end  
    PageSlaveResp_rxfhsdone_STATE:   // tmp for transit to PageSlaveResp_ackfhs_STATE
      begin        
        if (s_tslot_p) 
          ns = PageSlaveResp_ackfhs_STATE;
      end  
    PageSlaveResp_ackfhs_STATE:  // send ID to master, should already sync to master CLK
      begin        
        if (s_tslot_p)      //ps_corr_tslotdly_endp)
          ns = CONNECTIONnewslave_STATE;
      end  
    InquiryScan_STATE:    
      begin
        if (!InquiryScanWindow)
          ns = pre_state_ff;
        else if (is_corre_threshold & corr_tslotdly_endp)  // back to, wait for rand timeslot, to avoid collision issue
          ns = InquiryScantxFHS_STATE;
      end  
    InquiryScanRand_STATE:    
      begin
        if (is_randwin_endp)
          ns = pre_state_ff;
      end  
    InquiryScantxFHS_STATE:    //send FHS to master
      begin
        if (regi_extendedInquiryResponse & istxfhs_tslot2dly_endp)
          ns = InquiryScantxExtIRP_STATE;
        else if (!regi_extendedInquiryResponse & istxfhs_tslotdly_endp)
          ns = InquiryScanRand_STATE;
      end  
    InquiryScantxExtIRP_STATE:    
      begin
        if (isextfhs_tslotdly_endp)
          ns = InquiryScanRand_STATE;
      end  
    Inquiry_STATE:
      begin
        if (inquiryTO)
          ns = pre_state_ff;
        else if (corre_threshold)
          ns = Inquiryrsp_STATE;
//        else if (corre_threshold & (!dec_iscanEIR) & corr_tslotdly_endp)
//          ns = Inquiryintern_STATE;
//        else if (corre_threshold & (dec_iscanEIR) & corr_tslotdly_endp)
//          ns = InquiryEIR_STATE;
      end  
    Inquiryrsp_STATE:
      begin
        if ((!dec_iscanEIR) & corr_tslotdly_endp)
          ns = Inquiryintern_STATE;
        else if (dec_iscanEIR & corr_tslotdly_endp)
          ns = InquiryEIR_STATE;
      end  
    InquiryEIR_STATE:  //receive extended FHS
      begin
        if (inqExt_tslot2dly_endp)
          ns = Inquiryintern_STATE;
      end  
    Inquiryintern_STATE:
      begin
        if (m_tslot_p)
          ns = Inquiry_STATE;
      end  
        
  endcase
end

//
reg [10:0] is_counter_1us;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     is_counter_1us <= 0;
// InquiryEIR_STATE delay count
  else if (cs==Inquiryrsp_STATE & dec_iscanEIR & corr_tslotdly_endp)
     is_counter_1us <= 0;
  else if (p_1us & (cs==InquiryEIR_STATE))
     is_counter_1us <= is_counter_1us + 1'b1;
// InquiryScan delay count
  else if (regi_extendedInquiryResponse & istxfhs_tslot2dly_endp & (cs==InquiryScantxFHS_STATE))
     is_counter_1us <= 0;     
  else if (is_corre_threshold & corr_tslotdly_endp & (cs==InquiryScan_STATE))
     is_counter_1us <= 0;     
  else if (p_1us & (cs==InquiryScantxFHS_STATE || cs==InquiryScantxExtIRP_STATE))
     is_counter_1us <= is_counter_1us + 1'b1;
end
assign istxfhs_tslotdly_endp  = (is_counter_1us==11'd624)  & p_1us & (cs==InquiryScantxFHS_STATE);
assign istxfhs_tslot2dly_endp = (is_counter_1us==11'd1249) & p_1us & (cs==InquiryScantxFHS_STATE);
assign isextfhs_tslotdly_endp = (is_counter_1us==11'd624)  & p_1us & (cs==InquiryScantxExtIRP_STATE);
assign inqExt_tslotdly_endp   = (is_counter_1us==11'd624)  & p_1us & (cs==InquiryEIR_STATE) ;
assign inqExt_tslot2dly_endp  = (is_counter_1us==11'd1249) & p_1us & (cs==InquiryEIR_STATE) ;
//
reg PageScanEnable;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     PageScanEnable <= 1'b0;
  else if (regi_PageScanEnable_oneshot)
     PageScanEnable <= 1'b1;
  else if ((cs==PageSlaveResp_ackfhs_STATE & s_tslot_p) || regi_PageScanCancel_oneshot)
     PageScanEnable <= 1'b0;
end

reg InquiryScanEnable;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     InquiryScanEnable <= 1'b0;
  else if (regi_InquiryScanEnable_oneshot)
     InquiryScanEnable <= 1'b1;
  else if (regi_InquiryScanCancel_oneshot)
     InquiryScanEnable <= 1'b0;
end


reg is_randwin;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     is_randwin <= 1'b0;
  else if (is_randwin_endp)
     is_randwin <= 1'b0;
  else if (cs==InquiryScanRand_STATE)
     is_randwin <=  1'b1;
end

reg [9:0] randcnt;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     randcnt <= 10'b0;
  else if (!is_randwin)
     randcnt <=  10'b0;
  else if (is_randwin & p_1us)
     randcnt <= randcnt+1'b1;
end

assign is_randwin_endp = (randcnt == regi_isMaxRand) & p_1us & is_randwin;

reg [4:0] counter_isFHS;
wire isFHS_en = regi_isMaster ? ( dec_iscanEIR ? (cs==InquiryEIR_STATE) & inqExt_tslot2dly_endp : 
                                                                 (cs==Inquiryrsp_STATE) & corr_tslotdly_endp ) : 
                regi_extendedInquiryResponse ? (cs==InquiryScantxExtIRP_STATE) & isextfhs_tslotdly_endp :
                                               (cs==InquiryScantxFHS_STATE) & istxfhs_tslotdly_endp;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     counter_isFHS <= 0;
    end 
  else if (isFHS_en)
    begin
     counter_isFHS <= counter_isFHS+1'b1;
    end 
end

wire corre_trgp;
assign ps_corre_sync_p = corre_trgp & ps;
assign conns_corre_sync_p = corre_trgp & conns;

//
reg prs_clock_frozen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     prs_clock_frozen <= 0;
    end 
  else if (!PageScanWindow)
    begin
     prs_clock_frozen <= 0;
    end     
  else if (cs==PageSlaveResp_ackfhs_STATE && s_tslot_p)
    begin
     prs_clock_frozen <= 1'b0;
    end 
  else if (ps & ps_corre_sync_p) 
    begin
     prs_clock_frozen <= 1'b1;
    end 
end


reg prm_clock_frozen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     prm_clock_frozen <= 0;
    end 
  else if (pageTO_status)
    begin
     prm_clock_frozen <= 0;
    end        
  else if (cs==PageMasterResp_rxackfhs_STATE && m_corre & CLKE[1] & m_tslot_p)
    begin
     prm_clock_frozen <= 1'b0;
    end 
  else if (page && p_corre_threshold ) //& CLKE[1] & m_tslot_p)
    begin
     prm_clock_frozen <= 1'b1;
    end 
end


reg [10:0] ps_FHS_count_1us;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     ps_FHS_count_1us <= 0;
    end 
  else if ( cs==PageSlaveResp_txid_STATE && ps_corr_halftslotdly_endp)
     ps_FHS_count_1us <= 0;
  else if ( cs==PageSlaveResp_rxfhs_STATE && (ps_FHS_count_1us==11'd1249) && p_1us)
     ps_FHS_count_1us <= 0;  
  else if ( cs==PageSlaveResp_ackfhs_STATE && (ps_FHS_count_1us==11'd1249) && p_1us)
     ps_FHS_count_1us <= 0;  
  else if ((cs==PageSlaveResp_rxfhs_STATE | cs==PageSlaveResp_ackfhs_STATE) & p_1us)
    begin
     ps_FHS_count_1us <= ps_FHS_count_1us + 1'b1;
    end 
  else if (p_1us)
     ps_FHS_count_1us <= 0;
end

//assign ps_N_incr_p = (ps_FHS_count_1us==11'd1249 & p_1us) ;
assign ps_N_incr_p = (CLKN[1] & s_tslot_p & spr) ;
//
// newconnectionTO
//
wire s_wpoll = cs == CONNECTIONnewslave_STATE;
wire newc_p = regi_isMaster ? connsnewmaster & (!m_corre) & m_tslot_p & CLK[1] : s_wpoll & CLK[1] & s_tslot_p;
reg [4:0] newconnectionTO_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     newconnectionTO_count <= 0;
  else if (regi_isMaster & (!connsnewmaster))
     newconnectionTO_count <= 0;
  else if ((!regi_isMaster) & s_wpoll)
     newconnectionTO_count <= 0;
  else if (newc_p)
     newconnectionTO_count <= newconnectionTO_count + 1'b1;
end

assign newconnectionTO = newconnectionTO_count > 5'd15;

//
ps_ctrl ps_ctrl_u(
.clk_6M                   (clk_6M                   ), 
.rstz                     (rstz                     ), 
.tslot_p                  (s_tslot_p                ), 
.p_1us                    (p_1us                    ),
.regi_Tpsinterval         (regi_Tpsinterval         ), 
.regi_Tpswindow           (regi_Tpswindow           ),
.regi_psinterlace         (regi_psinterlace         ),
.PageScanEnable           (PageScanEnable           ),
.ps                       (ps                       ),
.gips                     (gips                     ),
.spr                      (spr                      ),
.pstxid                   (pstxid                   ), 
.ps_corr_halftslotdly_endp(ps_corr_halftslotdly_endp),
//
.PageScanWindow           (PageScanWindow           ),
.pagerespTO               (ps_pagerespTO            ),
.PageScanWindow1more      (PageScanWindow1more      )
);



page_ctrl page_ctrl_u(
.clk_6M              (clk_6M              ), 
.rstz                (rstz                ),
.p_corre_threshold   (m_corre             ), 
.mpr                 (mpr                 ),
.CLKE                (CLKE                ),
.page                (page                ), 
.Master_TX_tslot_endp(Master_TX_tslot_endp),
.Master_RX_tslot_endp(Master_RX_tslot_endp),
.m_tslot_p           (m_tslot_p           ),
.regi_Npage          (regi_Npage          ),
.regi_slave_SRmode   (regi_slave_SRmode   ),
.regi_Tsco           (regi_Tsco           ),
.regi_scolink_num    (regi_scolink_num    ),
.regi_Page_Timeout   (regi_Page_Timeout   ),
//
.pageAB_2Npage_count (pageAB_2Npage_count ),
.pageTO_status_p     (pageTO_status       ),
.Atrain              (Atrain              ),
.pagerespTO          (page_pagerespTO     )
);

wire p_correWin = m_page_uncerWindow ;
wire mpr_correWin = m_page_uncerWindow ;
wire page_rx_endp = CLKE[1] & m_tslot_p;

//
is_ctrl is_ctrl_u(
.clk_6M                (clk_6M                ), 
.rstz                  (rstz                  ), 
.tslot_p               (s_tslot_p             ), 
.p_1us                 (p_1us                 ),
.regi_Tsco             (regi_Tsco             ),
.regi_scolink_num      (regi_scolink_num      ),
.regi_Tisinterval      (regi_Tisinterval      ), 
.regi_Tiswindow        (regi_Tiswindow        ),
.regi_isinterlace      (regi_isinterlace      ),
.regi_InquiryScanEnable(InquiryScanEnable     ),
.is                    (is                    ), 
.giis                  (giis                  ),
//               
.InquiryScanWindow     (InquiryScanWindow     )
);

inquiry_ctrl inquiry_ctrl_u(
.clk_6M                      (clk_6M                      ), 
.rstz                        (rstz                        ),
.inquiry                     (inquiry                     ),  
.Master_RX_tslot_endp        (Master_RX_tslot_endp        ), 
.m_tslot_p                   (m_tslot_p                   ),
.regi_Ninquiry               (regi_Ninquiry               ),
.regi_Inquiry_Length         (regi_Inquiry_Length         ), 
.regi_Extended_Inquiry_Length(regi_Extended_Inquiry_Length),
//                          (//                          )
//.inquiryAB_2Ninquiry_count   (inquiryAB_2Ninquiry_count   ),
.inquiryTO_status_p          (inquiryTO                   ),
.Atrain                      (inquiryAtrain               )
);

//////////////////////correlator_is correlator_is_u(
//////////////////////.clk_6M                 (clk_6M                   ), 
//////////////////////.rstz                   (rstz                     ), 
//////////////////////.p_1us                  (p_1us                    ),
//////////////////////.correWindow            (InquiryScanWindow        ),
//////////////////////.sync_in                (sync_in                  ), 
//////////////////////.ref_sync               (regi_syncword_GIAC       ),
//////////////////////.regi_correthreshold    (regi_correthreshold      ),
////////////////////////
//////////////////////.ps_corre_threshold     (is_corre_threshold       ),
//////////////////////.corre_tslotdly_endp    (is_corr_tslotdly_endp    ), 
//////////////////////.corre_halftslotdly_endp(is_corr_halftslotdly_endp),
//////////////////////.corr_2tslotdly_endp    (is_corr_2tslotdly_endp   ),
//////////////////////.corr_3tslotdly_endp    (is_corr_3tslotdly_endp   ), 
//////////////////////.corr_4tslotdly_endp    (is_corr_4tslotdly_endp   ),
//////////////////////.pscorr_trgp            (is_corre_sync_p          )
//////////////////////);
//////////////////////
//////////////////////correlator_page correlator_page_u(
//////////////////////.clk_6M                 (clk_6M                  ), 
//////////////////////.rstz                   (rstz                    ), 
//////////////////////.p_1us                  (p_1us                   ),
//////////////////////.page_rx_endp           (page_rx_endp            ),
//////////////////////.correWindow            (p_correWin              ),
//////////////////////.sync_in                (sync_in                 ), 
//////////////////////.ref_sync               (regi_syncword_DAC       ),
//////////////////////.regi_correthreshold    (regi_correthreshold     ),
////////////////////////
//////////////////////.ps_corre_threshold     (p_corre_threshold       )
////////////////////////.corre_tslotdly_endp    (p_corr_tslotdly_endp    ), 
////////////////////////.corre_halftslotdly_endp(p_corr_halftslotdly_endp),
////////////////////////.pscorr_trgp            (p_corre_sync_p          )
//////////////////////);
//////////////////////
//////////////////////correlator_ps correlator_ps_u(
//////////////////////.clk_6M                 (clk_6M                   ), 
//////////////////////.rstz                   (rstz                     ), 
//////////////////////.p_1us                  (p_1us                    ),
//////////////////////.ps                     (ps                       ), 
//////////////////////.s_tslot_p              (s_tslot_p                ),
//////////////////////.correWindow            (PageScanWindow           ),
//////////////////////.psrxfhs                (psrxfhs                  ),
//////////////////////.sync_in                (sync_in                  ), 
//////////////////////.ref_sync               (regi_syncword_DAC        ),
//////////////////////.regi_correthreshold    (regi_correthreshold      ),
////////////////////////
//////////////////////.ps_corre_threshold     (ps_corre_threshold       ),
//////////////////////.corre_tslotdly_endp    (ps_corr_tslotdly_endp    ), 
//////////////////////.corre_halftslotdly_endp(ps_corr_halftslotdly_endp),
//////////////////////.pscorr_trgp            (ps_corre_sync_p          ),
//////////////////////.rx_trailer_st_p        (rx_trailer_st_p          )
//////////////////////);
//////////////////////
//////////////////////correlator_conns correlator_conns_u(
//////////////////////.clk_6M                 (clk_6M                   ), 
//////////////////////.rstz                   (rstz                     ), 
//////////////////////.p_1us                  (p_1us                    ),
//////////////////////.ps                     (ps                       ), 
//////////////////////.ms_tslot_p             (ms_tslot_p               ),
//////////////////////.correWindow            (ConnsWindow              ),
//////////////////////.sync_in                (sync_in                  ), 
//////////////////////.ref_sync               (regi_syncword_CAC        ),
//////////////////////.regi_correthreshold    (regi_correthreshold      ),
////////////////////////
//////////////////////.ps_corre_threshold     (conns_corre_threshold    ),
//////////////////////.pscorr_trgp            (conns_corre_sync_p       ),
//////////////////////.rx_trailer_st_p        (rx_trailer_st_p          )
//////////////////////);
//////////////////////
//

wire ConnsWindow = regi_isMaster ? m_conns_uncerWindow : s_conns_uncerWindow;  
wire [63:0] ref_sync = PageScanWindow | page | mpr | spr | ps ? regi_syncword_DAC :
                       InquiryScanWindow | inquiry ? (regi_inquiryDIAC ? regi_syncword_DIAC : regi_syncword_GIAC) :
                       conns ? regi_syncword_CAC : 64'b0 ;
                       
wire correWindow = page ? p_correWin :
                   ps ? PageScanWindow :
                   spr ? spr_correWin :
                   mpr ? mpr_correWin :
                   is ? InquiryScanWindow :
                   conns | inquiry ? ConnsWindow : 1'b0;
//
correlator correlator_u(
.clk_6M                 (clk_6M                   ), 
.rstz                   (rstz                     ), 
.p_1us                  (p_1us                    ),
.correWindow            (correWindow              ),
.sync_in                (sync_in                  ), 
.ref_sync               (ref_sync                 ),
.regi_correthreshold    (regi_correthreshold      ),
//
.corre_threshold        (corre_threshold          ),
.corre_tslotdly_endp    (corr_tslotdly_endp       ), 
.corre_halftslotdly_endp(corr_halftslotdly_endp   ),
.corre_trgp             (corre_trgp               ),
.rx_trailer_st_p        (raw_rx_trailer_st_p      )
);

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     m_corre <= 0;
    end 
  else if (corre_trgp)
    begin
     m_corre <= 1'b1;
    end 
  else if (m_tslot_p)
    begin
     m_corre <= 1'b0;
    end 
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     s_corre <= 0;
    end 
  else if (corre_trgp)
    begin
     s_corre <= 1'b1;
    end 
  else if (s_tslot_p)
    begin
     s_corre <= 1'b0;
    end 
end

// exclude ID packet
assign rx_trailer_st_p = raw_rx_trailer_st_p & (spr | conns | inquiry);
//

assign page = (cs == Page_STATE) | (cs == Pagetmp_STATE) ;

assign ps =  (cs==PageScan_STATE) | (cs==PageScan1more_STATE);

assign inquiry =  (cs==Inquiry_STATE);

assign is = (cs==InquiryScan_STATE);

assign gips = ps & regi_psinterlace & (regi_Tpsinterval >= {regi_Tpswindow,1'b0});

assign giis = is & regi_isinterlace & (regi_Tisinterval >= {regi_Tiswindow,1'b0});

assign mpr = (cs==PageMasterResp_txfhs_STATE) | (cs==PageMasterResp_rxackfhs_STATE) ;

assign spr = (cs==PageSlaveResp_txid_STATE) | (cs==PageSlaveResp_rxfhs_STATE) | (cs==PageSlaveResp_rxfhsdone_STATE) | (cs==PageSlaveResp_ackfhs_STATE);

assign ir = (cs==InquiryScantxFHS_STATE) | (cs==InquiryScantxExtIRP_STATE) | (cs==Inquiryrsp_STATE) | (cs==InquiryEIR_STATE);

assign pagetxfhs = (cs==PageMasterResp_txfhs_STATE);

assign istxfhs = (cs==InquiryScantxFHS_STATE);

assign connsnewmaster = (cs==CONNECTIONnewmaster_STATE);
assign connsnewslave = (cs==CONNECTIONnewslave_STATE) | (cs==CONNECTIONnewslave_ackpoll_STATE);

assign conns = (cs==CONNECTIONActive_STATE) | connsnewslave | connsnewmaster;

assign pstxid = (cs==PageSlaveResp_txid_STATE);

assign psrxfhs = (cs==PageSlaveResp_rxfhs_STATE) | (cs==PageSlaveResp_rxfhsdone_STATE);

assign inquiryrxfhs = (cs==Inquiryrsp_STATE);

assign pssyncCLK_p = (cs==PageSlaveResp_ackfhs_STATE) & s_tslot_p;
//

assign tx_packet_st_p = 

                       page & m_corre    ?  CLKE[1] & m_tslot_p & (!regi_pagetruncated)  :   //1st FHS
                       
                       page & (!m_corre) ? (!CLKE[1] & m_half_tslot_p) | (CLKE[1] & m_tslot_p ) :   //page, ID, 

                     inquiry ? (!CLK[1]  & m_half_tslot_p) | (CLK[1]  & m_tslot_p ) :   //inquiry, ID
                     
                     ps  ? ps_corre_threshold & corr_tslotdly_endp :  // slave page response, ID         
                     cs==PageSlaveResp_rxfhsdone_STATE ? s_tslot_p :   // slave page response, ID
                     cs==InquiryScan_STATE ? is_corre_threshold & corr_tslotdly_endp :  // inquiryScan response, FHS
                     cs==InquiryScantxFHS_STATE ? regi_extendedInquiryResponse & istxfhs_tslot2dly_endp : //  inquiryScan extended response
                     cs==PageMasterResp_rxackfhs_STATE & m_corre    ?  CLKE[1] & m_tslot_p :  // master send first poll
                     cs==PageMasterResp_rxackfhs_STATE & (!m_corre) ?  CLKE[1] & m_tslot_p & (!regi_pagetruncated) :  // re-transmit FHS ,master page response, 
                     cs==CONNECTIONnewmaster_STATE ? (!m_corre) & CLKE[1] & m_tslot_p :   // master send retry poll
                     cs==CONNECTIONnewslave_STATE  ? s_corre & rxispoll & s_tslot_p :   // slave send null to ack poll
                     1'b0;
                      
wire pk_encode_1stslot = page | mpr ? !CLKE[1] :
                   spr ? (cs==PageSlaveResp_txid_STATE) | (cs==PageSlaveResp_ackfhs_STATE) :
                   //conns ? (regi_isMaster ? !CLK[1] : CLK[1]) :
                   connsnewmaster | connsnewslave ? (regi_isMaster ? !CLK[1] : CLK[1]) :
                   conns ? (regi_isMaster ? m_conns_1stslot : s_conns_1stslot) :
                   inquiry ? !CLKN[1] :
                   cs==InquiryScantxFHS_STATE ? 1'b1 :
                   cs==InquiryScantxExtIRP_STATE ? 1'b1 : 
                   1'b0;
                   
// txcmd_p : 
//  Master : issue by mcu for new acl packet transmit,or by reserved-timeslot for sco packet transmit,  
//  Slave  : issue in slave-to-master slot 
//
wire m_scotxcmd_p = 1'b0; //for tmp
wire s_scotxcmd_p = 1'b0; //for tmp


assign ms_txcmd_p = regi_isMaster ? m_acltxcmd_p | m_scotxcmd_p : s_acltxcmd_p | s_scotxcmd_p;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     m_txcmd <= 0;
  else if (ms_txcmd_p)
     m_txcmd <= 1'b1;
  else if (m_tslot_p & CLK[1])
     m_txcmd <= 1'b0;
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     m_conns_1stslot <= 0;
  else if (m_txcmd & m_tslot_p & CLK[1])
     m_conns_1stslot <= 1'b1;
  else if (m_tslot_p)
     m_conns_1stslot <= 1'b0;
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s_txcmd <= 0;
  else if (ms_txcmd_p)
     s_txcmd <= 1'b1;
  else if (s_tslot_p & (!CLK[1]))
     s_txcmd <= 1'b0;
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s_conns_1stslot <= 0;
  else if (s_txcmd & s_tslot_p & (!CLK[1]))
     s_conns_1stslot <= 1'b1;
  else if (s_tslot_p)
     s_conns_1stslot <= 1'b0;
end
 
assign conns_1stslot = conns & (regi_isMaster ? m_conns_1stslot : s_conns_1stslot);
assign pk_encode = pk_encode_1stslot | extendslot;

endmodule
