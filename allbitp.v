module allbitp (
clk_6M, rstz, p_1us, p_05us, p_033us,
s_tslot_p,
pagetxfhs, istxfhs, connsnewmaster, connsnewslave,
page, inquiry, conns, ps, mpr, spr, ir, psrxfhs, inquiryrxfhs,
rx_trailer_st_p,
tx_packet_st_p,
regi_txwhitening, regi_rxwhitening,
regi_payloadlen,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_LT_ADDR, regi_mylt_address,
regi_FHS_LT_ADDR,
regi_packet_type,
regi_FLOW, regi_ARQN, regi_SEQN,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, 
Xprm, Xir, Xprs,
CLK,
regi_myClass,
regi_my_BD_ADDR_NAP,
regi_my_BD_ADDR_UAP,
regi_SR,
regi_EIR,
regi_my_BD_ADDR_LAP,
regi_my_syncword,
is_BRmode, is_eSCO, is_SCO, is_ACL,
pk_encode,
rxbit,
//
txbit, txbit_period,
rxispoll,
lt_addressed,
fhs_Pbits,
fhs_LAP,
fhs_EIR,
fhs_SR,
fhs_SP,
fhs_UAP,
fhs_NAP,
fhs_CoD,
fhs_LT_ADDR,
fhs_CLK,
fhs_PSM


);


input clk_6M, rstz, p_1us, p_05us, p_033us;
input s_tslot_p;
input pagetxfhs, istxfhs, connsnewmaster, connsnewslave;
input page, inquiry, conns, ps, mpr, spr, ir, psrxfhs, inquiryrxfhs;
input rx_trailer_st_p;
input tx_packet_st_p;
input regi_txwhitening, regi_rxwhitening;
input [9:0] regi_payloadlen;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [2:0] regi_LT_ADDR, regi_mylt_address;
input [2:0] regi_FHS_LT_ADDR;
input [3:0] regi_packet_type;
input regi_FLOW, regi_ARQN, regi_SEQN;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input [23:0] regi_myClass;
input [15:0] regi_my_BD_ADDR_NAP;
input [7:0] regi_my_BD_ADDR_UAP;
input [1:0] regi_SR;
input regi_EIR;
input [23:0] regi_my_BD_ADDR_LAP;
input [33:0] regi_my_syncword;
input is_BRmode, is_eSCO, is_SCO, is_ACL;
input pk_encode;
input rxbit;
//
output txbit, txbit_period;
output rxispoll;
output lt_addressed;
output [33:0] fhs_Pbits;
output [23:0] fhs_LAP;
output        fhs_EIR;
output [1:0]  fhs_SR;
output [1:0]  fhs_SP;
output [7:0]  fhs_UAP;
output [15:0] fhs_NAP;
output [23:0] fhs_CoD;
output [2:0]  fhs_LT_ADDR;
output [27:2] fhs_CLK;
output [2:0]  fhs_PSM;

//
wire py_period, daten, dec_py_period;
wire py_st_p;
wire [6:0] whitening;
wire packet_BRmode, packet_DPSK;
wire [1:0] dec_LLID;
wire [33:0] fhs_Pbits;
wire [23:0] fhs_LAP;
wire        fhs_EIR;
wire [1:0]  fhs_SR;
wire [1:0]  fhs_SP;
wire [7:0]  fhs_UAP;
wire [15:0] fhs_NAP;
wire [23:0] fhs_CoD;
wire [2:0]  fhs_LT_ADDR;
wire [27:2] fhs_CLK;
wire [2:0]  fhs_PSM;
wire [9:0] dec_pylenByte;
wire [3:0] dec_pk_type;


wire py_datvalid_p = packet_BRmode ? p_1us :
                  packet_DPSK ? p_05us : p_033us;

//
headerbitp headerbitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.s_tslot_p              (s_tslot_p              ),
.pagetxfhs              (pagetxfhs              ), 
.istxfhs                (istxfhs                ),
.connsnewmaster         (connsnewmaster         ),
.connsnewslave          (connsnewslave          ),
.page                   (page                   ), 
.inquiry                (inquiry                ), 
.conns                  (conns                  ), 
.ps                     (ps                     ), 
.mpr                    (mpr                    ), 
.spr                    (spr                    ),
.ir                     (ir                     ),
.rx_trailer_st_p        (rx_trailer_st_p        ),
.tx_packet_st_p         (tx_packet_st_p         ),
.packet_BRmode          (packet_BRmode          ),
.regi_txwhitening       (regi_txwhitening       ),
.regi_rxwhitening       (regi_rxwhitening       ),
.regi_inquiryDIAC       (regi_inquiryDIAC       ),
.regi_syncword_CAC      (regi_syncword_CAC      ), 
.regi_syncword_DAC      (regi_syncword_DAC      ), 
.regi_syncword_DIAC     (regi_syncword_DIAC     ), 
.regi_syncword_GIAC     (regi_syncword_GIAC     ),
.regi_LT_ADDR           (regi_LT_ADDR           ),
.regi_mylt_address      (regi_mylt_address      ),
.regi_packet_type       (regi_packet_type       ),
.regi_FLOW              (regi_FLOW              ), 
.regi_ARQN              (regi_ARQN              ), 
.regi_SEQN              (regi_SEQN              ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.Xprm                   (Xprm                   ),
.Xprs                   (Xprs                   ),
.Xir                    (Xir                    ),
.CLK                    (CLK                    ),
.py_period              (py_period              ), 
.dec_py_period          (dec_py_period          ), 
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.pk_encode              (pk_encode              ),
.rxbit                  (rxbit                  ),

//                (//                )          
.guard_st_p             (guard_st_p             ), 
.edrsync11_st_p         (edrsync11_st_p         ), 
.py_st_p                (py_st_p                ),
.txheaderbit            (txheaderbit            ),
.whitening              (whitening              ),
.rxispoll               (rxispoll               ),
.header_packet_period   (header_packet_period   ),
.dec_pk_type            (dec_pk_type            ),
.lt_addressed           (lt_addressed           )

);

wire [3:0] txpk_type = mpr | istxfhs ? 4'h2 : regi_packet_type;

wire [3:0] pk_type = pk_encode ? txpk_type : dec_pk_type;

wire [9:0] pylenB = pk_encode ? regi_payloadlen : dec_pylenByte;

wire [12:0] pylenbit;
wire [2:0] occpuy_slots;
pktydecode pktydecode_u(
.is_BRmode      (is_BRmode      ), 
.is_eSCO        (is_eSCO        ), 
.is_SCO         (is_SCO         ), 
.is_ACL         (is_ACL         ),
.pk_type        (pk_type        ),
.regi_payloadlen(pylenB         ),
//             (//             )
.pylenbit       (pylenbit       ),
.occpuy_slots   (occpuy_slots   ),
.fec31encode    (fec31encode    ), 
.fec32encode    (fec32encode    ), 
.crcencode      (crcencode      ), 
.packet_BRmode  (packet_BRmode  ), 
.packet_DPSK    (packet_DPSK    ),
.BRss           (BRss           ),
.existpyheader  (existpyheader  )
);

//
pybitp pybitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.mpr                    (mpr                    ),
.ir                     (ir                     ),
.spr                    (spr                    ),
.psrxfhs                (psrxfhs                ),
.inquiryrxfhs           (inquiryrxfhs           ),
.py_st_p                (py_st_p                ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.whitening              (whitening              ),
.CLK                    (CLK                    ),
.regi_FHS_LT_ADDR       (regi_FHS_LT_ADDR       ),
.regi_myClass           (regi_myClass           ),
.regi_my_BD_ADDR_NAP    (regi_my_BD_ADDR_NAP    ),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.regi_SR                (regi_SR                ),
.regi_EIR               (regi_EIR               ),
.regi_my_BD_ADDR_LAP    (regi_my_BD_ADDR_LAP    ),
.regi_my_syncword       (regi_my_syncword       ),
//.is_BRmode              (is_BRmode              ), 
//.is_eSCO                (is_eSCO                ), 
//.is_SCO                 (is_SCO                 ), 
//.is_ACL                 (is_ACL                 ),
.pk_type                (pk_type                ),
.pylenbit               (pylenbit               ),
.crcencode              (crcencode              ), 
.fec31encode            (fec31encode            ), 
.fec32encode            (fec32encode            ),
.py_datvalid_p          (py_datvalid_p          ), 
.pk_encode              (pk_encode              ),
.BRss                   (BRss                   ),
.existpyheader          (existpyheader          ),
.rxbit                  (rxbit                  ),
//                                              
.txpybit                (txpybit                ), 
.py_period              (py_period              ),
.daten                  (daten                  ),
.dec_py_period          (dec_py_period          ),
.dec_pylenByte          (dec_pylenByte          ),
.dec_crcgood            (dec_crcgood            ),
.dec_LLID               (dec_LLID               ),
.dec_FLOW               (dec_FLOW               ),
.fhs_Pbits              (fhs_Pbits              ),
.fhs_LAP                (fhs_LAP                ),
.fhs_EIR                (fhs_EIR                ),
.fhs_SR                 (fhs_SR                 ),
.fhs_SP                 (fhs_SP                 ),
.fhs_UAP                (fhs_UAP                ),
.fhs_NAP                (fhs_NAP                ),
.fhs_CoD                (fhs_CoD                ),
.fhs_LT_ADDR            (fhs_LT_ADDR            ),
.fhs_CLK                (fhs_CLK                ),
.fhs_PSM                (fhs_PSM                )

);


assign txbit = header_packet_period & pk_encode ? txheaderbit :
               py_period & pk_encode     ? txpybit     : 1'b0;

assign txbit_period = (header_packet_period | py_period) & pk_encode;

endmodule
