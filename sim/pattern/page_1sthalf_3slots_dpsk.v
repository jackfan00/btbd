
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
//force bt_top_m.linkctrler_u.regw_txdatready_p=1'b1;
@(posedge m_clk_6M);
#10;
force bt_top_m.regi_chgbufcmd_p=1'b0;
//force bt_top_m.linkctrler_u.regw_txdatready_p=1'b0;
end
else
begin
@(posedge s_clk_6M);
#10;
force bt_top_s.regi_chgbufcmd_p=1'b1;
//force bt_top_s.linkctrler_u.regw_txdatready_p=1'b1;
@(posedge s_clk_6M);
#10;
force bt_top_s.regi_chgbufcmd_p=1'b0;
//force bt_top_s.linkctrler_u.regw_txdatready_p=1'b0;
end
//
endtask;

task newdatready;
input master;
//
if (master)
begin
@(posedge m_clk_6M);
#10;
//force bt_top_m.regi_chgbufcmd_p=1'b1;
force bt_top_m.linkctrler_u.regw_txdatready_p=1'b1;
@(posedge m_clk_6M);
#10;
//force bt_top_m.regi_chgbufcmd_p=1'b0;
force bt_top_m.linkctrler_u.regw_txdatready_p=1'b0;
end
else
begin
@(posedge s_clk_6M);
#10;
//force bt_top_s.regi_chgbufcmd_p=1'b1;
force bt_top_s.linkctrler_u.regw_txdatready_p=1'b1;
@(posedge s_clk_6M);
#10;
//force bt_top_s.regi_chgbufcmd_p=1'b0;
force bt_top_s.linkctrler_u.regw_txdatready_p=1'b0;
end
//
endtask;

task m_bsm_wdat;
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
//////if (master)
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
//////else
//////begin
//////@(posedge s_clk_6M);
//////#10;
//////force bt_top_s.txbsmacl_we =1'b1;
//////force bt_top_s.txbsmacl_cs =1'b1;
//////force bt_top_s.txbsmacl_addr = adr;
//////force bt_top_s.txbsmacl_din = din;
//////@(posedge s_clk_6M);
//////#10;
//////force bt_top_s.txbsmacl_we =1'b0;
//////force bt_top_s.txbsmacl_cs =1'b0;
//////end
//
endtask;

task s_bsm_wdat;
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
///////if (master)
///////begin
///////@(posedge m_clk_6M);
///////#10;
///////force bt_top_m.txbsmacl_we =1'b1;
///////force bt_top_m.txbsmacl_cs =1'b1;
///////force bt_top_m.txbsmacl_addr = adr;
///////force bt_top_m.txbsmacl_din = din;
///////@(posedge m_clk_6M);
///////#10;
///////force bt_top_m.txbsmacl_we =1'b0;
///////force bt_top_m.txbsmacl_cs =1'b0;
///////end
///////else
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

task m_bsm_rdat;
input [7:0] adr;
//
begin
@(posedge m_clk_6M);
#10;
force bt_top_m.rxbsmacl_cs =1'b1;
force bt_top_m.rxbsm_valid_p =1'b1;
force bt_top_m.rxbsmacl_addr = adr;
@(posedge m_clk_6M);
#10;
force bt_top_m.rxbsmacl_cs =1'b0;
force bt_top_m.rxbsm_valid_p =1'b0;
end
endtask;

task s_bsm_rdat;
input [7:0] adr;
//
begin
@(posedge s_clk_6M);
#10;
force bt_top_s.rxbsmacl_cs =1'b1;
force bt_top_s.rxbsm_valid_p =1'b1;
force bt_top_s.rxbsmacl_addr = adr;
@(posedge s_clk_6M);
#10;
force bt_top_s.rxbsmacl_cs =1'b0;
force bt_top_s.rxbsm_valid_p =1'b0;
end
endtask;

reg m_regi_ptt;
reg m_regi_pagetruncated;
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
reg s_regi_ptt;
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
reg s_pscase;

reg [63:0] fixed_syncword_GIAC;

reg regi_InquiryEnable_oneshot, regi_PageEnable_oneshot, regi_ConnHold_oneshot, regi_ConnSniff_oneshot, regi_ConnPark_oneshot;
reg regi_PageScanEnable_oneshot, regi_InquiryScanEnable_oneshot;

// page initial begin block
initial begin
//
$fsdbDumpfile("bt.fsdb");
$fsdbDumpvars;
// parameter setting
//for master
m_regi_ptt = 1'b0;
m_regi_pagetruncated = 1'b0;
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
m_regi_syncword_CAC =  {6'b010011,m_regi_my_BD_ADDR_LAP,m_regi_my_syncword_c33c0}; // 
m_regi_syncword_DAC =  {6'b101100,regi_paged_BD_ADDR_LAP,m_paged_syncword_c33c0};  //
//m_regi_syncword_DIAC = 64'h28ed3c34cb345e72; //LAP=9E8B34
m_regi_syncword_DIAC   = 64'h4e7a2cd32c3cb714; //LAP=9E8B34
//m_regi_syncword_GIAC   = 64'h475c58cc73345e72;
fixed_syncword_GIAC   =   64'h4e7a2cce331a3ae2;
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
s_regi_ptt = 1'b0;
s_pscase = 1'b1;   // 1st or 2nd half
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
integer m_i, m_ri;
initial begin
m_regi_txwhitening = 1'b0;
m_regi_rxwhitening = 1'b0;
s_regi_txwhitening = 1'b0;
s_regi_rxwhitening = 1'b0;
//
wait (bt_top_m.conns);
wait (bt_top_m.linkctrler_u.cs==5'd5);
//
// LMP negosiation time
# 123400;
//
// prepare data and header, then write to buffer (only data, header is register setting)
// 
regi_LT_ADDR = 3'd3;
m_regi_ptt = 1'b1;
m_regi_packet_type = 4'ha;
m_regi_payloadlen = 10'd121; //bytes
m_pyheader_l = {m_regi_payloadlen[4:0], 1'b1, 2'b10};
m_pyheader_h = {3'b0,m_regi_payloadlen[9:5]};
// mcu write to buffer
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 0, {8'h02,8'h01,m_pyheader_h,m_pyheader_l});
for (m_i=1;m_i<=m_regi_payloadlen[9:2];m_i=m_i+1)
  begin
    m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, m_i, {m_i+3,m_i+2,m_i+1,m_i});
  end  
//
//  for 1st packet, mcu need to switch buffer manually 
//    chgbuf(1);
//    newdatready(1);
//  mcu issue tx cmd
# 5678;
    m_txcmd;

wait (bt_top_m.CLK[1]==1'b1);
wait (bt_top_m.CLK[1]==1'b0);
wait (bt_top_m.CLK[0]==1'b1);
wait (bt_top_m.pk_encode==1'b0);
//wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);

// 2nd py
// prepare new py
m_regi_payloadlen = 10'd5; //bytes
m_pyheader_l = {m_regi_payloadlen[4:0], 1'b1, 2'b10};
m_pyheader_h = {3'b0,m_regi_payloadlen[9:5]};
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 0, {8'h07,8'h06,m_pyheader_h, m_pyheader_l});
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 1, {8'h0a,8'h09,8'h08});
// send new py until ACK
wait (bt_top_m.linkctrler_u.corre_trgp);  //
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
//wait (bt_top_m.rxbit_period_endp);
//m_regi_packet_type = 4'd0;  //null packet
# 2678000;
m_regi_packet_type = 4'h3;  //DM1
    m_txcmd;
//


// after 3rd py
// prepare new py
@ (negedge bt_top_m.allbitp_u.bufctrl_u.regi_txs1a);  //
//wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 0, {8'h0c,8'h0b, m_pyheader_h, m_pyheader_l});
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 1, {8'h0f,8'h0e,8'h0d});
// send new py until ACK
wait (bt_top_m.linkctrler_u.corre_trgp);  //
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
//wait (bt_top_m.rxbit_period_endp);
//m_regi_packet_type = 4'd0;  //null packet
# 5678;
    m_txcmd;
//


//bsm read
#1234000;
for (m_ri=0; m_ri<100; m_ri=m_ri+1)
  begin
    m_bsm_rdat(m_ri);
  end  


// prepare new py
@ (posedge bt_top_m.allbitp_u.bufctrl_u.regi_txs1a);  //
//wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 0, {8'h1c,8'h1b, m_pyheader_h, m_pyheader_l});
m_bsm_wdat(o_adr, o_din, o_we, o_cs, 1, 1, {8'h1f,8'h1e,8'h1d});
// send new py until ACK
wait (bt_top_m.linkctrler_u.corre_trgp);  //
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
//wait (bt_top_m.rxbit_period_endp);
//m_regi_packet_type = 4'd0;  //null packet
# 5678;
    m_txcmd;
//
//

//

wait (bt_top_m.pk_encode==1'b0);
wait (bt_top_m.pk_encode==1'b1);
# 5678000;
m_regi_packet_type = 4'h1;
regi_LT_ADDR = 3'd3;
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
    m_txcmd;
//
wait (bt_top_m.pk_encode==1'b0);
wait (bt_top_m.pk_encode==1'b1);
# 5678000;
m_regi_packet_type = 4'h3;
regi_LT_ADDR = 3'd3;
//wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
    m_txcmd;

//bsm read
for (m_ri=0; m_ri<100; m_ri=m_ri+1)
  begin
    m_bsm_rdat(m_ri);
  end  

//
wait (bt_top_m.pk_encode==1'b0);
wait (bt_top_m.pk_encode==1'b1);
# 5678000;
m_regi_packet_type = 4'he;   //5-slots
regi_LT_ADDR = 3'd4;
    m_txcmd;
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);

//
wait (bt_top_m.pk_encode==1'b0);
wait (bt_top_m.pk_encode==1'b1);
# 5678000;
m_regi_packet_type = 4'h1;
regi_LT_ADDR = 3'd3;
wait (bt_top_m.allbitp_u.headerbitp_u.dec_arqn[regi_LT_ADDR]);
    m_txcmd;

end


//
integer s_i;
reg [7:0] s_pyheader_l,s_pyheader_h;
initial begin
regi_mylt_address = 3'd3;
wait (bt_top_s.linkctrler_u.cs==5'd5);
//regi_mylt_address = 3'd3;
//s_regi_packet_type = 4'd3;
//wait (bt_top_s.linkctrler_u.corre_trgp);  //
//wait (bt_top_s.rxbit_period_endp);  //1st , respnse with null
//@(negedge bt_top_s.rxbit_period_endp);  //2nd , response with data (master should send null)
//wait (bt_top_s.linkctrler_u.corre_trgp);  //
//
// LMP negosiation
s_regi_ptt = 1'b1;
//
s_regi_packet_type = 4'ha;
s_regi_payloadlen = 10'd55; //bytes
//
s_pyheader_l = {s_regi_payloadlen[4:0], 1'b1, 2'b10};
s_pyheader_h = {3'b0,s_regi_payloadlen[9:5]};
s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 0, {8'h02,8'h01,s_pyheader_h,s_pyheader_l});
//s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 1, {8'h05,8'h04,8'h03});
for (s_i=1;s_i<=s_regi_payloadlen[9:2];s_i=s_i+1)
  begin
    s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, s_i, {s_i+3,s_i+2,s_i+1,s_i});
  end  

// 1st reponse py
// slave need to manual switch in 1st packet
    chgbuf(0);
//    newdatready(0);
#1234;
s_regi_payloadlen = 10'd5; //bytes
s_pyheader_l = {s_regi_payloadlen[4:0], 1'b1, 2'b10};
s_pyheader_h = {3'b0,s_regi_payloadlen[9:5]};
s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 0, {8'h07,8'h06,s_pyheader_h,s_pyheader_l});
s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 1, {8'h0a,8'h09,8'h08});


// 2nd response, after receive ACK
// slave auto reponse
// 
wait (bt_top_s.linkctrler_u.corre_trgp);  //
wait (bt_top_s.allbitp_u.headerbitp_u.dec_arqn[regi_mylt_address]);
//wait (bt_top_s.linkctrler_u.corre_trgp);  //
//s_regi_packet_type = 4'ha; //DM3 3slots
@ (negedge bt_top_s.allbitp_u.bufctrl_u.regi_txs1a);  //
s_regi_payloadlen = 10'd15; //bytes
s_pyheader_l = {s_regi_payloadlen[4:0], 1'b1, 2'b10};
s_pyheader_h = {3'b0,s_regi_payloadlen[9:5]};
s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 0, {8'h0c,8'h0b,s_pyheader_h,s_pyheader_l});
s_bsm_wdat(o_adr, o_din, o_we, o_cs, 0, 1, {8'h0f,8'h0e,8'h0d});
end


// read rx acl buffer
integer s_ri;
initial begin
wait (bt_top_s.linkctrler_u.cs==5'd5);
//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u1empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  

//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u0empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  
//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u1empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  

//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u0empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  
//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u1empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  

//
wait (bt_top_s.allbitp_u.bufctrl_u.pyrxaclbufctrl_u.u0empty==1'b0);
//
for (s_ri=0; s_ri<100; s_ri=s_ri+1)
  begin
    s_bsm_rdat(s_ri);
  end  

end