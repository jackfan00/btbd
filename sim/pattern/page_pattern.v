initial begin
//
$fsdbDumpfile("bt.fsdb");
$fsdbDumpvars;
// parameter setting
regi_PageScanEnable_oneshot = 1'b0;
s_regi_slave_offset = 28'd0;
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
