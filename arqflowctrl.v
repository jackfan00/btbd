//
// Vol2 Part B sec 7.6 / 4.5.3 arq / flow control
//
module arqflowctrl();

input clk_6M, rstz;
input pk_encode;
input lt_addressed;
input allowedeSCOtype;
input header_st_p;
input [3:0] pktype;
input dec_STOP, pre_notrans, dec_crcgood;
input flushcmd;
output ACK;
output txSEQN;

wire pktype_data;

//destination control
//
assign rspFLOW = aclrxbufempty;


//source control
//
assign srctxpktype = dec_STOP ? 4'b0 : pktype;
assign srcFLOW = !dec_STOP | pre_notrans | !dec_crcgood |!aclpacket;


wire pktype_data, ACK;
//
// TX arq ctrl
// Vol2 PartB Figure 7.15
//

wire sendnewpy = pk_encode & !pktype_data | (pktype_data & ACK);
wire sendoldpy = pk_encode &  pktype_data & !ACK & !flushcmd;
wire send0cpy  = pk_encode &  pktype_data & !ACK &  flushcmd;  // 0 length continue ACL-U packet

reg txaclSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txaclSEQN <= 1'b1;
  else if (connsnewmaster | connsnewslave)
     txaclSEQN <= 1'b1;
  else if (pk_encode & pktype_data & ACK & header_st_p)
     txaclSEQN <= ~txaclSEQN ;
end

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
wire fail1 = noCAC | !hecgood;
wire fail2 = !lt_addressed;
wire esco_addressed = dec_LT_ADDR == esco_LT_ADDR;
wire pktype_data = pktype==4'h3 | pktype==4'h4 | pktype==4'h8 | pktype==4'ha | pktype==4'hb | pktype==4'he | pktype==4'hf;
wire pktype_kk = pktype==4'h0 | pktype==4'h1 | pktype==4'h9 | pktype==4'h5 | (pktype==4'h6 & !is_eSCO) | (pktype==4'h7 & !is_eSCO);

wire condi_A = (!fail1) & (!fail2) ;

wire condi_B = condi_A & esco_addressed;

reg rxeSCOvalid_pyload;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxeSCOvalid_pyload <= 0;
  else if ((!pk_encode) & hecgood & crcgood & eSCOwindow & s_tslot_p)
     rxeSCOvalid_pyload <= 1'b1 ;
  else if (!eSCOwindow)
     rxeSCOvalid_pyload <= 1'b0 ;
end

wire rxeSCOpacketOK = rxeSCOvalid_pyload & allowedeSCOtype;

wire accept_eSCOpyload = condi_B & !rxeSCOvalid_pyload & rxeSCOpacketOK;
wire ignore_eSCOpyload = condi_B &  rxeSCOvalid_pyload ;
wire reject_eSCOpyload = condi_B & !rxeSCOvalid_pyload & !rxeSCOpacketOK;

reg SEQN_old;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     SEQN_old <= 0;
  else if (accept_pyload )
     SEQN_old <= dec_SEQN ;
end

wire accept_aclpyload = condi_A & !esco_addressed & pktype_data & dec_SEQN!=SEQN_old & crcgood & micgood;
wire ignore_aclpyload = condi_A & !esco_addressed & pktype_data & dec_SEQN==SEQN_old;
wire reject_aclpyload = condi_A & !esco_addressed & (
                                                  (dec_SEQN!=SEQN_old & (!crcgood | !micgood)) |
                                                  (dec_SEQN!=SEQN_old & pktype_kk            ) |
                                                  (!pktype_data & !pktype_kk             )  
                                                 ) ;

reg ACK;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     ACK <= 0;
  else if ((accept_eSCOpyload|ignore_eSCOpyload) & eSCOwindow)
     ACK <= 1'b1 ;
  else if (reject_eSCOpyload & eSCOwindow)
     ACK <= 1'b0 ;
//
  else if (accept_aclpyload | ignore_aclpyload )
     ACK <= 1'b1 ;
  else if ( reject_aclpyload | fail1 | (fail2 & regi_isMaster) )
     ACK <= 1'b0 ;
end



endmodule
