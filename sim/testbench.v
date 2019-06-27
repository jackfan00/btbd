`timescale 1ns/10ps
module testbench;

reg m_clk_6M, m_rstz;
reg s_clk_6M, s_rstz;
reg [27:0] s_regi_slave_offset;
reg regi_InquiryEnable_oneshot, regi_PageEnable_oneshot, regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot;
reg regi_PageScanEnable_oneshot, regi_InquiryScanEnable_oneshot;

`include "tp.v"

always #83.333 m_clk_6M = ~m_clk_6M;
always #83.320 s_clk_6M = ~s_clk_6M;


wire m_txbit, s_txbit;
wire m_rxbit, s_rxbit;
wire [6:0] m_fk, s_fk;

bt_top bt_top_m(
.clk_6M                      (m_clk_6M               ), 
.rstz                        (m_rstz                 ),
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

.regi_esti_offset            (28'd0),  //m_regi_esti_offset     ), 
.regi_time_base_offset       (28'd0),  //m_regi_time_base_offset), 
.regi_slave_offset           (28'd0),  //m_regi_slave_offset    )
.regi_interlace_offset       (5'd16),
.regi_page_k_nudge           (5'd0), 
.regi_isMaster               (1'b1),
.regi_GIAC_BD_ADDR_UAP       (8'h0), 
.regi_paged_BD_ADDR_UAP      (8'h47),   
.regi_master_BD_ADDR_UAP     (8'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_UAP         (8'h0),
.regi_GIAC_BD_ADDR_LAP       (24'h9E8B33), 
.regi_paged_BD_ADDR_LAP      (24'h0),  //24'h61650c), 
.regi_master_BD_ADDR_LAP     (24'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_LAP         (24'h0),
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
.regi_pagetruncated          (1'b0),
.regi_psinterlace            (1'b0), 
.regi_isinterlace            (1'b0),
.regi_inquiryDIAC            (1'b0),
.regi_syncword_CAC           (64'he758b5227ffffff2),  //LAP=ffffff,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DAC           (64'h7e7041e34000000d),  //LAP=0,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DIAC          (64'h28ed3c34cb345e72),  //LAP=9E8B34,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_GIAC          (64'h475c58cc73345e72),
.regi_Npage                  (10'd127),
.regi_slave_SRmode           (2'b01),
.regi_scolink_num            (2'h0),
.regi_Page_Timeout           (16'h2000),   //5.12s),
.regi_m_uncerWinSize         (9'd10), 
.regi_s_uncerWinSize         (9'd10),
.regi_AFH_channel_map        ({16'hffff,16'hffff,16'hffff,16'hffff,16'hffff}),
.regi_AFH_N                  (7'd20),
.regi_AFH_modN               (7'd20),
.regi_isMaxRand              (10'd50),
.regi_extendedInquiryResponse(1'b0),
.regi_Tsco                   (3'd6),
.regi_LT_ADDR                (3'b010        ),
.regi_packet_type            (4'b0100       ),
.regi_FLOW                   (1'b0          ), 
.regi_ARQN                   (1'b1          ), 
.regi_SEQN                   (1'b1          ),
.regi_payloadlen             (10'd144),  //FHS: 144bits
.regi_FHS_LT_ADDR            (3'd2     ),
.regi_myClass                (24'd1    ),
.regi_my_BD_ADDR_NAP         (16'd0    ),
.regi_SR                     (2'd0     ),
.regi_EIR                    (1'b0     ),
.regi_my_syncword            (34'h3f3820f1a),   //LAP=0
.regi_txwhitening            (1'b1),
.regi_rxwhitening            (1'b0),
.rxbit                       (m_rxbit),
//
.txbit                       (m_txbit),
.fk                          (m_fk),
.regi_aclrxbufempty          ()

);
wire [27:2] regi_fhsslave_offset;
wire [33:0] fhs_Pbits_L2M;
wire [23:0] fhs_LAP_L2M;
wire [2:0] fhs_LT_ADDR;

bt_top bt_top_s(
.clk_6M                      (s_clk_6M               ), 
.rstz                        (s_rstz                 ),
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
.regi_time_base_offset       ({15'b0,1'b1,12'b0}),  //s_regi_time_base_offset), 
.regi_slave_offset           ({regi_fhsslave_offset,2'b0}),  //s_regi_slave_offset    ),
.regi_interlace_offset       (5'd16),
.regi_page_k_nudge           (5'd0), 
.regi_isMaster               (1'b0),
.regi_GIAC_BD_ADDR_UAP       (8'h0), 
.regi_paged_BD_ADDR_UAP      (8'h0),  //24'h61650c), 
.regi_master_BD_ADDR_UAP     (8'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_UAP         (8'h47),
.regi_GIAC_BD_ADDR_LAP       (24'h9E8B33), 
.regi_paged_BD_ADDR_LAP      (24'h0),  //24'h61650c), 
.regi_master_BD_ADDR_LAP     (24'h0),   //syncword = 64'h7e7041e34000000d, SPEC Vol2, PartG, 3.ACCESS CODE SAMPLE DATA
.regi_my_BD_ADDR_LAP         (24'h0),
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
.regi_Tisinterval            (16'h1000),   //2.56s), 
.regi_Tiswindow              (16'h0012),   //11.25ms),
.regi_correthreshold         (6'd60),   // allow 4 bit error
.regi_pagetruncated          (1'b0),
.regi_psinterlace            (1'b0), 
.regi_isinterlace            (1'b0),
.regi_inquiryDIAC            (1'b0),
.regi_syncword_CAC           (64'he758b5227ffffff2),  //LAP=ffffff,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DAC           (64'h7e7041e34000000d),  //LAP=0,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_DIAC          (64'h28ed3c34cb345e72),  //LAP=9E8B34,      //(64'hec4c69b54c29a18d, LAP= 24'h61650c) 
.regi_syncword_GIAC          (64'h475c58cc73345e72),
.regi_Npage                  (10'd127),
.regi_slave_SRmode           (2'b01),
.regi_scolink_num            (2'h0),
.regi_Page_Timeout           (16'h2000),   //5.12s),
.regi_m_uncerWinSize         (9'd10), 
.regi_s_uncerWinSize         (9'd10),
.regi_AFH_channel_map        ({16'hffff,16'hffff,16'hffff,16'hffff,16'hffff}),
.regi_AFH_N                  (7'd20),
.regi_AFH_modN               (7'd20),
.regi_isMaxRand              (10'd50),
.regi_extendedInquiryResponse(1'b1),
.regi_Tsco                   (3'd6),
.regi_LT_ADDR                (3'b011        ),
.regi_mylt_address           (3'b010        ),
.regi_packet_type            (4'b0100       ),
.regi_FLOW                   (1'b0          ), 
.regi_ARQN                   (1'b1          ), 
.regi_SEQN                   (1'b0          ),
.regi_payloadlen             (10'd144),  //FHS: 144bits
.regi_FHS_LT_ADDR            (3'd1     ),
.regi_myClass                (24'd1    ),
.regi_my_BD_ADDR_NAP         (16'd0    ),
.regi_SR                     (2'd0     ),
.regi_EIR                    (1'b1     ),
.regi_my_syncword            (34'h3f3820f1a),   //LAP=0
.regi_txwhitening            (1'b0),
.regi_rxwhitening            (1'b1),
.rxbit                       (s_rxbit),
//
.txbit                       (s_txbit),
.fk                          (s_fk),
.regi_fhsslave_offset        (regi_fhsslave_offset),
.regi_aclrxbufempty          (),
.fhs_LT_ADDR                 (fhs_LT_ADDR),
.fhs_Pbits_L2M                   (fhs_Pbits_L2M),
.fhs_LAP_L2M                     (fhs_LAP_L2M)
);


assign m_rxbit = m_fk==s_fk ? s_txbit : 1'bx;
assign s_rxbit = m_fk==s_fk ? m_txbit : 1'bx;

endmodule
