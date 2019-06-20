module txheaderbitp(
clk_6M, rstz, p_1us,
pagetxfhs, connsnewmaster,
page, inquiry, conns, ps, mpr, spr, ir,
tx_packet_st_p,
packet_BRmode, 
regi_txwhitening,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_LT_ADDR,
regi_packet_type,
regi_FLOW, regi_ARQN, regi_SEQN,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
Xprm, Xir, Xprs,
CLK,          
py_period, daten, py_datvalid_p,
//
guard_st_p, edrsync11_st_p, py_st_p,
txheaderbit,
whitening,
header_packet_period
);

input clk_6M, rstz, p_1us;
input pagetxfhs, connsnewmaster;
input page, inquiry, conns, ps, mpr, spr, ir;
input tx_packet_st_p;
input packet_BRmode;
input regi_txwhitening;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [2:0] regi_LT_ADDR;
input [3:0] regi_packet_type;
input regi_FLOW, regi_ARQN, regi_SEQN;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input py_period, daten, py_datvalid_p;
//
output guard_st_p, edrsync11_st_p, py_st_p;
output txheaderbit;
output [6:0] whitening;
output header_packet_period;


wire packet_endp;
reg header_packet_period;
wire preamble_en, syncword_en, trailer_en, header_en, hec_en;
wire [63:0] syncword;
wire fec31inc_p;
reg [3:0] header_bitcount;
reg [1:0] fec31count;
wire hecencodebit;
wire pkheader_bitin;

reg [7:0] all_bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     all_bitcount <= 8'hff;
  else if ((packet_endp)  & p_1us)
     all_bitcount <= 8'hff;
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

assign py_st_p = packet_BRmode ? (all_bitcount==8'd125) & p_1us : (all_bitcount==8'd141) & p_1us;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_packet_period <= 0;
  else if (packet_endp & p_1us)
     header_packet_period <= 0;
  else if (tx_packet_st_p & p_1us)
     header_packet_period <= 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_bitcount <= 0;
  else if (all_bitcount==8'd0 & p_1us)
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
wire [3:0] txpktype = pagetxfhs ? 4'b0010 :   //fhs
                    connsnewmaster ? 4'b0001 :    //poll
                    regi_packet_type;
wire [9:0] packet_header = {regi_SEQN,regi_ARQN,regi_FLOW,txpktype,regi_LT_ADDR};


assign pkheader_bitin = packet_header[header_bitcount];

assign syncword = conns ? regi_syncword_CAC :
                  page | ps | mpr | spr ? regi_syncword_DAC : 
                  regi_inquiryDIAC ? regi_syncword_DIAC : regi_syncword_GIAC;

// syncword format is LSB leftmost
assign txheaderbit = preamble_en ? (syncword[63] ? !all_bitcount[0] : all_bitcount[0]) :
               syncword_en ? syncword[8'd63-all_bitcount+3'd4] :
               trailer_en ?  (syncword[0] ? all_bitcount[0] : !all_bitcount[0]) :
               header_en|hec_en ? hecencodebit : 1'b0;


headerpro headerpro_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.pk_encode              (1'b1                   ),
.regi_whitening         (regi_txwhitening       ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.spr                    (spr                    ), 
.ir                     (ir                     ),
.header_st_p            (header_st_p            ), 
.header_en              (header_en              ), 
.hec_en                 (hec_en                 ),
.py_st_p                (py_st_p                ),
.fec31inc_p             (fec31inc_p             ),
.py_period              (py_period              ), 
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.dec_py_period          (1'b0                   ),
.pkheader_bitin         (pkheader_bitin         ), 
.dec_headerbit          (1'b0                   ),
.Xprm                   (Xprm                   ),
.Xir                    (Xir                    ),
.Xprs                   (Xprs                   ),
.CLK                    (CLK                    ),
//                     (//                     )
.encodeout              (hecencodebit           ),
.whitening              (whitening              )

);






endmodule