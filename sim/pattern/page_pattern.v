initial begin
//
$fsdbDumpfile("bt.fsdb");
$fsdbDumpvars;
// parameter setting
//for master
regi_paged_BD_ADDR_LAP = 24'h0;
regi_paged_BD_ADDR_UAP = 8'h47;
m_regi_my_BD_ADDR_UAP = 8'h0;
m_regi_my_BD_ADDR_LAP = 24'h0;
//
// Vol2 Part G, sample Data
//syncword format
//transmit from left(c0) to right
//c0...c33,a0,a1,a2...a23,001101   if a23=0
//c0...c33,a0,a1,a2...a23,110010   if a23=1
m_regi_syncword_CAC =  64'he758b5227ffffff2; //LAP=ffffff, need match m_regi_my_BD_ADDR_LAP
m_regi_syncword_DAC =  64'h7e7041e34000000d; //LAP=0 , need match regi_paged_BD_ADDR_LAP
m_regi_syncword_DIAC = 64'h28ed3c34cb345e72; //LAP=9E8B34
m_regi_my_syncword =   34'h3f3820f1a; //LAP=0 , need match m_regi_my_BD_ADDR_LAP
//
m_regi_AFH_mode = 1'b0;  // each device have their own setting
m_regi_AFH_N = 7'd79;
m_regi_AFH_channel_map = {16'hffff,16'hffff,16'hffff,16'hffff,16'hffff};
regi_LT_ADDR = 3'd2;
m_regi_packet_type = 4'd4;
m_regi_payloadlen = 10'd0; //bytes
m_regi_FHS_LT_ADDR = 4'd2;   //should match regi_LT_ADDR for testbench sim

//
//for slave
s_regi_my_BD_ADDR_LAP = 24'h0;  //should match regi_paged_BD_ADDR_LAP
s_regi_my_BD_ADDR_UAP = 8'h47;  //should match regi_paged_BD_ADDR_UAP
regi_extendedInquiryResponse = 1'b0; 
s_regi_syncword_CAC =  64'he758b5227ffffff2; //LAP=ffffff, need match m_regi_my_BD_ADDR_LAP
s_regi_syncword_DAC =  64'h7e7041e34000000d; //LAP=0 , need match s_regi_my_BD_ADDR_LAP
s_regi_syncword_DIAC = 64'h28ed3c34cb345e72; //LAP=9E8B34
s_regi_my_syncword =   34'h3f3820f1a; //LAP=0 , need match s_regi_my_BD_ADDR_LAP
//
s_regi_AFH_mode = 1'b0;  // each device have their own setting
s_regi_AFH_N = 7'd79;
s_regi_AFH_channel_map = {16'hffff,16'hffff,16'hffff,16'hffff,16'hffff};
s_regi_packet_type = 4'd4;
s_regi_payloadlen = 10'd0; //bytes
regi_mylt_address = 3'd2;  //should match master's regi_LT_ADDR


//
regi_PageScanEnable_oneshot = 1'b0;
//
//
m_clk_6M = 1'b0;
s_clk_6M = 1'b0;
m_rstz = 1'b0;
s_rstz = 1'b0;
#1000;
m_rstz = 1'b1;
#10150000;
s_rstz = 1'b1;
//
#10000000;
@(posedge m_clk_6M);
regi_PageScanEnable_oneshot = 1'b1;
#1000 ;
regi_PageScanEnable_oneshot = 1'b0;
// reg setting

@(posedge m_clk_6M);
regi_InquiryEnable_oneshot = 1'b0;
regi_PageEnable_oneshot = 1'b0;
regi_ConnHold_oneshot = 1'b0;
regi_ConnSniff_oneshot = 1'b0;
regi_ConnPark_oneshot = 1'b0;
@(posedge m_clk_6M);
regi_PageEnable_oneshot = 1'b1;
#1000 ;
regi_PageEnable_oneshot = 1'b0;

//
#200000000;
//#2000000000;
//#2000000000;
$finish;
end
