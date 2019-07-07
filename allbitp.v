module allbitp (
clk_6M, rstz, p_1us, p_05us, p_033us,
regi_chgbufcmd_p,
LMP_c_slot,
rxCAC, prerx_trans,
regi_txcmd_p, regi_flushcmd_p,  
ms_txcmd_p,
txbsmacl_addr, txbsmsco_addr,
txbsmacl_din, txbsmsco_din,
txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs,
rxbsmacl_addr, rxbsmsco_addr,
rxbsmacl_cs, rxbsmsco_cs,
rxbsm_valid_p,
s_tslot_p, ms_tslot_p,
pagetxfhs, istxfhs, connsnewmaster, connsnewslave,
page, inquiry, conns, ps, mpr, spr, ir, psrxfhs, inquiryrxfhs,
rx_trailer_st_p,
tx_packet_st_p,
regi_isMaster,
regi_txwhitening, regi_rxwhitening,
regi_payloadlen,
regi_inquiryDIAC,
regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC,
regi_LT_ADDR, regi_mylt_address,
regi_FHS_LT_ADDR,
regi_packet_type,
//regi_FLOW, regi_ARQN, regi_SEQN,
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
pk_encode, conns_1stslot, pk_encode_1stslot,
//bufpacketin,
rxbit,
//
pybitcount,
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
fhs_PSM,
//rxpydin,
//rxpyadr,
//rxpydin_valid_p,
bsm_dout,
extendslot,
s_acltxcmd_p,
regi_aclrxbufempty,
srcFLOW, txARQN,
dec_pk_type,
dec_lt_addr,
dec_flow, dec_arqn, SEQN_old,
dec_hecgood

);


input clk_6M, rstz, p_1us, p_05us, p_033us;
input regi_chgbufcmd_p;
input LMP_c_slot;
input rxCAC, prerx_trans;
input regi_txcmd_p, regi_flushcmd_p;
input ms_txcmd_p;
input [7:0] txbsmacl_addr, txbsmsco_addr;
input [31:0] txbsmacl_din, txbsmsco_din;
input txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs;
input [7:0] rxbsmacl_addr, rxbsmsco_addr;
input rxbsmacl_cs, rxbsmsco_cs;
input rxbsm_valid_p;
input s_tslot_p, ms_tslot_p;
input pagetxfhs, istxfhs, connsnewmaster, connsnewslave;
input page, inquiry, conns, ps, mpr, spr, ir, psrxfhs, inquiryrxfhs;
input rx_trailer_st_p;
input tx_packet_st_p;
input regi_isMaster;
input regi_txwhitening, regi_rxwhitening;
input [9:0] regi_payloadlen;
input regi_inquiryDIAC;
input [63:0] regi_syncword_CAC, regi_syncword_DAC, regi_syncword_DIAC, regi_syncword_GIAC;
input [2:0] regi_LT_ADDR, regi_mylt_address;
input [2:0] regi_FHS_LT_ADDR;
input [3:0] regi_packet_type;
//input regi_FLOW, regi_ARQN, regi_SEQN;
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
input pk_encode, conns_1stslot, pk_encode_1stslot;
//input bufpacketin;
input rxbit;
//
output [12:0] pybitcount;
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
//output [31:0] rxpydin;
//output [7:0] rxpyadr;
//output rxpydin_valid_p;
output [31:0] bsm_dout ;
output extendslot;
output s_acltxcmd_p;
output regi_aclrxbufempty;
output [7:0] srcFLOW, txARQN;
output [3:0] dec_pk_type;
output [2:0] dec_lt_addr;
output [7:0] dec_flow, dec_arqn, SEQN_old;
output dec_hecgood;

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
wire [3:0] txpktype;
wire [7:0] txaclSEQN, txARQN;
wire [7:0] srcFLOW;
wire [3:0] srctxpktype;
wire [2:0] dec_lt_addr;
wire [7:0] dec_flow, dec_arqn;
wire [31:0] rxpydin;
wire [7:0] rxpyadr;
wire pktype_data;
wire [12:0] pylenbit;
wire [2:0] occpuy_slots;

wire [2:0] ms_lt_addr = regi_isMaster ? regi_LT_ADDR : regi_mylt_address;
wire py_datvalid_p = packet_BRmode ? p_1us :
                  packet_DPSK ? p_05us : p_033us;

//
headerbitp headerbitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.pylenbit               (pylenbit               ),
.ms_lt_addr             (ms_lt_addr             ),
.s_tslot_p              (s_tslot_p              ),
.ms_tslot_p             (ms_tslot_p             ),
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
.regi_isMaster          (regi_isMaster          ),
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
//.regi_FLOW              (regi_FLOW              ), 
//.regi_ARQN              (regi_ARQN              ), 
//.regi_SEQN              (regi_SEQN              ),
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
.srctxpktype            (srctxpktype            ),
.txaclSEQN              (txaclSEQN              ), 
.txARQN                 (txARQN                 ),
.srcFLOW                (srcFLOW                ),
.rspFLOW                (rspFLOW                ),
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
.lt_addressed           (lt_addressed           ),
.txpktype               (txpktype               ),
.dec_lt_addr            (dec_lt_addr            ),
.dec_flow               (dec_flow               ), 
.dec_arqn               (dec_arqn               ),
.header_st_p            (header_st_p            ),
.dec_hecgood            (dec_hecgood            ),
.dec_seqn               (dec_seqn               )

);

//wire [3:0] txpk_type = mpr | istxfhs ? 4'h2 : regi_packet_type;

wire [3:0] pk_type = pk_encode ? txpktype : dec_pk_type;

wire [9:0] pylenB = pk_encode_1stslot ? regi_payloadlen : dec_pylenByte;

pktydecode pktydecode_u(
.clk_6M           (clk_6M           ), 
.rstz             (rstz             ), 
.pktype_data      (pktype_data      ),
.ms_tslot_p       (ms_tslot_p       ),
.is_BRmode        (is_BRmode        ), 
.is_eSCO          (is_eSCO          ), 
.is_SCO           (is_SCO           ), 
.is_ACL           (is_ACL           ),
.pk_type          (pk_type          ),
.regi_payloadlen  (pylenB           ),
.conns_1stslot    (conns_1stslot    ),
.pk_encode_1stslot(pk_encode_1stslot),
//             (//             )
.pylenbit_f       (pylenbit         ),
.occpuy_slots_f   (occpuy_slots     ),
.fec31encode_f    (fec31encode      ), 
.fec32encode_f    (fec32encode      ), 
.crcencode_f      (crcencode        ), 
.packet_BRmode_f  (packet_BRmode    ), 
.packet_DPSK_f    (packet_DPSK      ),
.BRss_f           (BRss             ),
.existpyheader_f  (existpyheader    ),
.allowedeSCOtype  (allowedeSCOtype  ),
.extendslot       (extendslot       )
);

//
wire lnctrl_txpybitin;
wire bufpacketin = lnctrl_txpybitin;
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
.bufpacketin            (bufpacketin            ),
.rxbit                  (rxbit                  ),
//                                              
.pybitcount             (pybitcount             ),
.txpybit                (txpybit                ), 
.py_period              (py_period              ),
.daten                  (daten                  ),
.dec_py_period          (dec_py_period          ),
.dec_pylenByte          (dec_pylenByte          ),
.dec_crcgood            (dec_crcgood            ),
.dec_LLID               (dec_LLID               ),
.dec_pyFLOW             (dec_pyFLOW             ),
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
.fhs_PSM                (fhs_PSM                ),
.rxpydin                (rxpydin                ),
.rxpyadr                (rxpyadr                ),
.rxpydin_valid_p_wr     (rxpydin_valid_p_wr     ),
.py_endp                (py_endp                ),
.dec_py_endp            (dec_py_endp            ),
.py_datperiod           (py_datperiod           )

);


assign txbit = header_packet_period & pk_encode ? txheaderbit :
               py_period & pk_encode     ? txpybit     : 1'b0;

assign txbit_period = (header_packet_period | py_period) & pk_encode;

//
wire [31:0] rxlnctrl_din = rxpydin;
wire [7:0]  rxlnctrl_addr = rxpyadr;
wire rxlnctrl_we = rxpydin_valid_p_wr;
wire dec_LMPcmd = (dec_LLID==2'b11);
//
wire tx_reservedslot = 1'b0; //for tmp
wire rx_reservedslot = 1'b0; //for tmp
wire txtsco_p = 1'b0; //for tmp
wire rxtsco_p = 1'b0; //for tmp

bufctrl bufctrl_u(
.clk_6M          (clk_6M          ), 
.rstz            (rstz            ),
.pktype_data     (pktype_data     ),
.regi_chgbufcmd_p(regi_chgbufcmd_p),
.LMP_c_slot      (LMP_c_slot      ),
.dec_hecgood     (dec_hecgood     ), 
.dec_crcgood     (dec_crcgood     ),
.dec_pylenByte   (dec_pylenByte   ), 
.header_st_p     (header_st_p     ),
.pk_encode       (pk_encode       ),
.py_endp         (py_endp         ),
.ms_lt_addr      (ms_lt_addr      ),
.dec_arqn        (dec_arqn        ),
.dec_flow        (dec_flow        ),
.ms_tslot_p      (ms_tslot_p      ),
.pybitcount      (pybitcount      ),
.dec_LMPcmd      (dec_LMPcmd      ),
.py_datperiod    (py_datperiod    ), 
.dec_py_period   (dec_py_period   ),
.tx_reservedslot (tx_reservedslot ), 
.rx_reservedslot (rx_reservedslot ), 
.txtsco_p        (txtsco_p        ), 
.rxtsco_p        (rxtsco_p        ),
.txbsmacl_addr   (txbsmacl_addr   ), 
.txbsmsco_addr   (txbsmsco_addr   ),
.txbsmacl_din    (txbsmacl_din    ), 
.txbsmsco_din    (txbsmsco_din    ),
.txbsmacl_we     (txbsmacl_we     ), 
.txbsmsco_we     (txbsmsco_we     ), 
.txbsmacl_cs     (txbsmacl_cs     ), 
.txbsmsco_cs     (txbsmsco_cs     ),
.rxbsmacl_addr   (rxbsmacl_addr   ), 
.rxbsmsco_addr   (rxbsmsco_addr   ), 
.rxlnctrl_addr   (rxlnctrl_addr   ),
.rxlnctrl_din    (rxlnctrl_din    ),
.rxlnctrl_we     (rxlnctrl_we     ), 
.rxbsmacl_cs     (rxbsmacl_cs     ), 
.rxbsmsco_cs     (rxbsmsco_cs     ),
.rxbsm_valid_p   (rxbsm_valid_p   ),
//
.lnctrl_txpybitin(lnctrl_txpybitin),
.bsm_dout        (bsm_dout        ),
.regi_aclrxbufempty(regi_aclrxbufempty)
);

wire dec_micgood = 1'b1; //for tmp
wire [2:0] esco_LT_ADDR = 3'h7; //for tmp
//
arqflowctrl arqflowctrl_u(
.clk_6M             (clk_6M             ), 
.rstz               (rstz               ),
.regi_chgbufcmd_p   (regi_chgbufcmd_p   ),
.regi_isMaster      (regi_isMaster      ),
.dec_py_endp        (dec_py_endp        ),
.esco_LT_ADDR       (esco_LT_ADDR       ),
.rxCAC              (rxCAC              ),
.is_eSCO            (is_eSCO            ),
.dec_hecgood        (dec_hecgood        ),
.dec_micgood        (dec_micgood        ),
.connsnewmaster     (connsnewmaster     ), 
.connsnewslave      (connsnewslave      ),
.ms_lt_addr         (ms_lt_addr         ),
.ms_tslot_p         (ms_tslot_p         ),
.s_tslot_p          (s_tslot_p          ),
.pk_encode          (pk_encode          ),
.dec_seqn           (dec_seqn           ),
.dec_lt_addr        (dec_lt_addr        ),
.lt_addressed       (lt_addressed       ),
.allowedeSCOtype    (allowedeSCOtype    ),
.header_st_p        (header_st_p        ),
.dec_pktype         (dec_pk_type        ), 
.txpktype           (txpktype           ),
.regi_packet_type   (regi_packet_type   ),
.dec_flow           (dec_flow           ),
.dec_arqn           (dec_arqn           ),
.prerx_trans        (prerx_trans        ), 
.dec_crcgood        (dec_crcgood        ),
.regi_flushcmd_p    (regi_flushcmd_p    ),
.ms_txcmd_p         (ms_txcmd_p         ),
.regi_aclrxbufempty (regi_aclrxbufempty ),
//
.txARQN             (txARQN             ),
.txaclSEQN          (txaclSEQN          ),
.srctxpktype        (srctxpktype        ),
.s_acltxcmd_p       (s_acltxcmd_p       ),
.srcFLOW            (srcFLOW            ),
.rspFLOW            (rspFLOW            ),
.pktype_data        (pktype_data        ),
.SEQN_old           (SEQN_old           )

);


endmodule
