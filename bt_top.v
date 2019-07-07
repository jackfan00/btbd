module bt_top(
clk_6M, rstz,
regi_chgbufcmd_p,
txbsmacl_addr, txbsmsco_addr,
txbsmacl_din, txbsmsco_din,
txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs,
rxbsmacl_addr, rxbsmsco_addr,
rxbsmacl_cs, rxbsmsco_cs,
rxbsm_valid_p,
regi_txcmd_p, regi_flushcmd_p, regi_LMPcmdfg,
regi_esti_offset, regi_time_base_offset, regi_slave_offset,
regi_interlace_offset, regi_page_k_nudge,
//regi_AFH_N,
regi_isMaster,
regi_scwdLAP, regi_cal_scwd_p,
regi_GIAC_BD_ADDR_UAP, regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
regi_GIAC_BD_ADDR_LAP, regi_paged_BD_ADDR_LAP, regi_master_BD_ADDR_LAP, regi_my_BD_ADDR_LAP,
regi_PageScanEnable_oneshot, regi_PageScanCancel_oneshot, 
regi_InquiryScanEnable_oneshot, regi_InquiryScanCancel_oneshot,
regi_InquiryEnable_oneshot,  regi_PageEnable_oneshot, 
regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot,
regi_Tpsinterval, regi_Tpswindow,
regi_Tisinterval, regi_Tiswindow,
regi_correthreshold, regi_pagetruncated,
regi_psinterlace, regi_isinterlace,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_Npage,
regi_slave_SRmode,
regi_scolink_num,
regi_Page_Timeout,
regi_m_uncerWinSize, regi_s_uncerWinSize,
regi_AFH_mode,
regi_AFH_channel_map,
regi_AFH_N,
regi_isMaxRand,
regi_extendedInquiryResponse,
regi_Tsco,
regi_LT_ADDR, regi_mylt_address,
regi_packet_type,
//regi_FLOW, regi_ARQN, regi_SEQN,
regi_payloadlen,
regi_FHS_LT_ADDR,
regi_myClass,
regi_my_BD_ADDR_NAP,
regi_SR,
regi_EIR,
regi_my_syncword,
regi_txwhitening, regi_rxwhitening,
regi_Ninquiry,
regi_Inquiry_Length, regi_Extended_Inquiry_Length,
rxbit,
//
txbit,
fk,
regi_fhsslave_offset,
bsm_dout,
regi_aclrxbufempty,
fhs_LT_ADDR,
fhs_Pbits,
fhs_LAP,
regi_srcFLOW,
regi_txARQN,
regi_dec_pk_type,
regi_dec_lt_addr,
regi_dec_flow, regi_dec_arqn, regi_SEQN_old,
regi_dec_hecgood

);


input clk_6M, rstz;
input regi_chgbufcmd_p;
input [7:0] txbsmacl_addr, txbsmsco_addr;
input [31:0] txbsmacl_din, txbsmsco_din;
input txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs;
input [7:0] rxbsmacl_addr, rxbsmsco_addr;
input rxbsmacl_cs, rxbsmsco_cs;
input rxbsm_valid_p;
input regi_txcmd_p, regi_flushcmd_p, regi_LMPcmdfg;
input [27:0] regi_esti_offset, regi_time_base_offset, regi_slave_offset;
input [4:0] regi_interlace_offset, regi_page_k_nudge;
//input [6:0] regi_AFH_N;
input regi_isMaster;
input [23:0] regi_scwdLAP;
input regi_cal_scwd_p;
input [7:0] regi_GIAC_BD_ADDR_UAP, regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input [23:0] regi_GIAC_BD_ADDR_LAP, regi_paged_BD_ADDR_LAP, regi_master_BD_ADDR_LAP, regi_my_BD_ADDR_LAP;
input regi_PageScanEnable_oneshot, regi_PageScanCancel_oneshot;
input regi_InquiryScanEnable_oneshot, regi_InquiryScanCancel_oneshot;
input regi_InquiryEnable_oneshot,  regi_PageEnable_oneshot;
input regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot;
input [15:0] regi_Tpsinterval, regi_Tpswindow;
input [15:0] regi_Tisinterval, regi_Tiswindow;
input [5:0] regi_correthreshold;
input regi_pagetruncated;
input regi_psinterlace, regi_isinterlace;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [9:0] regi_Npage;
input [1:0] regi_slave_SRmode;
input [1:0] regi_scolink_num;
input [15:0] regi_Page_Timeout;
input [8:0] regi_m_uncerWinSize;
input [8:0] regi_s_uncerWinSize;
input regi_AFH_mode;
input [79:0] regi_AFH_channel_map;
input [6:0] regi_AFH_N;
input [9:0] regi_isMaxRand;
input regi_extendedInquiryResponse;
input [2:0] regi_Tsco;
input [2:0] regi_LT_ADDR, regi_mylt_address;
input [3:0] regi_packet_type;
//input regi_FLOW, regi_ARQN, regi_SEQN;
input [9:0] regi_payloadlen;
input [2:0] regi_FHS_LT_ADDR;
input [23:0] regi_myClass;
input [15:0] regi_my_BD_ADDR_NAP;
input [1:0] regi_SR;
input regi_EIR;
input [33:0] regi_my_syncword;
input regi_txwhitening, regi_rxwhitening;
input [9:0] regi_Ninquiry;
input [15:0] regi_Inquiry_Length, regi_Extended_Inquiry_Length;
input rxbit;
//
output txbit;
output [6:0] fk;
output [27:2] regi_fhsslave_offset;
output [31:0] bsm_dout ;
output regi_aclrxbufempty;
output [2:0]  fhs_LT_ADDR;
output [33:0] fhs_Pbits;
output [23:0] fhs_LAP;
output [7:0] regi_srcFLOW, regi_txARQN;
output [3:0] regi_dec_pk_type;
output [2:0] regi_dec_lt_addr;
output [7:0] regi_dec_flow, regi_dec_arqn, regi_SEQN_old;
output regi_dec_hecgood;


wire rxispoll;
wire ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns;
wire Atrain;
wire        fhs_EIR;
wire [1:0]  fhs_SR;
wire [1:0]  fhs_SP;
wire [7:0]  fhs_UAP;
wire [15:0] fhs_NAP;
wire [23:0] fhs_CoD;

wire [27:2] fhs_CLK;
wire [2:0]  fhs_PSM;
wire s_acltxcmd_p;

wire [27:0] hop_BD_ADDR = 
                          is | giis | ir | inquiry ? {regi_GIAC_BD_ADDR_UAP[3:0], regi_GIAC_BD_ADDR_LAP}  :
                          ps | gips | spr  ? {regi_my_BD_ADDR_UAP[3:0], regi_my_BD_ADDR_LAP} : 
                          page | mpr  ? {regi_paged_BD_ADDR_UAP[3:0], regi_paged_BD_ADDR_LAP} : 
                                             {regi_master_BD_ADDR_UAP[3:0], regi_master_BD_ADDR_LAP} ;  //conns

wire [27:0] CLKN_master, CLK_master, CLKE_master;
wire [27:0] CLKN_slave, CLK_slave;
wire [4:0] counter_isFHS;
wire [3:0] pageAB_2Npage_count;

wire [4:0] Xprm, Xir, Xprs;
wire [4:0] X, C;
wire [4:0] A;
wire [3:0] B;
wire [8:0] D;
wire [6:0] E, F, Fprime;
wire Y1;
wire [5:0] Y2;
wire [79:0] regi_AFH_channel_map;
wire [6:0] regi_AFH_N;
wire [6:0] fk;
wire [63:0] syncinword;
wire [6:0] whitening;
wire py_period, daten, py_datvalid_p;
wire pssyncCLK_p;
wire lt_addressed;
wire pstxid, psrxfhs, psrxfhs_succ_p;


bluetoothclk bluetoothclk_u(
.clk_6M               (clk_6M               ), 
.rstz                 (rstz                 ),
.page                 (page                 ),
.mpr                  (mpr                  ),
.regi_esti_offset     (regi_esti_offset     ), 
.regi_time_base_offset(regi_time_base_offset), 
.regi_slave_offset    (regi_slave_offset    ),
.regi_m_uncerWinSize  (regi_m_uncerWinSize  ),
.regi_s_uncerWinSize  (regi_s_uncerWinSize  ),
.conns_corre_sync_p   (conns_corre_sync_p   ), 
.ps_corre_sync_p      (ps_corre_sync_p      ),
.pssyncCLK_p          (pssyncCLK_p          ),
.fhs_CLK              (fhs_CLK              ),
//
.CLKN_master          (CLKN_master          ), 
.CLK_master           (CLK_master           ), 
.CLKE_master          (CLKE_master          ),
.CLKN_slave           (CLKN_slave           ), 
.CLK_slave            (CLK_slave            ),
.Master_TX_tslot_endp (Master_TX_tslot_endp ), 
.Master_RX_tslot_endp (Master_RX_tslot_endp ),
.Slave_TX_tslot_endp  (Slave_TX_tslot_endp  ), 
.Slave_RX_tslot_endp  (Slave_RX_tslot_endp  ),
.m_half_tslot_p       (m_half_tslot_p       ), 
.s_half_tslot_p       (s_half_tslot_p       ),
.m_tslot_p            (m_tslot_p            ), 
.s_tslot_p            (s_tslot_p            ), 
.p_1us                (p_1us                ),
.p_05us               (p_05us               ),
.p_033us              (p_033us              ),
.m_conns_uncerWindow  (m_conns_uncerWindow  ), 
.m_page_uncerWindow   (m_page_uncerWindow   ),
.spr_correWin         (spr_correWin         ), 
.s_conns_uncerWindow  (s_conns_uncerWindow  ),
.regi_fhsslave_offset (regi_fhsslave_offset )

);

wire [27:0] CLK = regi_isMaster ? CLK_master : CLK_slave;
wire [27:0] CLKN = regi_isMaster ? CLKN_master : CLKN_slave;
wire [27:0] CLKE = CLKE_master;
wire ms_tslot_p = regi_isMaster ? m_tslot_p : s_tslot_p;


hopctrlwd hopctrlwd_u(
.clk_6M               (clk_6M               ), 
.rstz                 (rstz                 ), 
.p_033us              (p_033us              ),
.psrxfhs_succ_p       (psrxfhs_succ_p       ),
.psrxfhs              (psrxfhs              ),
.pstxid               (pstxid               ),
.m_tslot_p            (m_tslot_p            ),
.ms_tslot_p           (ms_tslot_p           ),
.ps_N_incr_p          (ps_N_incr_p          ),
.pageAB_2Npage_count  (pageAB_2Npage_count  ), 
.Atrain               (Atrain               ),
.regi_interlace_offset(regi_interlace_offset),
.regi_page_k_nudge    (regi_page_k_nudge    ),
.regi_AFH_mode        (regi_AFH_mode        ),
.regi_AFH_N           (regi_AFH_N           ),
.ps                   (ps                   ), 
.gips                 (gips                 ), 
.is                   (is                   ), 
.giis                 (giis                 ), 
.page                 (page                 ), 
.inquiry              (inquiry              ), 
.mpr                  (mpr                  ), 
.spr                  (spr                  ), 
.ir                   (ir                   ), 
.conns                (conns                ),
.prs_clock_frozen     (prs_clock_frozen     ), 
.prm_clock_frozen     (prm_clock_frozen     ),
.CLK                  (CLK                  ), 
.CLKE                 (CLKE                 ), 
.CLKN                 (CLKN                 ), 
.BD_ADDR              (hop_BD_ADDR          ),
.counter_isFHS        (counter_isFHS        ),
//
.Xprm                 (Xprm                 ), 
.Xir                  (Xir                  ),
.Xprs                 (Xprs                 ), 
.X                    (X                    ),
.Y1                   (Y1                   ),
.Y2                   (Y2                   ),
.A                    (A                    ),
.B                    (B                    ),
.C                    (C                    ),
.D                    (D                    ),
.E                    (E                    ), 
.F                    (F                    ), 
.Fprime               (Fprime               )
);

hopkernal hopkernal_u(
//.divffclk            (divffclk            ), 
//.div_en_p            (div_en_p            ),
.rstz                (rstz                ),
.X                   (X                   ), 
.A                   (A                   ), 
.C                   (C                   ),
.B                   (B                   ),
.D                   (D                   ),
.E                   (E                   ), 
.F                   (F                   ),
.Fprime              (Fprime              ),
.Y1                  (Y1                  ),
.Y2                  (Y2                  ),
.regi_AFH_channel_map(regi_AFH_channel_map),
.regi_AFH_N          (regi_AFH_N          ),
.fk                  (fk                  )

);


linkctrler linkctrler_u(
.clk_6M                      (clk_6M                      ), 
.rstz                        (rstz                        ), 
.p_1us                       (p_1us                       ), 
.s_tslot_p                   (s_tslot_p                   ),
.regi_LMPcmdfg               (regi_LMPcmdfg               ),
.regi_pagetruncated          (regi_pagetruncated          ),
.regi_InquiryEnable_oneshot  (regi_InquiryEnable_oneshot  ), 
.regi_PageEnable_oneshot     (regi_PageEnable_oneshot     ), 
.regi_ConnHold_oneshot       (regi_ConnHold_oneshot       ), 
.regi_ConnSniff_oneshot      (regi_ConnSniff_oneshot      ), 
.regi_ConnPark_oneshot       (regi_ConnPark_oneshot       ),
.Master_TX_tslot_endp        (Master_TX_tslot_endp        ), 
.Master_RX_tslot_endp        (Master_RX_tslot_endp        ),
.m_tslot_p                   (m_tslot_p                   ),
.m_half_tslot_p              (m_half_tslot_p              ),
.ms_tslot_p                  (ms_tslot_p                  ),
.CLKE                        (CLKE                        ),
.CLK                         (CLK                         ),
.CLKN                        (CLKN                        ),
.Slave_TX_tslot_endp         (Slave_TX_tslot_endp         ),
.Slave_RX_tslot_endp         (Slave_RX_tslot_endp         ),
.m_page_uncerWindow          (m_page_uncerWindow          ),
.m_conns_uncerWindow         (m_conns_uncerWindow         ),
.s_conns_uncerWindow         (s_conns_uncerWindow         ),
.spr_correWin                (spr_correWin                ), 
.regi_extendedInquiryResponse(regi_extendedInquiryResponse),
.Inquiry_Complete_status     (Inquiry_Complete_status     ),
.regi_Tpsinterval            (regi_Tpsinterval            ), 
.regi_Tpswindow              (regi_Tpswindow              ),
.regi_Tisinterval            (regi_Tisinterval            ), 
.regi_Tiswindow              (regi_Tiswindow              ),
.regi_correthreshold         (regi_correthreshold         ),
.regi_psinterlace            (regi_psinterlace            ),
.regi_isinterlace            (regi_isinterlace            ),
.regi_syncword_DAC           (regi_syncword_DAC           ),
.regi_syncword_GIAC          (regi_syncword_GIAC          ),
.regi_syncword_CAC           (regi_syncword_CAC           ),
.regi_inquiryDIAC            (regi_inquiryDIAC            ), 
.regi_syncword_DIAC          (regi_syncword_DIAC          ),
.sync_in                     (syncinword                  ),
.regi_Npage                  (regi_Npage                  ),
.regi_slave_SRmode           (regi_slave_SRmode           ),
.regi_Tsco                   (regi_Tsco                   ),
.regi_scolink_num            (regi_scolink_num            ),
.regi_Page_Timeout           (regi_Page_Timeout           ),
.regi_isMaxRand              (regi_isMaxRand              ),
.regi_PageScanEnable_oneshot (regi_PageScanEnable_oneshot ), 
.regi_PageScanCancel_oneshot (regi_PageScanCancel_oneshot ), 
.regi_InquiryScanEnable_oneshot (regi_InquiryScanEnable_oneshot ), 
.regi_InquiryScanCancel_oneshot (regi_InquiryScanCancel_oneshot ), 
.rxispoll                    (rxispoll                    ),
.lt_addressed                (lt_addressed                ),
.regi_Ninquiry               (regi_Ninquiry               ),
.regi_Inquiry_Length         (regi_Inquiry_Length         ), 
.regi_Extended_Inquiry_Length(regi_Extended_Inquiry_Length),
.dec_iscanEIR                (fhs_EIR                     ),
.regi_isMaster               (regi_isMaster               ),
.extendslot                  (extendslot                  ),
//.m_acltxcmd_p                (regi_txcmd_p                ),
.regi_txcmd_p                (regi_txcmd_p                ),
.s_acltxcmd_p                (s_acltxcmd_p                ),
//
//
.ps                        (ps                        ), 
.gips                      (gips                      ), 
.is                        (is                        ), 
.giis                      (giis                      ), 
.page                      (page                      ), 
.inquiry                   (inquiry                   ), 
.mpr                       (mpr                       ), 
.spr                       (spr                       ), 
.ir                        (ir                        ), 
.conns                     (conns                     ),
.ps_corre_sync_p           (ps_corre_sync_p           ),
.conns_corre_sync_p        (conns_corre_sync_p        ),
.pageAB_2Npage_count       (pageAB_2Npage_count       ),
.counter_isFHS             (counter_isFHS             ),
.Atrain                    (Atrain                    ),
.ps_N_incr_p               (ps_N_incr_p               ),
.prs_clock_frozen          (prs_clock_frozen          ),
.prm_clock_frozen          (prm_clock_frozen          ),
.tx_packet_st_p            (tx_packet_st_p            ),
.psrxfhs                   (psrxfhs                   ),
.inquiryrxfhs              (inquiryrxfhs              ), 
.rx_trailer_st_p           (rx_trailer_st_p           ),
.pagetxfhs                 (pagetxfhs                 ), 
.istxfhs                   (istxfhs                   ),
.connsnewmaster            (connsnewmaster            ),
.connsnewslave             (connsnewslave             ),
.pk_encode                 (pk_encode                 ),
.pssyncCLK_p               (pssyncCLK_p               ),
.conns_1stslot             (conns_1stslot             ),
.pk_encode_1stslot         (pk_encode_1stslot         ),
.ms_txcmd_p                (ms_txcmd_p                ),
.rxCAC                     (rxCAC                     ), 
.prerx_trans               (prerx_trans               ),
.LMP_c_slot                (LMP_c_slot                ),
.pstxid                    (pstxid                    ),
.psrxfhs_succ_p            (psrxfhs_succ_p            )

);

//for tmp
wire txis_BRmode = 1'b1;
wire txis_eSCO   = 1'b0;
wire txis_SCO    = 1'b0;
wire txis_ACL    = 1'b1;
//for tmp
wire rxis_BRmode = 1'b1;
wire rxis_eSCO   = 1'b0;
wire rxis_SCO    = 1'b0;
wire rxis_ACL    = 1'b1;

wire is_BRmode = pk_encode ? txis_BRmode : rxis_BRmode;
wire is_eSCO   = pk_encode ? txis_eSCO   : rxis_eSCO;
wire is_SCO    = pk_encode ? txis_SCO    : rxis_SCO;
wire is_ACL    = pk_encode ? txis_ACL    : rxis_ACL;


/////////////////////////////txallbit txallbit_u(
/////////////////////////////.clk_6M                 (clk_6M                 ), 
/////////////////////////////.rstz                   (rstz                   ), 
/////////////////////////////.p_1us                  (p_1us                  ),
/////////////////////////////.p_05us                 (p_05us                 ),
/////////////////////////////.p_033us                (p_033us                ),
/////////////////////////////.pagetxfhs              (pagetxfhs              ), 
/////////////////////////////.connsnewmaster         (connsnewmaster         ),
/////////////////////////////.page                   (page                   ), 
/////////////////////////////.inquiry                (inquiry                ), 
/////////////////////////////.conns                  (conns                  ), 
/////////////////////////////.ps                     (ps                     ), 
/////////////////////////////.mpr                    (mpr                    ), 
/////////////////////////////.spr                    (spr                    ),
/////////////////////////////.ir                     (ir                     ),
/////////////////////////////.tx_packet_st_p         (tx_packet_st_p         ),
/////////////////////////////.regi_txwhitening       (regi_txwhitening       ),
/////////////////////////////.regi_payloadlen        (regi_payloadlen        ),
/////////////////////////////.regi_inquiryDIAC       (regi_inquiryDIAC       ),
/////////////////////////////.regi_syncword_CAC      (regi_syncword_CAC      ), 
/////////////////////////////.regi_syncword_DAC      (regi_syncword_DAC      ), 
/////////////////////////////.regi_syncword_DIAC     (regi_syncword_DIAC     ), 
/////////////////////////////.regi_syncword_GIAC     (regi_syncword_GIAC     ),
/////////////////////////////.regi_LT_ADDR           (regi_LT_ADDR           ),
/////////////////////////////.regi_packet_type       (regi_packet_type       ),
/////////////////////////////.regi_FLOW              (regi_FLOW              ), 
/////////////////////////////.regi_ARQN              (regi_ARQN              ), 
/////////////////////////////.regi_SEQN              (regi_SEQN              ),
/////////////////////////////.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
/////////////////////////////.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
/////////////////////////////.Xprm                   (Xprm                   ),
/////////////////////////////.Xir                    (Xir                    ),
/////////////////////////////.Xprs                   (Xprs                   ),
/////////////////////////////.CLK                    (CLK                    ),
/////////////////////////////.regi_FHS_LT_ADDR       (regi_FHS_LT_ADDR       ),
/////////////////////////////.regi_myClass           (regi_myClass           ),
/////////////////////////////.regi_my_BD_ADDR_NAP    (regi_my_BD_ADDR_NAP    ),
/////////////////////////////.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
/////////////////////////////.regi_SR                (regi_SR                ),
/////////////////////////////.regi_EIR               (regi_EIR               ),
/////////////////////////////.regi_my_BD_ADDR_LAP    (regi_my_BD_ADDR_LAP    ),
/////////////////////////////.regi_my_syncword       (regi_my_syncword       ),
/////////////////////////////.is_BRmode              (txis_BRmode            ), 
/////////////////////////////.is_eSCO                (txis_eSCO              ), 
/////////////////////////////.is_SCO                 (txis_SCO               ), 
/////////////////////////////.is_ACL                 (txis_ACL               ),
///////////////////////////////                                              
/////////////////////////////.txbit                  (txbit                  ), 
/////////////////////////////.txbit_period           (txbit_period           )
/////////////////////////////
/////////////////////////////);


// re-sync
reg [1:0] rxbit_as;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxbit_as <= 0;
  else 
     rxbit_as <= {rxbit_as[0], rxbit};
end
reg rxbit_resync;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxbit_resync <= 0;
  else if (p_1us)
     rxbit_resync <= rxbit_as[1];
end

allbitp allbitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.regi_chgbufcmd_p       (regi_chgbufcmd_p       ),
.LMP_c_slot             (LMP_c_slot             ),
.rxCAC                  (rxCAC                  ), 
.prerx_trans            (prerx_trans            ),
.regi_txcmd_p           (regi_txcmd_p           ), 
.regi_flushcmd_p        (regi_flushcmd_p        ), 

.ms_txcmd_p             (ms_txcmd_p             ),
.p_1us                  (p_1us                  ),
.p_05us                 (p_05us                 ),
.p_033us                (p_033us                ),
.txbsmacl_addr          (txbsmacl_addr          ), 
.txbsmsco_addr          (txbsmsco_addr          ),
.txbsmacl_din           (txbsmacl_din           ), 
.txbsmsco_din           (txbsmsco_din           ),
.txbsmacl_we            (txbsmacl_we            ), 
.txbsmsco_we            (txbsmsco_we            ), 
.txbsmacl_cs            (txbsmacl_cs            ), 
.txbsmsco_cs            (txbsmsco_cs            ),
.rxbsmacl_addr          (rxbsmacl_addr          ), 
.rxbsmsco_addr          (rxbsmsco_addr          ), 
.rxbsmacl_cs            (rxbsmacl_cs            ), 
.rxbsmsco_cs            (rxbsmsco_cs            ),
.rxbsm_valid_p          (rxbsm_valid_p          ),
.s_tslot_p              (s_tslot_p              ),
.ms_tslot_p             (ms_tslot_p             ),
.pagetxfhs              (pagetxfhs              ), 
.istxfhs                (istxfhs                ),
.connsnewmaster         (connsnewmaster         ),
.connsnewslave          (connsnewslave          ),
.page                   (page                   ), 
.inquiry                (inquiry                ), 
.conns                  (conns                  ), 
.ps                     (ps                     ), 
.mpr                    (mpr                    ), 
.spr                    (spr                    ),
.ir                     (ir                     ),
.psrxfhs                (psrxfhs                ),
.inquiryrxfhs           (inquiryrxfhs           ),
.rx_trailer_st_p        (rx_trailer_st_p        ),
.tx_packet_st_p         (tx_packet_st_p         ),
.regi_isMaster          (regi_isMaster          ),
.regi_txwhitening       (regi_txwhitening       ),
.regi_rxwhitening       (regi_rxwhitening       ),
.regi_payloadlen        (regi_payloadlen        ),
.regi_inquiryDIAC       (regi_inquiryDIAC       ),
.regi_syncword_CAC      (regi_syncword_CAC      ), 
.regi_syncword_DAC      (regi_syncword_DAC      ), 
.regi_syncword_DIAC     (regi_syncword_DIAC     ), 
.regi_syncword_GIAC     (regi_syncword_GIAC     ),
.regi_LT_ADDR           (regi_LT_ADDR           ),  // packet header LT_ADDR sent by master
.regi_mylt_address      (regi_mylt_address      ),  // slave LT_ADDR, assigned by master FHS
.regi_FHS_LT_ADDR       (regi_FHS_LT_ADDR       ),  // master sent to slave LT_ADDR by FHS packet
.regi_packet_type       (regi_packet_type       ),
//.regi_FLOW              (regi_FLOW              ), 
//.regi_ARQN              (regi_ARQN              ), 
//.regi_SEQN              (regi_SEQN              ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.Xprm                   (Xprm                   ),
.Xir                    (Xir                    ),
.Xprs                   (Xprs                   ),
.CLK                    (CLK                    ),
.regi_myClass           (regi_myClass           ),
.regi_my_BD_ADDR_NAP    (regi_my_BD_ADDR_NAP    ),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.regi_SR                (regi_SR                ),
.regi_EIR               (regi_EIR               ),
.regi_my_BD_ADDR_LAP    (regi_my_BD_ADDR_LAP    ),
.regi_my_syncword       (regi_my_syncword       ),
.is_BRmode              (is_BRmode              ), 
.is_eSCO                (is_eSCO                ), 
.is_SCO                 (is_SCO                 ), 
.is_ACL                 (is_ACL                 ),
.pk_encode              (pk_encode              ),
.conns_1stslot          (conns_1stslot          ),
.pk_encode_1stslot      (pk_encode_1stslot      ),
//.bufpacketin            (bufpacketin            ),
.rxbit                  (rxbit_resync           ),
//                                              
.txbit                  (txbit                  ), 
.txbit_period           (txbit_period           ),
.rxispoll               (rxispoll               ),
.lt_addressed           (lt_addressed           ),
.fhs_Pbits              (fhs_Pbits              ),
.fhs_LAP                (fhs_LAP                ),
.fhs_EIR                (fhs_EIR                ),
.fhs_SR                 (fhs_SR                 ),
.fhs_SP                 (fhs_SP                 ),
.fhs_UAP                (fhs_UAP                ),
.fhs_NAP                (fhs_NAP                ),
.fhs_CoD                (fhs_CoD                ),
.fhs_LT_ADDR            (fhs_LT_ADDR            ),
.fhs_CLK                (fhs_CLK                ),
.fhs_PSM                (fhs_PSM                ),
//.rxpydin,
//.rxpyadr,
//.rxpydin_valid_p,
.bsm_dout                (bsm_dout              ),
.extendslot             (extendslot             ),
.s_acltxcmd_p           (s_acltxcmd_p           ),
.regi_aclrxbufempty     (regi_aclrxbufempty     ),
.srcFLOW                (regi_srcFLOW           ),
.txARQN                 (regi_txARQN            ),
.dec_pk_type            (regi_dec_pk_type       ),
.dec_lt_addr            (regi_dec_lt_addr       ),
.dec_flow               (regi_dec_flow          ), 
.dec_arqn               (regi_dec_arqn          ), 
.SEQN_old               (regi_SEQN_old          ),
.dec_hecgood            (regi_dec_hecgood       )
);

//
//syncword generation
//
wire [33:0] swgenpbits;
wire [63:0] swgenword;
swgen swgen_u(
.clk_6M         (clk_6M         ), 
.rstz           (rstz           ),
.regi_scwdLAP   (regi_scwdLAP   ),
.regi_cal_scwd_p(regi_cal_scwd_p),
//
.pbits          (swgenpbits ),
.pbitsready     (swgenpbitsready),
.syncword       (swgenword      )

);

//

rxsyncinword rxsyncinword_u(
.clk_6M    (clk_6M          ), 
.rstz      (rstz            ), 
.p_1us     (p_1us           ),
.rxbit     (rxbit_resync    ),
.syncinword(syncinword      )
);

endmodule
