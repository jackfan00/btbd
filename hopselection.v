module hopselection(
clk_6M, rstz, p_033us,
ps_pagerespTO,
fk_page,
scancase,
m_half_tslot_p,
connsnewslave, connsnewmaster,
txbit_period, rxbit_period,
fkset_p,  // default 150us pll setup time
psackfhs, pagetxfhs, pagetmp, pagerxackfhs ,
corre_threshold,

//counter_clkN1, counter_clkE1,
psrxfhs_succ_p,
psrxfhs,
pstxid,
m_tslot_p, ms_tslot_p,
ps_N_incr_p,
pageAB_2Npage_count, 
Atrain,
regi_interlace_offset, regi_page_k_nudge,
regi_AFH_mode,
regi_AFH_N, regi_AFH_channel_map,
ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns,
prs_clock_frozen, prm_clock_frozen,
CLK, CLKE, CLKN, BD_ADDR,
counter_isFHS,
//
fk,
fk_chg_p, fk_chg_p_ff,
fk_pstxid
);

input clk_6M, rstz, p_033us;
input ps_pagerespTO;
input fk_page;
input scancase;
input m_half_tslot_p;
input connsnewslave, connsnewmaster;

input txbit_period, rxbit_period;
input fkset_p;  // default 150us pll setup time
input psackfhs, pagetxfhs, pagetmp, pagerxackfhs ;
input corre_threshold;

wire [5:0] counter_clkN1;
wire [5:0] counter_clkE1;
input psrxfhs_succ_p;
input psrxfhs;
input pstxid;
input m_tslot_p, ms_tslot_p;
input ps_N_incr_p;
input [3:0] pageAB_2Npage_count;
input Atrain;
input [4:0] regi_interlace_offset, regi_page_k_nudge;
input regi_AFH_mode;
input [6:0] regi_AFH_N;
input [79:0] regi_AFH_channel_map;
input ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns;
input prs_clock_frozen, prm_clock_frozen;
input [27:0] CLK, CLKE, CLKN, BD_ADDR;
input [4:0] counter_isFHS;
//
output [6:0] fk;
output fk_chg_p, fk_chg_p_ff;
output fk_pstxid;

wire [4:0] Xprm, Xir, Xprs;
wire [4:0] X;
wire Y1;
wire [5:0] Y2;
wire [4:0] A;
wire [3:0] B;
wire [4:0] C;
wire [8:0] D;
wire [6:0] E, F, Fprime;
wire fk_connsnewslave, fk_connsnewmaster;

wire fk_conns = conns | fk_connsnewslave | fk_connsnewmaster;
wire [27:0] fk_CLK = fk_conns ? CLK + 1'b1 : CLK;
wire [27:0] fk_CLKE = CLKE + 1'b1;
wire [27:0] fk_CLKN = CLKN + 1'b1;

hopctrlwd hopctrlwd_u(
.clk_6M               (clk_6M               ), 
.rstz                 (rstz                 ), 
.p_033us              (p_033us              ),
.mpr_Y                (counter_clkE1[0]     ),
.counter_clkN1        (counter_clkN1        ),  
.counter_clkE1        (counter_clkE1        ),       
.psrxfhs_succ_p       (psrxfhs_succ_p       ),
.psrxfhs              (fk_psrxfhs              ),
.pstxid               (fk_pstxid               ),
.m_tslot_p            (m_tslot_p            ),
.ms_tslot_p           (ms_tslot_p           ),
.ps_N_incr_p          (ps_N_incr_p          ),
.pageAB_2Npage_count  (pageAB_2Npage_count  ), 
.Atrain               (Atrain               ),
.regi_interlace_offset(regi_interlace_offset),
.regi_page_k_nudge    (regi_page_k_nudge    ),
.regi_AFH_mode        (regi_AFH_mode        ),
.regi_AFH_N           (regi_AFH_N           ),
.ps                   (ps                   ), 
.gips                 (gips                 ), 
.is                   (is                   ), 
.giis                 (giis                 ), 
.page                 (fk_page                 ), 
.inquiry              (inquiry              ), 
.mpr                  (fk_mpr                  ), 
.spr                  (fk_spr                  ), 
.ir                   (ir                   ), 
.conns                (fk_conns                ),
.prs_clock_frozen     (prs_clock_frozen     ), 
.prm_clock_frozen     (prm_clock_frozen     ),
.CLK                  (fk_CLK                  ), 
.CLKE                 (fk_CLKE                 ), 
.CLKN                 (fk_CLKN                 ), 
.BD_ADDR              (BD_ADDR          ),
.counter_isFHS        (counter_isFHS        ),
//
.Xprm                 (Xprm                 ), 
.Xir                  (Xir                  ),
.Xprs                 (Xprs                 ), 
.X                    (X                    ),
.Y1                   (Y1                   ),
.Y2                   (Y2                   ),
.A                    (A                    ),
.B                    (B                    ),
.C                    (C                    ),
.D                    (D                    ),
.E                    (E                    ), 
.F                    (F                    ), 
.Fprime               (Fprime               )
);

hopkernal hopkernal_u(
//.divffclk            (divffclk            ), 
//.div_en_p            (div_en_p            ),
.rstz                (rstz                ),
.X                   (X                   ), 
.A                   (A                   ), 
.C                   (C                   ),
.B                   (B                   ),
.D                   (D                   ),
.E                   (E                   ), 
.F                   (F                   ),
.Fprime              (Fprime              ),
.Y1                  (Y1                  ),
.Y2                  (Y2                  ),
.regi_AFH_channel_map(regi_AFH_channel_map),
.regi_AFH_N          (regi_AFH_N          ),
.fk                  (fk                  )

);


fkctrl fkctrl_u(
.clk_6M         (clk_6M         ), 
.rstz           (rstz           ),
.psrxfhs_succ_p (psrxfhs_succ_p ),
.fk_page        (fk_page        ),
.page           (page           ),
.ps_pagerespTO  (ps_pagerespTO  ),
.scancase       (scancase       ),
.m_half_tslot_p (m_half_tslot_p ),
.mpr            (mpr            ),
.m_tslot_p      (m_tslot_p      ),
.connsnewslave  (connsnewslave  ),
.connsnewmaster (connsnewmaster ),
.CLKN           (CLKN           ),
.CLKE           (CLKE           ),
.CLK            (CLK            ),
.txbit_period   (txbit_period   ), 
.rxbit_period   (rxbit_period   ),
.fkset_p        (fkset_p        ),  // default 150us pll setup time
.ps             (ps             ), 
.pstxid         (pstxid         ), 
.psrxfhs        (psrxfhs        ), 
.psackfhs       (psackfhs       ), 
.pagetxfhs      (pagetxfhs      ), 
.pagetmp        (pagetmp        ), 
.pagerxackfhs   (pagerxackfhs   ),
.corre_threshold(corre_threshold),
//
.counter_clkN1   (counter_clkN1   ),
.counter_clkE1   (counter_clkE1   ),
.fk_pstxid       (fk_pstxid       ),
.fk_psrxfhs      (fk_psrxfhs      ),
.fk_psackfhs     (fk_psackfhs     ),
.fk_connsnewslave(fk_connsnewslave),
.fk_connsnewmaster(fk_connsnewmaster),
.fk_pagetxfhs    (fk_pagetxfhs    ),
.fk_pagerxackfhs (fk_pagerxackfhs ),
.fk_spr          (fk_spr          ),
.fk_mpr          (fk_mpr          ),
.fk_chg_p        (fk_chg_p        ),
.fk_chg_p_ff     (fk_chg_p_ff     )


);

endmodule