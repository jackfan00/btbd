module rxallbit(
clk_6M, rstz, p_1us, p_05us, p_033us,
is_BRmode, is_eSCO, is_SCO, is_ACL,
regi_rxwhitening,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
mpr, ir, spr,
rx_trailer_st_p,
psrxfhs, inquiryrxfhs, conns,
Xprm, Xir, Xprs,
CLK,
rxbit,

//
rxispoll
);

input clk_6M, rstz, p_1us, p_05us, p_033us;
input is_BRmode, is_eSCO, is_SCO, is_ACL;
input regi_rxwhitening;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input mpr, ir, spr;
input rx_trailer_st_p;
input psrxfhs, inquiryrxfhs, conns;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
input rxbit;
//
output rxispoll;

wire [12:0] rxpybitlen, dec_pylenbit;
wire [9:0] dec_pylenByte;
wire [6:0] whitening;
wire [3:0] dec_pk_type;
wire [2:0] rxoccpuy_slots;
//
rxheaderbit rxheaderbit_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.regi_rxwhitening       (regi_rxwhitening       ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.spr                    (spr                    ), 
.ir                     (ir                     ),
.rx_trailer_st_p        (rx_trailer_st_p        ),
.psrxfhs                (psrxfhs                ), 
.inquiryrxfhs           (inquiryrxfhs           ), 
.conns                  (conns                  ),
.packet_BRmode          (rxpacket_BRmode        ),
.Xprm                   (Xprm                   ), 
.Xir                    (Xir                    ), 
.Xprs                   (Xprs                   ),
.CLK                    (CLK                    ),
.dec_py_period          (dec_py_period          ), 
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.dec_pylenByte          (dec_pylenByte          ),
.dec_pylenbit           (dec_pylenbit           ),
.rxbit                  (rxbit                  ),
//             (        //             )        
.header_en              (header_en              ), 
.header_st_p            (header_st_p            ), 
.edrsync11_st_p         (edrsync11_st_p         ), 
.guard_st_p             (guard_st_p             ), 
.py_st_p                (py_st_p                ),
.whitening              (whitening              ),
.rxispoll               (rxispoll               ),
.dec_pk_type            (dec_pk_type            )
);

wire [1:0] dec_LLID;
rxpybitp rxpybitp_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ), 
.p_05us                 (p_05us                 ), 
.p_033us                (p_033us                ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP), 
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.ir                     (ir                     ), 
.spr                    (spr                    ),
.py_st_p                (py_st_p                ),
.packet_BRmode          (rxpacket_BRmode        ), 
.packet_DPSK            (rxpacket_DPSK          ),
.rxpybitlen             (rxpybitlen             ),
.whitening              (whitening              ),
.BRss                   (rxBRss                 ),
.crcencode              (rxcrcencode            ), 
.existpyheader          (rxexistpyheader        ),
.rxbit                  (rxbit                  ),
//                     (//                     )
.daten                  (daten                  ), 
.py_datvalid_p          (py_datvalid_p          ),
.dec_py_period          (dec_py_period          ),
.dec_pylenByte          (dec_pylenByte          ),
.dec_pylenbit           (dec_pylenbit           ),
.dec_crcgood            (dec_crcgood            ),
.dec_LLID               (dec_LLID               ),
.dec_FLOW               (dec_FLOW               )
);

//
pktydecode pktydecode_u(
.is_BRmode      (is_BRmode      ), 
.is_eSCO        (is_eSCO        ), 
.is_SCO         (is_SCO         ), 
.is_ACL         (is_ACL         ),
.pk_type        (dec_pk_type    ),
.regi_payloadlen(dec_pylenByte  ),
//             (//             )
.pylenbit       (rxpybitlen     ),
.occpuy_slots   (rxoccpuy_slots ),
.fec31encode    (rxfec31encode  ), 
.fec32encode    (rxfec32encode  ), 
.crcencode      (rxcrcencode    ), 
.packet_BRmode  (rxpacket_BRmode), 
.packet_DPSK    (rxpacket_DPSK  ),
.BRss           (rxBRss         ),
.pyheader       (rxexistpyheader)
);


endmodule