module rxheaderbit(
clk_6M, rstz, p_1us,
regi_rxwhitening,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
mpr, ir, spr,
rx_trailer_st_p,
psrxfhs, inquiryrxfhs, conns,
packet_BRmode,
Xprm, Xir, Xprs,
CLK,
dec_py_period, daten, py_datvalid_p,
dec_pylenByte,
dec_pylenbit,
rxbit,
//
header_en, header_st_p, edrsync11_st_p, guard_st_p, py_st_p,
rxispoll, rxisnull, rxisfhs,
whitening,
dec_pk_type

);

input clk_6M, rstz, p_1us;
input regi_rxwhitening;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input mpr, ir, spr;
input rx_trailer_st_p;
input psrxfhs, inquiryrxfhs, conns;
input packet_BRmode;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input dec_py_period, daten, py_datvalid_p;
input [9:0] dec_pylenByte;
input [12:0] dec_pylenbit;
input rxbit;
//
output header_en, header_st_p, edrsync11_st_p, guard_st_p, py_st_p;
output rxispoll, rxisnull, rxisfhs;
output [6:0] whitening;
output [3:0] dec_pk_type;

wire packet_endp;
reg header_packet_period;
wire [7:0] hec;

reg [7:0] all_bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     all_bitcount <= 8'hff;
  else if ((packet_endp)  & p_1us)
     all_bitcount <= 8'hff;
  else if (rx_trailer_st_p & p_1us)
     all_bitcount <= 8'h1;
  else if (header_packet_period & p_1us)
     all_bitcount <= all_bitcount + 1'b1 ;
end


always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_packet_period <= 0;
  else if (packet_endp & p_1us)
     header_packet_period <= 0;
  else if (rx_trailer_st_p & p_1us)
     header_packet_period <= 1'b1 ;
end


assign packet_endp = psrxfhs | inquiryrxfhs ? all_bitcount==8'd57  :   // tralier(4) + header(54)
                     conns & packet_BRmode ? all_bitcount==8'd57 :  // tralier(4) + header(54)
                             all_bitcount==8'd73 ;  //EDR, tralier(4) + header(54) + guard(5)+sync(11)

assign header_en   = header_packet_period & (all_bitcount > 8'd3) && (all_bitcount <= 8'd33);
assign hec_en   = header_packet_period & (all_bitcount > 8'd33) && (all_bitcount <= 8'd57);
assign header_st_p = header_packet_period & (all_bitcount==8'd3)  & p_1us;

assign guard_st_p = packet_BRmode ? 1'b0 : (all_bitcount==8'd57) & p_1us;
assign edrsync11_st_p = packet_BRmode ? 1'b0 : (all_bitcount==8'd62) & p_1us;
assign py_st_p = packet_BRmode ? (all_bitcount==8'd57) & p_1us : (all_bitcount==8'd73) & p_1us;

//
reg [1:0] fec31count;
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


headerpro headerpro_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.pk_encode              (1'b0                   ),
.regi_whitening         (regi_rxwhitening       ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.spr                    (spr                    ), 
.ir                     (ir                     ),
.header_st_p            (header_st_p            ), 
.header_en              (header_en              ), 
.hec_en                 (hec_en                 ),
.fec31inc_p             (fec31inc_p             ),
.py_period              (1'b0                   ), 
.dec_py_period          (dec_py_period          ), 
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.pkheader_bitin         (1'b0                   ), 
.dec_headerbit          (rxbit                  ),
.Xprm                   (Xprm                   ),
.Xir                    (Xir                    ),
.Xprs                   (Xprs                   ),
.CLK                    (CLK                    ),
//                     (//                     )
.decodeout              (decodeout              ),
.whitening              (whitening              ),
.hecrem                 (hec                    )

);

//
reg ckhec;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     ckhec <= 0;
  else if (py_st_p & p_1us )
     ckhec <=  1'b1 ;
  else if (p_1us)
     ckhec <= 1'b0;
end
reg hecgood;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     hecgood <= 0;
  else if (ckhec & p_1us )
     hecgood <=  (hec==8'h0) ;
end

//
reg [4:0] header_bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     header_bitcount <= 0;
  else if (header_st_p)
     header_bitcount <= 0;
  else if (header_en & fec31inc_p)
     header_bitcount <=  header_bitcount + 1'b1 ;
end

reg [2:0] lt_addr;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     lt_addr <= 0;
  else if (header_bitcount==5'd2 & fec31inc_p)
     lt_addr <= {decodeout,lt_addr[1:0]};
  else if (header_bitcount==5'd1 & fec31inc_p)
     lt_addr <= {lt_addr[2],decodeout,lt_addr[0]};
  else if (header_bitcount==5'd0 & fec31inc_p)
     lt_addr <= {lt_addr[2:1],decodeout};
end

reg [3:0] dec_pk_type;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_pk_type <= 0;
  else if (header_bitcount==5'd6 & fec31inc_p)
     dec_pk_type <= {decodeout,dec_pk_type[2:0]};
  else if (header_bitcount==5'd5 & fec31inc_p)
     dec_pk_type <= {dec_pk_type[3],decodeout,dec_pk_type[1:0]};
  else if (header_bitcount==5'd4 & fec31inc_p)
     dec_pk_type <= {dec_pk_type[3:2],decodeout,dec_pk_type[0]};
  else if (header_bitcount==5'd3 & fec31inc_p)
     dec_pk_type <= {dec_pk_type[3:1],decodeout};
end

reg flow, arqn, seqn;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     flow <= 0;
  else if (header_bitcount==5'd7 & fec31inc_p)
     flow <= {decodeout};
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     arqn <= 0;
  else if (header_bitcount==5'd8 & fec31inc_p)
     arqn <= {decodeout};
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     seqn <= 0;
  else if (header_bitcount==5'd9 & fec31inc_p)
     seqn <= {decodeout};
end

assign rxisnull = dec_pk_type==4'b0000;
assign rxispoll = dec_pk_type==4'b0001;
assign rxisfhs = dec_pk_type==4'b0010;

//assign rxpybitlen = rxisfhs ? 13'd144 :
//                 rxispoll|rxisnull ? 13'd0 : dec_pylenbit;
                 
                 
endmodule