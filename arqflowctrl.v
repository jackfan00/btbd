//
// Vol2 Part B sec 4.5.3 flow control
//
module arqflowctrl();


//destination control
//
assign dstSTOP = !aclrxbufempty;


//source control
//
assign srctxpktype = dec_STOP ? 4'b0 : regi_pktype;
assign srcGO = !dec_STOP | !packetreceived;


wire pktype_data, ACK;
//
// TX arq ctrl
// Vol2 PartB Figure 7.15
//

wire sendnewpy = !pktype_data | (pktype_data & ACK);
wire sendoldpy =  pktype_data & !ACK & !flushcmd;
wire send0cpy  =  pktype_data & !ACK &  flushcmd;  // 0 length continue ACL-U packet

reg txSEQN;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     txSEQN <= 0;
  else if (pktype_data & ACK & header_st_p)
     txSEQN <= ~txSEQN ;
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

wire condi_A = (!fail1 & !fail2 ) ;

wire condi_B = condi_A & esco_addressed;

reg rxeSCOvalid_pyload;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxeSCOvalid_pyload <= 0;
  else if (hecgood & crcgood & eSCOwindow & s_tslot_p)
     rxeSCOvalid_pyload <= 1'b1 ;
  else if (eSCOwindow)
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
  else if ((accept_eSCOpyload|ignore_eSCOpyload) )
     ACK <= 1'b1 ;
  else if (reject_eSCOpyload)
     ACK <= 1'b0 ;
//
  else if (accept_aclpyload )
     ACK <= 1'b1 ;
  else if ((reject_aclpyload|fail1) )
     ACK <= 1'b0 ;
end



endmodule
