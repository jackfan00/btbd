module headerbitp(
clk_6M, rstz, p_1us,
pylenbit,
ms_lt_addr,
s_tslot_p, ms_tslot_p,
pagetxfhs, istxfhs, connsnewmaster, connsnewslave,
page, inquiry, conns, ps, mpr, spr, ir,
rx_trailer_st_p,
tx_packet_st_p,
packet_BRmode, 
regi_isMaster,
regi_txwhitening, regi_rxwhitening,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_LT_ADDR, regi_mylt_address,
regi_packet_type,
//regi_FLOW, regi_ARQN, regi_SEQN,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
Xprm, Xir, Xprs,
CLK,          
py_period, daten, py_datvalid_p,
dec_py_period,
pk_encode,
srctxpktype,
txaclSEQN, txARQN,
srcFLOW, rspFLOW,
rxbit,
//
guard_st_p, edrsync11_st_p, py_st_p,
txheaderbit,
whitening,
header_packet_period,
rxispoll,
dec_pk_type,
lt_addressed,
txpktype,
dec_lt_addr,
dec_flow, dec_arqn,
header_st_p,
dec_hecgood,
dec_seqn

);

input clk_6M, rstz, p_1us;
input [12:0] pylenbit;
input [2:0] ms_lt_addr;
input s_tslot_p, ms_tslot_p;
input pagetxfhs, istxfhs, connsnewmaster, connsnewslave;
input page, inquiry, conns, ps, mpr, spr, ir;
input rx_trailer_st_p;
input tx_packet_st_p;
input packet_BRmode;
input regi_isMaster;
input regi_txwhitening, regi_rxwhitening;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [2:0] regi_LT_ADDR, regi_mylt_address;
input [3:0] regi_packet_type;
//input regi_FLOW, regi_ARQN, regi_SEQN;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input py_period, daten, py_datvalid_p;
input dec_py_period;
input pk_encode;
input [3:0] srctxpktype;
input [7:0] txaclSEQN, txARQN;
input [7:0] srcFLOW;
input rspFLOW;
input rxbit;
//
output guard_st_p, edrsync11_st_p, py_st_p;
output txheaderbit;
output [6:0] whitening;
output header_packet_period;
output rxispoll;
output [3:0] dec_pk_type;
output lt_addressed;
output [3:0] txpktype;
output [2:0] dec_lt_addr;
output [7:0] dec_flow, dec_arqn;
output header_st_p;
output dec_hecgood;
output dec_seqn;

wire packet_endp;
reg header_packet_period;
wire preamble_en, syncword_en, trailer_en, header_en, hec_en;
wire [63:0] syncword;
wire fec31inc_p;
reg [3:0] header_bitcount;
reg [1:0] fec31count;
wire hecencodebit;
wire pkheader_bitin;
reg [2:0] dec_lt_addr;

reg [7:0] all_bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     all_bitcount <= 8'hff;
  else if ((packet_endp)  & p_1us)
     all_bitcount <= 8'hff;
  else if (rx_trailer_st_p & p_1us)
     all_bitcount <= 8'd69;
  else if (tx_packet_st_p & p_1us)
     all_bitcount <= 8'h0;
  else if (header_packet_period & p_1us)
     all_bitcount <= all_bitcount + 1'b1 ;
end

assign packet_endp = page ? all_bitcount==8'd67  :
                   spr ? all_bitcount==8'd67 :
                   inquiry ? all_bitcount==8'd67 : 
                   packet_BRmode ? all_bitcount==8'd125 :  // header(54)
                             all_bitcount==8'd141 ;  //EDR, guard(5)+sync(11)
                   
assign preamble_en = all_bitcount<=8'd3 ;
assign syncword_en = all_bitcount>8'd3 & all_bitcount<=8'd67 ;
assign trailer_en = (all_bitcount>8'd67) & (all_bitcount<=8'd71) ;
assign header_en = (all_bitcount>8'd71) & (all_bitcount<=8'd101);
assign hec_en = (all_bitcount>8'd101) & (all_bitcount<=8'd125);

assign header_st_p = (all_bitcount==8'd71) & p_1us;
assign guard_st_p = packet_BRmode ? 1'b0 : (all_bitcount==8'd125) & p_1us;
assign edrsync11_st_p = packet_BRmode ? 1'b0 : (all_bitcount==8'd130) & p_1us;

assign py_st_p = !(srcFLOW[ms_lt_addr]) & pk_encode ? 1'b0 :   // flow=STOP, dont send payload
                 packet_BRmode ? (all_bitcount==8'd125) & p_1us : (all_bitcount==8'd141) & p_1us;

wire hec_endp = packet_BRmode ? (all_bitcount==8'd125) & p_1us : (all_bitcount==8'd141) & p_1us;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_packet_period <= 0;
  else if (packet_endp & p_1us)
     header_packet_period <= 0;
  else if (tx_packet_st_p & p_1us)
     header_packet_period <= 1'b1 ;
  else if (rx_trailer_st_p & p_1us)
     header_packet_period <= 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_bitcount <= 0;
  else if (header_st_p)
     header_bitcount <= 0;
  else if (header_en & p_1us & fec31inc_p)
     header_bitcount <= header_bitcount + 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec31count <= 0;
  else if ((fec31count==2'd2 & p_1us) | (!(header_en|hec_en)))
     fec31count <= 0;
  else if ((header_en|hec_en) & p_1us)
     fec31count <= fec31count + 1'b1 ;
end

assign fec31inc_p = fec31count==2'd2 & p_1us;


//
wire [3:0] txpktype = mpr | istxfhs ? 4'b0010 :   //fhs
                    connsnewmaster ? 4'b0001 :    //poll
                    connsnewslave ? 4'b0000 :    //null
                    conns ? srctxpktype : 4'b0; //regi_packet_type;

// slave: should be response in next slot with current regi_mylt_address
wire [2:0] txpk_lt_addr = regi_isMaster ? regi_LT_ADDR : regi_mylt_address;

wire txpk_seqn = conns ? txaclSEQN[txpk_lt_addr] : 1'b1;
wire txpk_arqn = conns ? txARQN[txpk_lt_addr] : 1'b0;
wire txpk_flow = conns ? rspFLOW : 1'b1;
wire [9:0] txpacket_header = {txpk_seqn,txpk_arqn,txpk_flow,txpktype,txpk_lt_addr};


assign pkheader_bitin = txpacket_header[header_bitcount];

assign syncword = conns ? regi_syncword_CAC :
                  page | ps | mpr | spr ? regi_syncword_DAC : 
                  regi_inquiryDIAC ? regi_syncword_DIAC : regi_syncword_GIAC;

// syncword format is LSB leftmost
assign txheaderbit = preamble_en ? (syncword[63] ? !all_bitcount[0] : all_bitcount[0]) :
               syncword_en ? syncword[8'd63-all_bitcount+3'd4] :
               trailer_en ?  (syncword[0] ? all_bitcount[0] : !all_bitcount[0]) :
               header_en|hec_en ? hecencodebit : 1'b0;


wire [7:0] hecrem;

wire whitening_enable = pk_encode ? regi_txwhitening : regi_rxwhitening;
headerpro headerpro_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.pk_encode              (pk_encode              ),
.regi_whitening         (whitening_enable       ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.spr                    (spr                    ), 
.ir                     (ir                     ),
.header_st_p            (header_st_p            ), 
.header_en              (header_en              ), 
.hec_en                 (hec_en                 ),
.hec_endp               (hec_endp               ),
.fec31inc_p             (fec31inc_p             ),
.py_period              (py_period              ), 
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.dec_py_period          (dec_py_period          ),
.pkheader_bitin         (pkheader_bitin         ), 
.dec_headerbit          (rxbit                  ),
.Xprm                   (Xprm                   ),
.Xir                    (Xir                    ),
.Xprs                   (Xprs                   ),
.CLK                    (CLK                    ),
//                     (//                     )
.encodeout              (hecencodebit           ),
.decodeout              (decodeout              ),
.whitening              (whitening              ),
.hecrem                 (hecrem                 )

);

//
reg ckhec;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     ckhec <= 0;
  else if (hec_endp & p_1us & (!pk_encode))
     ckhec <=  1'b1 ;
  else if (p_1us)
     ckhec <= 1'b0;
end
reg dec_hecgood;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_hecgood <= 0;
  else if (ckhec & p_1us)
     dec_hecgood <=  (hecrem==8'h0) ;
end

//


always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_lt_addr <= 0;
  else if (header_bitcount<=5'd2 & fec31inc_p & header_en & (!pk_encode))
     dec_lt_addr <= {decodeout,dec_lt_addr[2:1]};
end

//wire ms_tslot_p = regi_isMaster ? m_tslot_p : s_slot_p;
//wire [2:0] ms_lt_addr = regi_isMaster ? regi_LT_ADDR : regi_mylt_address;
reg lt_addressed;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     lt_addressed <= 0;
  else if (ms_tslot_p | pk_encode)
     lt_addressed <= 0;
  else if (ckhec & p_1us)
     lt_addressed <=  (hecrem==8'h0) & (dec_lt_addr==ms_lt_addr) ;  //header good and match lt_address
end

wire headvalid_p = ckhec & p_1us & (hecrem==8'h0) & (dec_lt_addr==ms_lt_addr);

reg [3:0] dec_pk_type;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_pk_type <= 0;
  else if (header_bitcount>5'd2 & header_bitcount<=5'd6 & fec31inc_p & header_en & (!pk_encode))
     dec_pk_type <= {decodeout,dec_pk_type[3:1]};
end

reg [7:0] dec_flow_t, dec_arqn_t;
reg [7:0] dec_flow, dec_arqn;
reg dec_seqn;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_flow_t <= 8'hff;
  else if (header_bitcount==5'd7 & fec31inc_p & header_en & (!pk_encode))
     dec_flow_t[dec_lt_addr] <= {decodeout};
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_arqn_t <= 0;
  else if (header_bitcount==5'd8 & fec31inc_p & header_en & (!pk_encode))
     dec_arqn_t[dec_lt_addr] <= {decodeout};
end


always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
      dec_flow <= 8'hff;
      dec_arqn <= 0;
    end  
  else if (headvalid_p)
    begin
      dec_flow <= dec_flow_t;
      dec_arqn <= dec_arqn_t;
    end  
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_seqn <= 0;
  else if (header_bitcount==5'd9 & fec31inc_p & header_en & (!pk_encode))
     dec_seqn <= {decodeout};
end

assign rxisnull = dec_pk_type==4'b0000;
assign rxispoll = dec_pk_type==4'b0001;
assign rxisfhs  = dec_pk_type==4'b0010;

endmodule
