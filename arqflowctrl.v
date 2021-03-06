//
// Vol2 Part B sec 7.6 / 4.5.3 arq / flow control
//
module arqflowctrl(
clk_6M, rstz,
txpk_flow,
m_2active_p, s_2active_p,
conns_rx1stslot,
corre_nottrg_p,
txpk_lt_addr,
flow_stop_start,
ckheader_endp,
regi_txdatready,
ms_TXslot_endp, ms_RXslot_endp,
regi_chgbufcmd_p,
regi_isMaster,
dec_py_endp,
esco_LT_ADDR,
rxCAC,
is_eSCO,
dec_hecgood, dec_micgood,
conns, connsnewmaster, connsnewslave,
ms_lt_addr,
ms_tslot_p, s_tslot_p,
pk_encode,
dec_seqn,
dec_lt_addr,
lt_addressed,
allowedeSCOtype,
header_st_p,
dec_pktype, txpktype, regi_packet_type,
dec_flow,
dec_arqn,
prerx_trans, dec_crcgood,
regi_flushcmd_p,
ms_txcmd_p,
regi_aclrxbufempty,
//
txARQN,
txaclSEQN,
srctxpktype,
ms_acltxcmd_p,
srcFLOW,
rspFLOW,
pktype_data,
SEQN_old,
sendnewpy, sendoldpy, send0py,
dec_py_endp_d1,
txpktype_data

);

input clk_6M, rstz;
input txpk_flow;
input m_2active_p, s_2active_p;
input conns_rx1stslot;
input corre_nottrg_p;
input [2:0] txpk_lt_addr;
input [7:0] flow_stop_start;
input ckheader_endp;
input regi_txdatready;
input ms_TXslot_endp, ms_RXslot_endp;
input regi_chgbufcmd_p;
input regi_isMaster;
input dec_py_endp;
input [2:0] esco_LT_ADDR;
input rxCAC;
input is_eSCO;
input dec_hecgood, dec_micgood;
input conns, connsnewmaster, connsnewslave;
input [2:0] ms_lt_addr;
input ms_tslot_p, s_tslot_p;
input pk_encode;
input dec_seqn;
input [2:0] dec_lt_addr;
input lt_addressed;
input allowedeSCOtype;
input header_st_p;
input [3:0] dec_pktype, txpktype, regi_packet_type;
input [7:0] dec_flow;
input [7:0] dec_arqn;
input prerx_trans, dec_crcgood;
input regi_flushcmd_p;
input ms_txcmd_p;
input regi_aclrxbufempty;
//
output [7:0] txARQN;
output [7:0] txaclSEQN;
output [3:0] srctxpktype;
output ms_acltxcmd_p;
output [7:0] srcFLOW;
output rspFLOW;
output pktype_data;
output [7:0] SEQN_old;
output sendnewpy, sendoldpy, send0py;
output [1:0] dec_py_endp_d1;
output txpktype_data;

wire dec_pktype_data, txpktype_data;
reg [7:0] SEQN_old;
reg [1:0] dec_py_endp_d1;

assign pktype_data = pk_encode ? txpktype_data : dec_pktype_data;
//destination control
//
assign rspFLOW = regi_aclrxbufempty;




wire dec_flow_device = dec_flow[dec_lt_addr];
//source control
//

assign srctxpktype = dec_flow_device ? regi_packet_type : 4'b0 ;   //& regi_txdatready
wire aclpacket = srctxpktype==4'h3 | srctxpktype==4'h4 | srctxpktype==4'h8 | srctxpktype==4'h9 | 
                 srctxpktype==4'ha | srctxpktype==4'hb | srctxpktype==4'he | srctxpktype==4'hf;
////////wire srcFLOW_t = dec_flow_device | !prerx_trans | !dec_crcgood | !aclpacket;
////////
////////reg [7:0] srcFLOW;
////////always @(posedge clk_6M or negedge rstz)
////////begin
////////  if (!rstz)
////////     srcFLOW <= 8'hff;
////////  else if (connsnewmaster | connsnewslave)
////////     srcFLOW <= 8'hff;
////////  else if (ms_tslot_p & (!pk_encode))
////////     srcFLOW[ms_lt_addr] <= srcFLOW_t ;
////////end

//
// TX arq ctrl
// Vol2 PartB Figure 7.15
//
assign txpktype_data = txpktype==4'h3 | txpktype==4'h4 | txpktype==4'h8 | txpktype==4'ha | txpktype==4'hb | txpktype==4'he | txpktype==4'hf;

////////reg flushcmd_trg, flushcmd;
////////always @(posedge clk_6M or negedge rstz)
////////begin
////////  if (!rstz)
////////     flushcmd_trg <= 1'b0;
////////  else if (regi_flushcmd_p)
////////     flushcmd_trg <= 1'b1;
////////  else if (ms_tslot_p)  
////////     flushcmd_trg <= 1'b0 ;
////////end

wire regw_flushcmd = 1'b0;//for tmp
reg flushcmd_flag;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     flushcmd_flag <= 1'b0;
  else if (regw_flushcmd)
     flushcmd_flag <= 1'b1;
  else if (ms_TXslot_endp)  
     flushcmd_flag <= 1'b0 ;
end

// Spec : Figure 7.15, tx slot
// Vol2 PartB 4.5.3.2 : in case flow stop then start, should re-transmit old pyload
// 
assign sendnewpy = conns & ( //!txpktype_data | , sco case
                             (txpktype_data & dec_arqn[txpk_lt_addr] & 
                               (dec_flow[txpk_lt_addr] & !flow_stop_start[txpk_lt_addr])
                             )
                           );
assign sendoldpy = !sendnewpy & !flushcmd_flag &  txpktype_data; //conns &  txpktype_data & (!dec_arqn[txpk_lt_addr] | !dec_flow[txpk_lt_addr]) & !flushcmd_flag;
assign send0py   = !sendnewpy & flushcmd_flag &  txpktype_data; //conns &  txpktype_data & !dec_arqn[txpk_lt_addr] &  flushcmd_flag;  // 0 length continue ACL-U packet

reg [7:0] txaclSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txaclSEQN <= 8'h0;
  else if (m_2active_p) //connsnewmaster | connsnewslave)
     txaclSEQN <= 8'hff;
  else if (s_2active_p) //connsnewmaster | connsnewslave)
     txaclSEQN <= 8'hff;
//  else if (regi_chgbufcmd_p)  // mcu check dec_arqn[ms_lt_addr] to determine switch buffer or not
//     txaclSEQN[ms_lt_addr] <= ~txaclSEQN[ms_lt_addr] ;
// Spec : Figure 7.15
//  else if (pk_encode & txpktype_data & dec_arqn[txpk_lt_addr] & header_st_p)
//     txaclSEQN[txpk_lt_addr] <= ~txaclSEQN[txpk_lt_addr] ;

  else if (!pk_encode & txpktype_data & dec_arqn[txpk_lt_addr] & ckheader_endp & dec_hecgood)
     txaclSEQN[txpk_lt_addr] <= ~txaclSEQN[txpk_lt_addr] ;
end

wire eSCOwindow_endp = 1'b0; //for tmp
wire eSCOwindow = 1'b0; //for tmp

reg txscoSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txscoSEQN <= 1'b1;
  else if (s_2active_p | m_2active_p) //connsnewmaster | connsnewslave)
     txscoSEQN <= 1'b1;
  else if (eSCOwindow_endp)
     txscoSEQN <= ~txscoSEQN ;
end
//
// RX arq ctrl
// Vol2 PartB Figure 7.12
//
wire fail1 = !rxCAC | !dec_hecgood;
wire fail2 = (!fail1) & !lt_addressed;
wire esco_addressed = dec_lt_addr == esco_LT_ADDR;
assign dec_pktype_data = dec_pktype==4'h3 | dec_pktype==4'h4 | dec_pktype==4'h8 | dec_pktype==4'ha | dec_pktype==4'hb | dec_pktype==4'he | dec_pktype==4'hf;
wire dec_pktype_kk = dec_pktype==4'h0 | dec_pktype==4'h1 | dec_pktype==4'h9 | dec_pktype==4'h5 | (dec_pktype==4'h6 & !is_eSCO) | (dec_pktype==4'h7 & !is_eSCO);

wire condi_A = (!fail1) & (!fail2) ;

wire condi_B = condi_A & esco_addressed;

reg rxeSCOvalid_pyload;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxeSCOvalid_pyload <= 0;
  else if ((!pk_encode) & dec_hecgood & dec_crcgood & eSCOwindow & ms_tslot_p)
     rxeSCOvalid_pyload <= 1'b1 ;
  else if (!eSCOwindow)
     rxeSCOvalid_pyload <= 1'b0 ;
end

wire rxeSCOpacketOK = rxeSCOvalid_pyload & allowedeSCOtype;

wire accept_eSCOpyload = condi_B & !rxeSCOvalid_pyload & rxeSCOpacketOK;
wire ignore_eSCOpyload = condi_B &  rxeSCOvalid_pyload ;
wire reject_eSCOpyload = condi_B & !rxeSCOvalid_pyload & !rxeSCOpacketOK;



wire accept_aclpyload = condi_A & !esco_addressed & dec_pktype_data & dec_seqn!=SEQN_old[dec_lt_addr] & dec_crcgood & dec_micgood;

wire ignore_aclpyload = condi_A & !esco_addressed & dec_pktype_data & dec_seqn==SEQN_old[dec_lt_addr];
wire reject_aclpyload_0 = condi_A & !esco_addressed & (
                                                  (dec_seqn!=SEQN_old[dec_lt_addr] & (!dec_crcgood | !dec_micgood)) 
                                                 // (dec_seqn!=SEQN_old[dec_lt_addr] & dec_pktype_kk            ) |
                                                 // (!dec_pktype_data & !dec_pktype_kk             )  
                                                 ) ;
wire reject_aclpyload_1 = condi_A & !esco_addressed & (
                                                  //(dec_seqn!=SEQN_old[dec_lt_addr] & (!dec_crcgood | !dec_micgood)) |
                                                  (dec_seqn!=SEQN_old[dec_lt_addr] & dec_pktype_kk            ) |
                                                  (!dec_pktype_data & !dec_pktype_kk             )  
                                                 ) ;

//
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_py_endp_d1 <= 0;
  else 
     dec_py_endp_d1 <= {dec_py_endp_d1[0],dec_py_endp} ;
end

wire reg_wr_sqen=1'b0; //for tmp
wire reg_wr_arqn=1'b0; //for tmp
wire [7:0] reg_wdata=8'h0; //for tmp

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     SEQN_old <= 8'h0;  //ff
  // mcu overwrite, EX:eSCO link setup
  else if (reg_wr_sqen)
     SEQN_old <= reg_wdata;
//  else if (connsnewmaster)
//     SEQN_old[ms_lt_addr] <= 1'b1;
//  else if (connsnewslave)
//     SEQN_old[ms_lt_addr] <= 1'b1;
  else if (accept_aclpyload & dec_py_endp_d1[1])
     SEQN_old[dec_lt_addr] <= dec_seqn ;
end

// RX slot ARQ scheme
// SPEC Vol 2, Part B, Sec 7.6, Figure 7.12 7.13
reg [7:0] txARQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txARQN <= 0;
  // mcu overwrite, EX:eSCO link setup
  else if (reg_wr_arqn)
     txARQN <= reg_wdata;
  // master initial ARQN=NAK   
  else if (m_2active_p) //connsnewmaster & header_st_p)  // initial ARQN=NAK just before 1st tx
     txARQN[txpk_lt_addr] <= 1'b0;
  // slave initial ARN=NAK   
  else if (s_2active_p) //connsnewslave & header_st_p)   // initial ARQN=NAK just before 1st tx
     txARQN[txpk_lt_addr] <= 1'b0;
     
  // Spec Figure 7.12
  // master: RX slot address should be same as TX slot address
  else if (corre_nottrg_p & conns_rx1stslot & conns & regi_isMaster)  // not trigger
     txARQN[txpk_lt_addr] <= 1'b0;
  else if ((fail1|fail2) & conns & ckheader_endp & regi_isMaster)  // HEC error
     txARQN[txpk_lt_addr] <= 1'b0;
  //   
  //slave : if not receive valid packet at any rx slot, all address set to NAK.
  // because any address is possible miss   
  else if (corre_nottrg_p & conns & !regi_isMaster) // not trigger, diff condition from master
     txARQN <= 8'b0;
  else if (!dec_hecgood & conns & ckheader_endp & !regi_isMaster) // HEC error
     txARQN <= 8'b0;
// keep previous ack value
//  else if (fail2 & ckheader_endp & !regi_isMaster)
//     txARQN <= txARQN;
     
// sco
  else if ((accept_eSCOpyload|ignore_eSCOpyload) & eSCOwindow)
     txARQN[dec_lt_addr] <= 1'b1 ;
  else if (reject_eSCOpyload & eSCOwindow)
     txARQN[dec_lt_addr] <= 1'b0 ;

// acl : addressed case
// if resp-packet is null, which no pyload and dont meet following condition
// so keep old txARQN
// if flow==0, treat as not accept
  else if ((accept_aclpyload) & conns & dec_py_endp_d1[1]) // 
     txARQN[dec_lt_addr] <= txpk_flow; //1'b1 ;
  else if ((ignore_aclpyload) & conns & ckheader_endp)  // dont consider crc/mic good
     txARQN[dec_lt_addr] <= 1'b1 ;
//
  else if ((reject_aclpyload_0 ) & conns & dec_py_endp_d1[1])
     txARQN[dec_lt_addr] <= 1'b0 ;
  else if ((reject_aclpyload_1 ) & conns & ckheader_endp)
     txARQN[dec_lt_addr] <= 1'b0 ;
end

// receive packet from master
//////reg s_acltxcmd;
//////always @(posedge clk_6M or negedge rstz)
//////begin
//////  if (!rstz)
//////     s_acltxcmd <= 0;
//////  else if ((accept_aclpyload | ignore_aclpyload) & dec_py_endp_d1 & !regi_isMaster)
//////     s_acltxcmd <= 1'b1 ;
//////  else if (s_tslot_p)
//////     s_acltxcmd <= 1'b0 ;
//////end

//Spec : Figure 7.12, 7.13
wire reserved_slot = 1'b0; //for tmp
assign ms_acltxcmd_p = fail1 & (!regi_isMaster) & (!reserved_slot) ? 1'b0 : 
                       fail2 & (!regi_isMaster) ? 1'b0 : ms_RXslot_endp;  //s_acltxcmd & s_tslot_p;
                      

endmodule
