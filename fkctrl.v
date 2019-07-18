//
// computr fk in advance
//

module fkctrl(
clk_6M, rstz,
scancase_fk_chg_p,
m_half_tslot_p,
mpr,
m_tslot_p,
connsnewslave, connsnewmaster,
CLKN, CLKE, CLK,
txbit_period, rxbit_period,
fkset_p,  // default 150us pll setup time
ps, pstxid, psrxfhs, psackfhs, pagetxfhs, pagetmp, pagerxackfhs ,
corre_threshold,
//
counter_clkN1,
counter_clkE1,
fk_pstxid,
fk_psrxfhs,
fk_psackfhs,
fk_connsnewslave, fk_connsnewmaster,
fk_pagetxfhs,
fk_pagerxackfhs,
fk_spr,
fk_chg_p, fk_chg_p_ff

);

input clk_6M, rstz;
input scancase_fk_chg_p;
input m_half_tslot_p;
input mpr;
input m_tslot_p;
input connsnewslave, connsnewmaster;
input [27:0] CLKN, CLKE, CLK;
input txbit_period, rxbit_period;
input fkset_p;  // default 150us pll setup time
input ps, pstxid, psrxfhs, psackfhs, pagetxfhs, pagetmp, pagerxackfhs ;
input corre_threshold;
//
output [5:0] counter_clkN1;
output [4:0] counter_clkE1;
output fk_pstxid;
output fk_psrxfhs;
output fk_psackfhs;
output fk_connsnewslave, fk_connsnewmaster;
output fk_pagetxfhs;
output fk_pagerxackfhs;
output fk_spr;
output fk_chg_p, fk_chg_p_ff;

assign fk_spr = fk_pstxid | fk_psrxfhs | fk_psackfhs;


wire fk_chg_p = ((!(txbit_period | rxbit_period)) & fkset_p); // | scancase_fk_chg_p;

reg fk_chg_p_ff;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_chg_p_ff <= 0;
  else 
     fk_chg_p_ff <= fk_chg_p | scancase_fk_chg_p;
end


reg fk_pstxid;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_pstxid <= 0;
  else if (ps & corre_threshold & fkset_p)  //special case 
     fk_pstxid <= 1'b1;
  else if (pstxid & fk_chg_p)
     fk_pstxid <= 1'b0;
end

reg fk_psrxfhs;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_psrxfhs <= 0;
  else if (pstxid & fk_chg_p)
     fk_psrxfhs <= 1'b1;
  else if (psrxfhs & corre_threshold & fk_chg_p)
     fk_psrxfhs <= 1'b0;
end

reg fk_psackfhs;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_psackfhs <= 0;
  else if (psrxfhs & corre_threshold & fk_chg_p)
     fk_psackfhs <= 1'b1;
  else if (psackfhs & fk_chg_p & CLKN[0])
     fk_psackfhs <= 1'b0;
end

reg fk_connsnewslave;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_connsnewslave <= 0;
  else if (psackfhs & fk_chg_p & CLKN[0])
     fk_connsnewslave <= 1'b1;
  else if (connsnewslave & fk_chg_p & CLK[0])  // conns use CLK
     fk_connsnewslave <= 1'b0;
end


reg fk_pagetxfhs;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_pagetxfhs <= 0;
  else if ( (pagetmp & fk_chg_p) | (pagerxackfhs & !corre_threshold & fk_chg_p) )
     fk_pagetxfhs <= 1'b1;
  else if (pagetxfhs & fk_chg_p)
     fk_pagetxfhs <= 1'b0;
end

reg fk_pagerxackfhs;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_pagerxackfhs <= 0;
  else if (pagetxfhs & fk_chg_p)
     fk_pagerxackfhs <= 1'b1;
  else if (pagerxackfhs & fk_chg_p & CLKE[0])
     fk_pagerxackfhs <= 1'b0;
end

reg fk_connsnewmaster;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fk_connsnewmaster <= 0;
  else if (pagerxackfhs & m_half_tslot_p)  // advance to half tslot
     fk_connsnewmaster <= 1'b1;
  else if (connsnewmaster & fk_chg_p & CLK[0])  // conns use CLK
     fk_connsnewmaster <= 1'b0;
end
//
//
wire ps_N_incr_p = (pstxid & fk_chg_p) | ((psrxfhs|psackfhs) & fk_chg_p & CLKN[0]);

reg [5:0] counter_clkN1;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     counter_clkN1 <= 0;
    end 
  else if (ps & corre_threshold & fkset_p)  //slave page response
    begin
     counter_clkN1 <= 6'h1;
    end 
//  else if (psrxfhs_succ_p)
//     counter_clkN1 <= {counter_clkN1[5:1],1'b0};
  else if (ps_N_incr_p)
    begin
     counter_clkN1 <= counter_clkN1+1'b1;
    end 
end

reg [4:0] counter_clkE1;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     counter_clkE1 <= 0;
    end 
  else if (!mpr)  //master page response
    begin
     counter_clkE1 <= 5'd0;
    end 
  else if (CLKE[1] & m_tslot_p)
    begin
     counter_clkE1 <= counter_clkE1+1'b1;
    end 
end
//


endmodule