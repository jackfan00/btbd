`timescale 1ns/10ps
module testbench;


wire [7:0] m_regi_srcFLOW, s_regi_srcFLOW;
wire [7:0] m_regi_txARQN, s_regi_txARQN;
wire [3:0] m_regi_dec_pk_type;
wire [2:0] m_regi_dec_lt_addr;
wire [7:0] m_regi_dec_flow, m_regi_dec_arqn, m_regi_SEQN_old;
wire       m_regi_dec_hecgood;
wire [3:0] s_regi_dec_pk_type;
wire [2:0] s_regi_dec_lt_addr;
wire [7:0] s_regi_dec_flow, s_regi_dec_arqn, s_regi_SEQN_old;
wire       s_regi_dec_hecgood;

reg m_clk_6M, m_rstz;
reg s_clk_6M, s_rstz;

`include "tp.v"

always #83.333 m_clk_6M = ~m_clk_6M;
always #83.333 s_clk_6M = ~s_clk_6M;

reg regi_cal_scwd_p;
initial begin
regi_cal_scwd_p=1'b0;
wait(m_rstz==1'b1);
#100;
@(posedge m_clk_6M);
#5;
regi_cal_scwd_p=1'b1;
@(posedge m_clk_6M);
#5;
regi_cal_scwd_p=1'b0;

end

wire [2:0] m_txsymbol, s_txsymbol;
wire [2:0] m_rxsymbol, s_rxsymbol;
wire [6:0] m_fk, s_fk;
wire [6:0] m_nxtfk, s_nxtfk;
wire m_connsactive, s_connsactive;
wire [4:0] m_regi_lc_cs, s_regi_lc_cs;
wire [27:0] m_CLK, s_CLK;

bt_top bt_top_m(
.clk_6M                      (m_clk_6M               ), 
.rstz                        (m_rstz                 ),
.regi_ptt                    (m_regi_ptt             ),
.regi_pllsetuptime           (10'd150                ), // 150us
.regi_chgbufcmd_p            (),
.txbsmacl_addr               (), //o_adr), 
.txbsmsco_addr               (),
.txbsmacl_din                (), //o_din), 
.txbsmsco_din                (),
.txbsmacl_we                 (), 
.txbsmsco_we                 (), 
.txbsmacl_cs                 (), 
.txbsmsco_cs                 (),
.rxbsmacl_addr               (), 
.rxbsmsco_addr               (),
.rxbsmacl_cs                 (), 
.rxbsmsco_cs                 (),
.rxbsm_valid_p               (),
.regi_txcmd_p                (1'b0), 
.regi_flushcmd_p             (1'b0), 
.regi_LMPcmdfg               (1'b0),

.regi_esti_offset            (28'd0),  //m_regi_esti_offset     ), 
.regi_time_base_offset       (28'd0),  //m_regi_time_base_offset), 
.regi_slave_offset           (28'd0),  //m_regi_slave_offset    )
.regi_interlace_offset       (5'd16),
.regi_page_k_nudge           (5'd0), 
.regi_isMaster               (1'b1),
.regi_scwdLAP                (regi_paged_BD_ADDR_LAP), 
.regi_cal_scwd_p             (regi_cal_scwd_p),
.regi_GIAC_BD_ADDR_UAP       (8'h0), 
.regi_paged_BD_ADDR_UAP      (regi_paged_BD_ADDR_UAP),   
.regi_master_BD_ADDR_UAP     (m_regi_my_BD_ADDR_UAP),   //for master, is regi_my_BD_ADDR_UAP
.regi_my_BD_ADDR_UAP         (m_regi_my_BD_ADDR_UAP),
.regi_GIAC_BD_ADDR_LAP       (24'h9E8B33), 
.regi_paged_BD_ADDR_LAP      (regi_paged_BD_ADDR_LAP),  //24'h61650c), 
.regi_master_BD_ADDR_LAP     (24'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_LAP         (m_regi_my_BD_ADDR_LAP),
.regi_PageScanEnable_oneshot (1'b0), 
.regi_PageScanCancel_oneshot (1'b0),
.regi_InquiryScanEnable_oneshot      (1'b0),
.regi_InquiryScanCancel_oneshot      (1'b0),
.regi_InquiryEnable_oneshot  (regi_InquiryEnable_oneshot),  
.regi_PageEnable_oneshot     (regi_PageEnable_oneshot), 
.regi_ConnHold_oneshot       (regi_ConnHold_oneshot), 
.regi_ConnSniff_oneshot      (regi_ConnSniff_oneshot), 
.regi_ConnPark_oneshot       (regi_ConnPark_oneshot),
.regi_Tpsinterval            (16'h0800),  //1.28s), 
.regi_Tpswindow              (16'h0012),  //11.25ms),
.regi_Tisinterval            (16'h1000),   //2.56s), 
.regi_Tiswindow              (16'h0012),   //11.25ms),
.regi_correthreshold         (6'd60),   // allow 4 bit error
.regi_pagetruncated          (m_regi_pagetruncated),
.regi_psinterlace            (1'b0), 
.regi_isinterlace            (1'b0),
.regi_inquiryDIAC            (1'b0),
.regi_syncword_CAC           (m_regi_syncword_CAC),  //LAP=ffffff,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DAC           (m_regi_syncword_DAC),  //LAP=0,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DIAC          (m_regi_syncword_DIAC),  //LAP=9E8B34,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_GIAC          (fixed_syncword_GIAC), //64'h475c58cc73345e72),
.regi_Npage                  (10'd127),
.regi_slave_SRmode           (2'b01),
.regi_scolink_num            (2'h0),
.regi_Page_Timeout           (16'h2000),   //5.12s),
.regi_m_uncerWinSize         (9'd10), 
.regi_s_uncerWinSize         (9'd10),
.regi_AFH_mode               (m_regi_AFH_mode),
.regi_AFH_channel_map        (m_regi_AFH_channel_map),
.regi_AFH_N                  (m_regi_AFH_N),
//.regi_AFH_modN               (7'd20),
.regi_isMaxRand              (10'd50),
.regi_extendedInquiryResponse(1'b0),
.regi_Tsco                   (3'd6),
.regi_LT_ADDR                (regi_LT_ADDR),
.regi_packet_type            (m_regi_packet_type),
//.regi_FLOW                   (1'b0          ), 
//.regi_ARQN                   (1'b1          ), 
//.regi_SEQN                   (1'b1          ),
.regi_payloadlen             (m_regi_payloadlen),  //FHS: 144bits
.regi_FHS_LT_ADDR            (m_regi_FHS_LT_ADDR),
.regi_myClass                (24'd1    ),
.regi_my_BD_ADDR_NAP         (16'd0    ),
.regi_SR                     (2'd0     ),
.regi_EIR                    (1'b0     ),
.regi_my_syncword            (m_regi_my_syncword_c33c0),   //
.regi_txwhitening            (m_regi_txwhitening),
.regi_rxwhitening            (m_regi_rxwhitening),
.rxsymbol                       (m_rxsymbol),
//
.txsymbol                    (m_txsymbol),
.fk                          (m_fk),
.regi_aclrxbufempty          (),
.regi_srcFLOW                (m_regi_srcFLOW),
.regi_txARQN                 (m_regi_txARQN),
.regi_dec_pk_type            (m_regi_dec_pk_type       ),
.regi_dec_lt_addr            (m_regi_dec_lt_addr       ),
.regi_dec_flow               (m_regi_dec_flow          ), 
.regi_dec_arqn               (m_regi_dec_arqn          ), 
.regi_SEQN_old               (m_regi_SEQN_old          ),
.regi_dec_hecgood            (m_regi_dec_hecgood       ),
.txbit_period                (m_txbit_period             ), 
.txbit_period_endp           (m_txbit_period_endp        ),
.rxbit_period                (m_rxbit_period             ), 
.rxbit_period_endp           (m_rxbit_period_endp        ),
.nxtfk                       (m_nxtfk                    ),
.fk_chg_p                    (m_fk_chg_p                 ),
.fk_chg_p_ff                 (m_fk_chg_p_ff              ),
.connsactive                 (m_connsactive              ),
.regi_lc_cs                  (m_regi_lc_cs               ),
.CLK                         (m_CLK                      ),
.p_1us                       (m_p_1us                    )

);

wire [2:0] m_radio_txsymbol, s_radio_txsymbol;
wire [6:0] m_radio_txfk, s_radio_txfk;
//wire m_loadfreq_p = (m_txbit_period_endp & m_txbit_period) |
//                  (m_rxbit_period_endp & m_rxbit_period) ;

BTradio m_BTradio(
.clk_6M     (m_clk_6M     ), 
.rstz       (m_rstz       ),
.p_1us      (m_p_1us        ),
.connsactive(m_connsactive),
.CLK        (m_CLK),
.txsymbolin    (m_txsymbol    ), 
.rxsymbolin    (s_radio_txsymbol    ),
.txen       (m_txbit_period       ), 
.rxen       (m_rxbit_period       ),
.lc_fk      (m_nxtfk          ), 
.rxfk       (s_radio_txfk        ),
.loadfreq_p (m_fk_chg_p_ff ),
//         (//         )
.txsymbolout   (m_radio_txsymbol   ), 
.rxsymbolout   (m_rxsymbol   ),
.txfk       (m_radio_txfk   )

);


wire [27:2] regi_fhsslave_offset;
wire [33:0] fhs_Pbits;
wire [23:0] fhs_LAP;
wire [2:0] fhs_LT_ADDR;

bt_top bt_top_s(
.clk_6M                      (s_clk_6M               ), 
.rstz                        (s_rstz                 ),
.regi_ptt                    (s_regi_ptt             ),
.regi_pllsetuptime           (10'd150                ), // 150us
.regi_chgbufcmd_p            (),
.txbsmacl_addr               (), 
.txbsmsco_addr               (),
.txbsmacl_din                (), 
.txbsmsco_din                (),
.txbsmacl_we                 (), 
.txbsmsco_we                 (), 
.txbsmacl_cs                 (), 
.txbsmsco_cs                 (),
.rxbsmacl_addr               (), 
.rxbsmsco_addr               (),
.rxbsmacl_cs                 (), 
.rxbsmsco_cs                 (),
.rxbsm_valid_p               (),
.regi_txcmd_p                (1'b0), 
.regi_flushcmd_p             (1'b0), 
.regi_LMPcmdfg               (1'b0),

.regi_esti_offset            (28'd0),  //s_regi_esti_offset     ), 
.regi_time_base_offset       ({15'b0,s_pscase,12'b0}),  //s_regi_time_base_offset), 
.regi_slave_offset           ({regi_fhsslave_offset,2'b0}),  //s_regi_slave_offset    ),
.regi_interlace_offset       (5'd16),
.regi_page_k_nudge           (5'd0), 
.regi_isMaster               (1'b0),
.regi_GIAC_BD_ADDR_UAP       (8'h0), 
.regi_paged_BD_ADDR_UAP      (8'h0),  //24'h61650c), 
.regi_master_BD_ADDR_UAP     (s_regi_master_BD_ADDR_UAP),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_UAP         (s_regi_my_BD_ADDR_UAP),
.regi_my_BD_ADDR_LAP         (s_regi_my_BD_ADDR_LAP),
.regi_GIAC_BD_ADDR_LAP       (24'h9E8B33), 
.regi_paged_BD_ADDR_LAP      (24'h0),  //24'h61650c), 
.regi_master_BD_ADDR_LAP     (24'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_PageScanEnable_oneshot (regi_PageScanEnable_oneshot), 
.regi_PageScanCancel_oneshot (1'b0),
.regi_InquiryScanEnable_oneshot      (regi_InquiryScanEnable_oneshot),
.regi_InquiryScanCancel_oneshot      (1'b0),
.regi_InquiryEnable_oneshot  (1'b0),  
.regi_PageEnable_oneshot     (1'b0), 
.regi_ConnHold_oneshot       (1'b0), 
.regi_ConnSniff_oneshot      (1'b0), 
.regi_ConnPark_oneshot       (1'b0),
.regi_Tpsinterval            (16'h0800),  //1.28s), 
.regi_Tpswindow              (16'h0012),  //11.25ms),
.regi_Tisinterval            (16'h00a0),  //00a0 for debug,           (16'h1000 -> 2.56s), 
.regi_Tiswindow              (16'h0012),   //11.25ms),
.regi_correthreshold         (6'd60),   // allow 4 bit error
.regi_pagetruncated          (1'b0),
.regi_psinterlace            (1'b0), 
.regi_isinterlace            (1'b0),
.regi_inquiryDIAC            (1'b0),
.regi_syncword_CAC           (s_regi_syncword_CAC),  //LAP=ffffff,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DAC           (s_regi_syncword_DAC),  //LAP=0,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DIAC          (s_regi_syncword_DIAC),  //LAP=9E8B34,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_GIAC          (fixed_syncword_GIAC), //64'h475c58cc73345e72),
.regi_Npage                  (10'd127),
.regi_slave_SRmode           (2'b01),
.regi_scolink_num            (2'h0),
.regi_Page_Timeout           (16'h2000),   //5.12s),
.regi_m_uncerWinSize         (9'd10), 
.regi_s_uncerWinSize         (9'd10),
.regi_AFH_mode               (s_regi_AFH_mode),
.regi_AFH_channel_map        ({16'hffff,16'hffff,16'hffff,16'hffff,16'hffff}),
.regi_AFH_N                  (s_regi_AFH_N),
//.regi_AFH_modN               (7'd20),
.regi_isMaxRand              (10'd50),
.regi_extendedInquiryResponse(regi_extendedInquiryResponse),
.regi_Tsco                   (3'd6),
.regi_LT_ADDR                (3'b011        ),
.regi_mylt_address           (regi_mylt_address),
.regi_packet_type            (s_regi_packet_type),
//.regi_FLOW                   (1'b0          ), 
//.regi_ARQN                   (1'b1          ), 
//.regi_SEQN                   (1'b0          ),
.regi_payloadlen             (s_regi_payloadlen),  //FHS: 144bits
.regi_FHS_LT_ADDR            (3'd0     ),
.regi_myClass                (24'd1    ),
.regi_my_BD_ADDR_NAP         (16'd0    ),
.regi_SR                     (2'd0     ),
.regi_EIR                    (s_regi_EIR     ),
.regi_my_syncword            (s_my_syncword_c33c0),   //LAP=0
.regi_txwhitening            (s_regi_txwhitening),
.regi_rxwhitening            (s_regi_rxwhitening),
.rxsymbol                       (s_rxsymbol),
//
.txsymbol                       (s_txsymbol),
.fk                          (s_fk),
.regi_fhsslave_offset        (regi_fhsslave_offset),
.regi_aclrxbufempty          (),
.fhs_LT_ADDR                 (fhs_LT_ADDR),
.fhs_Pbits                   (fhs_Pbits),
.fhs_LAP                     (fhs_LAP),
.regi_srcFLOW                (s_regi_srcFLOW),
.regi_txARQN                 (s_regi_txARQN),
.regi_dec_pk_type            (s_regi_dec_pk_type       ),
.regi_dec_lt_addr            (s_regi_dec_lt_addr       ),
.regi_dec_flow               (s_regi_dec_flow          ), 
.regi_dec_arqn               (s_regi_dec_arqn          ), 
.regi_SEQN_old               (s_regi_SEQN_old          ),
.regi_dec_hecgood            (s_regi_dec_hecgood       ),
.txbit_period                (s_txbit_period             ), 
.txbit_period_endp           (s_txbit_period_endp        ),
.rxbit_period                (s_rxbit_period             ), 
.rxbit_period_endp           (s_rxbit_period_endp        ),
.nxtfk                       (s_nxtfk                    ),
.fk_chg_p                    (s_fk_chg_p                 ),
.fk_chg_p_ff                 (s_fk_chg_p_ff              ),
.connsactive                 (s_connsactive              ),
.regi_lc_cs                  (s_regi_lc_cs               ),
.CLK                         (s_CLK                      ),
.p_1us                       (s_p_1us                    )

);

//wire s_loadfreq_p = (s_txbit_period_endp & s_txbit_period) |
//                  (s_rxbit_period_endp & s_rxbit_period) ;

BTradio s_BTradio(
.clk_6M     (s_clk_6M     ), 
.rstz       (s_rstz       ),
.p_1us      (s_p_1us        ),
.connsactive(s_connsactive),
.CLK        (s_CLK),
.txsymbolin    (s_txsymbol    ), 
.rxsymbolin    (m_radio_txsymbol    ),
.txen       (s_txbit_period       ), 
.rxen       (s_rxbit_period       ),
.lc_fk      (s_nxtfk          ), 
.rxfk       (m_radio_txfk        ),
.loadfreq_p (s_fk_chg_p_ff ),
//         (//         )
.txsymbolout   (s_radio_txsymbol   ), 
.rxsymbolout   (s_rxsymbol   ),
.txfk       (s_radio_txfk   )

);


endmodule
