
task m_txcmd;
//
@(posedge m_clk_6M);
#10;
force bt_top_m.regi_txcmd_p=1'b1;
@(posedge m_clk_6M);
#10;
force bt_top_m.regi_txcmd_p=1'b0;
//
endtask;

task chgbuf;
input master;
//
if (master)
begin
@(posedge m_clk_6M);
#10;
force bt_top_m.regi_chgbufcmd_p=1'b1;
@(posedge m_clk_6M);
#10;
force bt_top_m.regi_chgbufcmd_p=1'b0;
end
else
begin
@(posedge s_clk_6M);
#10;
force bt_top_s.regi_chgbufcmd_p=1'b1;
@(posedge s_clk_6M);
#10;
force bt_top_s.regi_chgbufcmd_p=1'b0;
end
//
endtask;


task bsm_wdat;
output [7:0] to_adr;
output [31:0] to_din;
output to_we;
output to_cs;
input master;
input [7:0] adr;
input [31:0] din;

//reg [7:0] to_adr;
//reg [31:0] to_din;
//reg to_we, to_cs;
//
if (master)
begin
@(posedge m_clk_6M);
#10;
force bt_top_m.txbsmacl_we =1'b1;
force bt_top_m.txbsmacl_cs =1'b1;
force bt_top_m.txbsmacl_addr = adr;
force bt_top_m.txbsmacl_din = din;
@(posedge m_clk_6M);
#10;
force bt_top_m.txbsmacl_we =1'b0;
force bt_top_m.txbsmacl_cs =1'b0;
end
else
begin
@(posedge s_clk_6M);
#10;
force bt_top_s.txbsmacl_we =1'b1;
force bt_top_s.txbsmacl_cs =1'b1;
force bt_top_s.txbsmacl_addr = adr;
force bt_top_s.txbsmacl_din = din;
@(posedge s_clk_6M);
#10;
force bt_top_s.txbsmacl_we =1'b0;
force bt_top_s.txbsmacl_cs =1'b0;
end
//
endtask;

reg [23:0] regi_paged_BD_ADDR_LAP ;
reg [7:0] regi_paged_BD_ADDR_UAP ;
reg [7:0] m_regi_my_BD_ADDR_UAP ;
reg [23:0] m_regi_my_BD_ADDR_LAP ;
//
// Vol2 Part G, sample Data
//syncword format
//transmit from left(c0) to right
//c0...c33,a0,a1,a2...a23,001101   if a23=0
//c0...c33,a0,a1,a2...a23,110010   if a23=1
reg [33:0] m_regi_my_syncword_c0c33 ; //LAP=ffffff,
reg [33:0] m_regi_my_syncword_c33c0 ; //LAP=ffffff,
reg [33:0] m_paged_syncword_c0c33   ; //LAP=0
reg [33:0] m_paged_syncword_c33c0   ; //LAP=0
reg [63:0] m_regi_syncword_CAC ; // 
reg [63:0] m_regi_syncword_DAC ;  //
reg [63:0] m_regi_syncword_DIAC ; //LAP=9E8B34
//
reg m_regi_AFH_mode ;  // each device have their own setting
reg [6:0] m_regi_AFH_N ;
reg [79:0] m_regi_AFH_channel_map ;
reg [2:0] regi_LT_ADDR ;
reg [3:0] m_regi_packet_type ;
reg [9:0] m_regi_payloadlen ; //bytes
reg [2:0] m_regi_FHS_LT_ADDR ;   //should match regi_LT_ADDR for testbench sim
reg m_regi_txwhitening ;
reg m_regi_rxwhitening ;
reg m_regi_chgbufcmd_p;
//
//for slave
reg [23:0] s_regi_my_BD_ADDR_LAP ;  //should match regi_paged_BD_ADDR_LAP
reg [7:0] s_regi_my_BD_ADDR_UAP ;  //should match regi_paged_BD_ADDR_UAP
reg [33:0] s_my_syncword_c0c33   ; //should match s_regi_my_BD_ADDR_LAP
reg [33:0] s_my_syncword_c33c0   ; //
 
reg regi_extendedInquiryResponse ; 
reg [63:0] s_regi_syncword_CAC ; //LAP=ffffff, need match m_regi_my_BD_ADDR_LAP
reg [63:0] s_regi_syncword_DAC ; //
reg [63:0] s_regi_syncword_DIAC ; //LAP=9E8B34
//
reg s_regi_AFH_mode ;  // each device have their own setting
reg [6:0] s_regi_AFH_N ;
reg [79:0] s_regi_AFH_channel_map ;
reg [3:0] s_regi_packet_type ;
reg [9:0] s_regi_payloadlen ; //bytes
reg [2:0] regi_mylt_address ;  //should match master's regi_LT_ADDR
reg s_regi_txwhitening ;
reg s_regi_rxwhitening ;
reg s_regi_chgbufcmd_p;
reg [7:0] s_regi_master_BD_ADDR_UAP;

reg regi_InquiryEnable_oneshot, regi_PageEnable_oneshot, regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot;
reg regi_PageScanEnable_oneshot, regi_InquiryScanEnable_oneshot;

// page initial begin block
initial begin
//
$fsdbDumpfile("bt.fsdb");
$fsdbDumpvars;
// parameter setting
//for master
regi_paged_BD_ADDR_LAP = 24'h0;
regi_paged_BD_ADDR_UAP = 8'h47;
m_regi_my_BD_ADDR_LAP = 24'hffffff;
m_regi_my_BD_ADDR_UAP = 8'h47;
//
// Vol2 Part G, sample Data
//syncword format
//transmit from left(c0) to right
//c0...c33,a0,a1,a2...a23,001101   if a23=0
//c0...c33,a0,a1,a2...a23,110010   if a23=1
//m_regi_my_syncword_c0c33 =   34'he758b5224; //LAP=ffffff,
m_regi_my_syncword_c33c0 =   34'h244ad1ae7; //LAP=ffffff,
//m_paged_syncword_c0c33   =   34'h1f9c1078d; //LAP=0
m_paged_syncword_c33c0   =   34'h2c7820e7e; //LAP=0
m_regi_syncword_CAC =  {6'b010011,m_regi_my_BD_ADDR_UAP,m_regi_my_syncword_c33c0}; // 
m_regi_syncword_DAC =  {6'b101100,regi_paged_BD_ADDR_LAP,m_paged_syncword_c33c0};  //
//m_regi_syncword_DIAC = 64'h28ed3c34cb345e72; //LAP=9E8B34
m_regi_syncword_DIAC   = 64'h4e7a2cd32c3cb714; //LAP=9E8B34
//
m_regi_AFH_mode = 1'b0;  // each device have their own setting
m_regi_AFH_N = 7'd79;
m_regi_AFH_channel_map = {16'hffff,16'hffff,16'hffff,16'hffff,16'hffff};
regi_LT_ADDR = 3'd3;
m_regi_packet_type = 4'd4;
m_regi_payloadlen = 10'd0; //bytes
m_regi_FHS_LT_ADDR = 4'd3;   //should match regi_LT_ADDR for testbench sim
m_regi_txwhitening = 1'b1;
m_regi_rxwhitening = 1'b0;
//
//for slave
s_regi_master_BD_ADDR_UAP = 8'h47;  //should match m_regi_my_BD_ADDR_UAP
s_regi_my_BD_ADDR_LAP = 24'h0;  //should match regi_paged_BD_ADDR_LAP
s_regi_my_BD_ADDR_UAP = 8'h47;  //should match regi_paged_BD_ADDR_UAP
//s_my_syncword_c0c33   =   34'h1f9c1078d; //should match s_regi_my_BD_ADDR_LAP
s_my_syncword_c33c0   =   34'h2c7820e7e; //

regi_extendedInquiryResponse = 1'b0; 
s_regi_syncword_CAC =  m_regi_syncword_CAC; //LAP=ffffff, need match m_regi_my_BD_ADDR_LAP
s_regi_syncword_DAC =  {6'b101100,s_regi_my_BD_ADDR_LAP,s_my_syncword_c33c0}; //
//s_regi_syncword_DIAC = 64'h28ed3c34cb345e72; //LAP=9E8B34
s_regi_syncword_DIAC   = 64'h4e7a2cd32c3cb714; //LAP=9E8B34

//
s_regi_AFH_mode = 1'b0;  // each device have their own setting
s_regi_AFH_N = 7'd79;
s_regi_AFH_channel_map = {16'hffff,16'hffff,16'hffff,16'hffff,16'hffff};
s_regi_packet_type = 4'd3;
s_regi_payloadlen = 10'd0; //bytes
regi_mylt_address = 3'd3;  //should match master's regi_LT_ADDR
s_regi_txwhitening = 1'b0;
s_regi_rxwhitening = 1'b1;


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

//
// conns initial begin block
// SPEC Vol2 Part G , 6.1
//
reg [7:0] o_adr;
reg [31:0] o_din;
reg o_we, o_cs;

reg [7:0] m_pyheader_l,m_pyheader_h;
initial begin
wait (bt_top_m.conns);
wait (bt_top_m.linkctrler_u.cs==5'd5);
//
m_regi_txwhitening = 1'b0;
m_regi_rxwhitening = 1'b0;
s_regi_txwhitening = 1'b0;
s_regi_rxwhitening = 1'b0;

regi_LT_ADDR = 3'd3;
m_regi_packet_type = 4'd4;
m_regi_payloadlen = 10'd5; //bytes
//
m_pyheader_l = {m_regi_payloadlen[4:0], 1'b1, 2'b10};
m_pyheader_h = {3'b0,m_regi_payloadlen[9:5]};
bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 0, {8'h03,8'h02,8'h01,m_pyheader_l});
bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 1, {8'h05,8'h04});

//
// retransmit or not
if (m_regi_txARQN[regi_LT_ADDR])
  chgbuf(1);
//
m_txcmd;
//
end


//
reg [7:0] s_pyheader_l,s_pyheader_h;
initial begin
wait (bt_top_s.linkctrler_u.cs==5'd5);
//
regi_mylt_address = 3'd3;
s_regi_packet_type = 4'd3;
s_regi_payloadlen = 10'd5; //bytes
//
s_pyheader_l = {s_regi_payloadlen[4:0], 1'b1, 2'b10};
s_pyheader_h = {3'b0,s_regi_payloadlen[9:5]};
bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 0, {8'h03,8'h02,8'h01,s_pyheader_l});
bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 1, {8'h05,8'h04});

// retransmit or not
if (s_regi_txARQN[regi_mylt_address])
  chgbuf(0);
//
// slave auto reponse
end