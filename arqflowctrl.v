//
// Vol2 Part B sec 7.6 / 4.5.3 arq / flow control
//
module arqflowctrl(
clk_6M, rstz,
esco_LT_ADDR,
noCAC,
is_eSCO,
dec_hecgood, dec_micgood,
connsnewmaster, connsnewslave,
ms_lt_addr,
ms_tslot_p,
pk_encode,
dec_seqn,
dec_lt_addr,
lt_addressed,
allowedeSCOtype,
header_st_p,
dec_pktype, txpktype, regi_packet_type,
dec_flow,
dec_arqn,
prerx_notrans, dec_crcgood,
regi_flushcmd_p,
txcmd_p,
regi_aclrxbufempty,
//
txARQN,
txaclSEQN,
srctxpktype,
s_acltxcmd_p,
srcFLOW

);

input clk_6M, rstz;
input [2:0] esco_LT_ADDR;
input noCAC;
input is_eSCO;
input dec_hecgood, dec_micgood;
input connsnewmaster, connsnewslave;
input [2:0] ms_lt_addr;
input ms_tslot_p;
input pk_encode;
input dec_seqn;
input [2:0] dec_lt_addr;
input lt_addressed;
input allowedeSCOtype;
input header_st_p;
input [3:0] dec_pktype, txpktype, regi_packet_type;
input [7:0] dec_flow;
input [7:0] dec_arqn;
input prerx_notrans, dec_crcgood;
input regi_flushcmd_p;
input txcmd_p;
input regi_aclrxbufempty;
//
output [7:0] txARQN;
output [7:0] txaclSEQN;
output [3:0] srctxpktype;
output s_acltxcmd_p;
output srcFLOW;

wire dec_pktype_data, pktype_data;
reg [7:0] SEQN_old;

//destination control
//
assign rspFLOW = regi_aclrxbufempty;


wire dec_flow_device = dec_flow[dec_lt_addr];
//source control
//

assign srctxpktype = dec_flow_device ? regi_packet_type : 4'b0 ;
wire aclpacket = srctxpktype==4'h3 | srctxpktype==4'h4 | srctxpktype==4'h8 | srctxpktype==4'h9 | 
                 srctxpktype==4'ha | srctxpktype==4'hb | srctxpktype==4'he | srctxpktype==4'hf;
assign srcFLOW = dec_flow_device | prerx_notrans | !dec_crcgood | !aclpacket;



//
// TX arq ctrl
// Vol2 PartB Figure 7.15
//
assign pktype_data = txpktype==4'h3 | txpktype==4'h4 | txpktype==4'h8 | txpktype==4'ha | txpktype==4'hb | txpktype==4'he | txpktype==4'hf;

reg flushcmd_trg, flushcmd;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     flushcmd_trg <= 1'b0;
  else if (regi_flushcmd_p)
     flushcmd_trg <= 1'b1;
  else if (ms_tslot_p)  
     flushcmd_trg <= 1'b0 ;
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     flushcmd <= 1'b0;
  else if (flushcmd_trg & ms_tslot_p)
     flushcmd <= 1'b1;
  else if (dec_arqn[ms_lt_addr])  
     flushcmd <= 1'b0 ;
end
//wire [2:0] ms_lt_addr = regi_isMaster ? regi_LT_ADDR : regi_mylt_address;
wire sendnewpy = pk_encode & (!pktype_data | (pktype_data & dec_arqn[ms_lt_addr]));
wire sendoldpy = pk_encode &  pktype_data & !dec_arqn[ms_lt_addr] & !flushcmd;
wire send0cpy  = pk_encode &  pktype_data & !dec_arqn[ms_lt_addr] &  flushcmd;  // 0 length continue ACL-U packet

reg [7:0] txaclSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txaclSEQN <= 8'hff;
  else if (connsnewmaster | connsnewslave)
     txaclSEQN <= 8'hff;
  else if (txcmd_p)  // start tx cmd, from lnctrl
     txaclSEQN[ms_lt_addr] <= ~txaclSEQN[ms_lt_addr] ;
  else if (pk_encode & pktype_data & dec_arqn[ms_lt_addr] & header_st_p)
     txaclSEQN[ms_lt_addr] <= ~txaclSEQN[ms_lt_addr] ;
end

wire eSCOwindow_endp = 1'b0; //for tmp
wire eSCOwindow = 1'b0; //for tmp

reg txscoSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txscoSEQN <= 1'b1;
  else if (connsnewmaster | connsnewslave)
     txscoSEQN <= 1'b1;
  else if (eSCOwindow_endp)
     txscoSEQN <= ~txscoSEQN ;
end
//
// RX arq ctrl
// Vol2 PartB Figure 7.12
//
wire fail1 = noCAC | !dec_hecgood;
wire fail2 = !lt_addressed;
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
wire reject_aclpyload = condi_A & !esco_addressed & (
                                                  (dec_seqn!=SEQN_old[dec_lt_addr] & (!dec_crcgood | !dec_micgood)) |
                                                  (dec_seqn!=SEQN_old[dec_lt_addr] & dec_pktype_kk            ) |
                                                  (!dec_pktype_data & !dec_pktype_kk             )  
                                                 ) ;
//

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     SEQN_old <= 0;
  else if (accept_aclpyload & dec_py_endp_d1)
     SEQN_old[dec_lt_addr] <= dec_seqn ;
end


reg [7:0] txARQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txARQN <= 0;
  else if ((accept_eSCOpyload|ignore_eSCOpyload) & eSCOwindow)
     txARQN[dec_lt_addr] <= 1'b1 ;
  else if (reject_eSCOpyload & eSCOwindow)
     txARQN[dec_lt_addr] <= 1'b0 ;
//
  else if ((accept_aclpyload | ignore_aclpyload) & dec_py_endp_d1)
     txARQN[dec_lt_addr] <= 1'b1 ;
  else if ((reject_aclpyload | fail1 | (fail2 & regi_isMaster) ) & dec_py_endp_d1)
     txARQN[dec_lt_addr] <= 1'b0 ;
end

// receive packet from master
reg s_acltxcmd;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s_acltxcmd <= 0;
  else if ((accept_aclpyload | ignore_aclpyload) & dec_py_endp_d1 & !regi_isMaster)
     s_acltxcmd <= 1'b1 ;
  else if (s_tslot_p)
     s_acltxcmd <= 1'b0 ;
end

assign s_acltxcmd_p =  s_acltxcmd & s_tslot_p;
                      


endmodule
