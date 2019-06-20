module txallbit (
clk_6M, rstz, p_1us, p_05us, p_033us,
pagetxfhs, connsnewmaster,,
page, inquiry, conns, ps, mpr, spr, ir,
tx_packet_st_p,
regi_txwhitening,
regi_payloadlen,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_LT_ADDR,
regi_packet_type,
regi_FLOW, regi_ARQN, regi_SEQN,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, 
Xprm, Xir, Xprs,
CLK,
regi_FHS_LT_ADDR,
regi_myClass,
regi_my_BD_ADDR_NAP,
regi_my_BD_ADDR_UAP,
regi_SR,
regi_EIR,
regi_my_BD_ADDR_LAP,
regi_my_syncword,
is_BRmode, is_eSCO, is_SCO, is_ACL,
//
txbit, txbit_period

);


input clk_6M, rstz, p_1us, p_05us, p_033us;
input pagetxfhs, connsnewmaster;
input page, inquiry, conns, ps, mpr, spr, ir;
input tx_packet_st_p;
input regi_txwhitening;
input [9:0] regi_payloadlen;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [2:0] regi_LT_ADDR;
input [3:0] regi_packet_type;
input regi_FLOW, regi_ARQN, regi_SEQN;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input [2:0] regi_FHS_LT_ADDR;
input [23:0] regi_myClass;
input [15:0] regi_my_BD_ADDR_NAP;
input [7:0] regi_my_BD_ADDR_UAP;
input [1:0] regi_SR;
input regi_EIR;
input [23:0] regi_my_BD_ADDR_LAP;
input [33:0] regi_my_syncword;
input is_BRmode, is_eSCO, is_SCO, is_ACL;

//
output txbit, txbit_period;

//
wire py_period, daten;
wire py_st_p;
wire [6:0] whitening;
wire packet_BRmode, packet_DPSK;

wire py_datvalid_p = packet_BRmode ? p_1us :
                  packet_DPSK ? p_05us : p_033us;

//
txheaderbitp txheaderbitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.pagetxfhs              (pagetxfhs              ), 
.connsnewmaster         (connsnewmaster         ),
.page                   (page                   ), 
.inquiry                (inquiry                ), 
.conns                  (conns                  ), 
.ps                     (ps                     ), 
.mpr                    (mpr                    ), 
.spr                    (spr                    ),
.ir                     (ir                     ),
.tx_packet_st_p         (tx_packet_st_p         ),
.packet_BRmode          (packet_BRmode          ),
.regi_txwhitening       (regi_txwhitening       ),
.regi_inquiryDIAC       (regi_inquiryDIAC       ),
.regi_syncword_CAC      (regi_syncword_CAC      ), 
.regi_syncword_DAC      (regi_syncword_DAC      ), 
.regi_syncword_DIAC     (regi_syncword_DIAC     ), 
.regi_syncword_GIAC     (regi_syncword_GIAC     ),
.regi_LT_ADDR           (regi_LT_ADDR           ),
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
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
//                (//                )          
.guard_st_p             (guard_st_p             ), 
.edrsync11_st_p         (edrsync11_st_p         ), 
.py_st_p                (py_st_p                ),
.txheaderbit            (txheaderbit            ),
.whitening              (whitening              ),
.header_packet_period   (header_packet_period   )

);

wire [3:0] pk_type = mpr | ir ? 4'h2 : regi_packet_type;

wire [12:0] pylenbit;
wire [2:0] occpuy_slots;
pktydecode pktydecode_u(
.is_BRmode      (is_BRmode      ), 
.is_eSCO        (is_eSCO        ), 
.is_SCO         (is_SCO         ), 
.is_ACL         (is_ACL         ),
.pk_type        (pk_type        ),
.regi_payloadlen(regi_payloadlen),
//             (//             )
.pylenbit       (pylenbit       ),
.occpuy_slots   (occpuy_slots   ),
.fec31encode    (fec31encode    ), 
.fec32encode    (fec32encode    ), 
.crcencode      (crcencode      ), 
.packet_BRmode  (packet_BRmode  ), 
.packet_DPSK    (packet_DPSK    ),
.BRss           (BRss           )
);

//
txpybitp txpybitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.mpr                    (mpr                    ),
.ir                     (ir                     ),
.spr                    (spr                    ),
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
//                                              
.txpybit                (txpybit                ), 
.py_period              (py_period              ),
.daten                  (daten                  )

);


assign txbit = header_packet_period ? txheaderbit :
               py_period     ? txpybit     : 1'b0;

assign txbit_period = header_packet_period | py_period;
endmodule