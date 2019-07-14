//
// 2019/04/24
// hopping control word : core5.1 Spec 2.6.4
//

module hopctrlwd(
clk_6M, rstz, p_033us,
counter_clkN1, counter_clkE1,
psrxfhs_succ_p,
psrxfhs,
pstxid,
m_tslot_p, ms_tslot_p,
ps_N_incr_p,
pageAB_2Npage_count, 
Atrain,
regi_interlace_offset, regi_page_k_nudge,
regi_AFH_mode,
regi_AFH_N,
ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns,
prs_clock_frozen, prm_clock_frozen,
CLK, CLKE, CLKN, BD_ADDR,
counter_isFHS,
//
Xprm, Xir, Xprs,
X,
Y1,
Y2,
A,
B,
C,
D,
E, F, Fprime
);

input clk_6M, rstz, p_033us;
input [5:0] counter_clkN1;
input [4:0] counter_clkE1;
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
input ps, gips, is, giis, page, inquiry, mpr, spr, ir, conns;
input prs_clock_frozen, prm_clock_frozen;
input [27:0] CLK, CLKE, CLKN, BD_ADDR;
input [4:0] counter_isFHS;
//
output [4:0] Xprm, Xir, Xprs;
output [4:0] X;
output Y1;
output [5:0] Y2;
output [4:0] A;
output [3:0] B;
output [4:0] C;
output [8:0] D;
output [6:0] E, F, Fprime;

wire [1:0] k_nudge;
wire [4:0] k_offset;

reg [27:0] CLKN_frozen, CLKE_frozen;
reg [4:0] k_offset_frozen;
reg [4:0] k_nudge_frozen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     CLKN_frozen <= 0;
    end 
  else if (!prs_clock_frozen)
    begin
     CLKN_frozen <= CLKN;
    end 
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     CLKE_frozen <= 0;
     k_offset_frozen <= 0;
     k_nudge_frozen <= 0;
    end 
  else if (!prm_clock_frozen)
    begin
     CLKE_frozen <= CLKE;
     k_offset_frozen <= k_offset;
     k_nudge_frozen <= k_nudge;
    end 
end
//

/////////reg [5:0] counter_clkN1;
/////////always @(posedge clk_6M or negedge rstz)
/////////begin
/////////  if (!rstz)
/////////    begin
/////////     counter_clkN1 <= 0;
/////////    end 
/////////  else if (!spr)  //slave page response
/////////    begin
/////////     counter_clkN1 <= 5'h1;
/////////    end 
/////////  else if (psrxfhs_succ_p)
/////////     counter_clkN1 <= {counter_clkN1[5:1],1'b0};
/////////  else if (ps_N_incr_p)
/////////    begin
/////////     counter_clkN1 <= counter_clkN1+1'b1;
/////////    end 
/////////end

////////reg [4:0] counter_clkE1;
////////always @(posedge clk_6M or negedge rstz)
////////begin
////////  if (!rstz)
////////    begin
////////     counter_clkE1 <= 0;
////////    end 
////////  else if (!mpr)  //master page response
////////    begin
////////     counter_clkE1 <= 5'd1;
////////    end 
////////  else if (CLKE[1] & m_tslot_p)
////////    begin
////////     counter_clkE1 <= counter_clkE1+1'b1;
////////    end 
////////end

//
//assign k_nudge = during_first_2Npage ? 2'd0  : 2'd2;
assign k_nudge = regi_page_k_nudge; //{pageAB_2Npage_count,1'b0};
assign k_offset = Atrain ? 5'd24 : 5'd8;
wire [3:0] xpt = {CLKE[4:2],CLKE[0]} - CLKE[16:12];   // mod 16
wire [4:0] Xp = CLKE[16:12] + k_offset + k_nudge + xpt ;  // mod 32

wire [4:0] Xprs = CLKN_frozen[16:12] + counter_clkN1[5:1];

wire [3:0] xprmt = {CLKE_frozen[4:2],CLKE_frozen[0]} - CLKE_frozen[16:12];
wire [4:0] Xprm = CLKE_frozen[16:12] + k_offset_frozen + k_nudge_frozen + xprmt + counter_clkE1;

wire [3:0] xit = {CLKN[4:2],CLKN[0]} - CLKN[16:12];
wire [4:0] Xi = CLKN[16:12] + k_offset + k_nudge + xit ;


wire [4:0] Xir = CLKN[16:12] + counter_isFHS ;

//
assign X = ({5{ps}}      & CLKN[16:12]) |    //page scan
           ({5{gips}}    & (CLKN[16:12]+regi_interlace_offset)) |  //generlized interlace page scan
           ({5{is}}      & Xir[4:0]) |       //inquiry scan
           ({5{giis}}    & (Xir[4:0]+regi_interlace_offset)) |     //generlized interlace inquiry scan
           ({5{page}}    & Xp[4:0]) |
           ({5{inquiry}} & Xi[4:0]) |
           ({5{mpr}}     & Xprm[4:0]) |   //master page respone
           ({5{spr}}     & Xprs[4:0]) |   //slave page response
           ({5{ir}}      & Xir[4:0]) |    //inquiry response
           ({5{conns}}   & CLK[6:2]);     //connection state
           

wire spr_Y = pstxid | (psrxfhs ? 1'b0 : counter_clkN1[0]);

assign Y1 =({1{page}}    & CLKE[1]) |
           ({1{inquiry}} & CLKN[1]) |
           ({1{mpr}}     & CLKE[1]) |   //master page respone
           ({1{spr}}     & spr_Y  ) |  //CLKN[1]) |   //slave page response
           ({1{ir}}      & 1'b1) |    //inquiry response
           ({1{conns}}   & (CLK[1]&(!regi_AFH_mode)) );     //connection state

assign Y2 =({6{page}}    & {CLKE[1],5'b0}) |
           ({6{inquiry}} & {CLKN[1],5'b0}) |
           ({6{mpr}}     & {CLKE[1],5'b0}) |   //master page respone
           ({6{spr}}     & {spr_Y  ,5'b0}) |  //{CLKN[1],5'b0}) |   //slave page response
           ({6{ir}}      & {1'b1   ,5'b0}) |    //inquiry response
           ({6{conns}}   & {(CLK[1]&(!regi_AFH_mode)) ,5'b0});     //connection state

assign A = ({5{ps}}      & BD_ADDR[27:23]) |    //page scan
           ({5{gips}}    & BD_ADDR[27:23]) |  //generlized interlace page scan
           ({5{is}}      & BD_ADDR[27:23]) |       //inquiry scan
           ({5{giis}}    & BD_ADDR[27:23]) |     //generlized interlace inquiry scan
           ({5{page}}    & BD_ADDR[27:23]) |
           ({5{inquiry}} & BD_ADDR[27:23]) |
           ({5{mpr}}     & BD_ADDR[27:23]) |   //master page respone
           ({5{spr}}     & BD_ADDR[27:23]) |   //slave page response
           ({5{ir}}      & BD_ADDR[27:23]) |    //inquiry response
           ({5{conns}}   & BD_ADDR[27:23] ^ CLK[25:21]);     //connection state

assign B = BD_ADDR[22:19];

assign C = ({5{ps}}      & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |    //page scan
           ({5{gips}}    & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |  //generlized interlace page scan
           ({5{is}}      & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |       //inquiry scan
           ({5{giis}}    & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |     //generlized interlace inquiry scan
           ({5{page}}    & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |
           ({5{inquiry}} & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |
           ({5{mpr}}     & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |   //master page respone
           ({5{spr}}     & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |   //slave page response
           ({5{ir}}      & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]}) |    //inquiry response
           ({5{conns}}   & {BD_ADDR[8],BD_ADDR[6],BD_ADDR[4],BD_ADDR[2],BD_ADDR[0]} ^ CLK[20:16]);     //connection state

assign D = ({9{ps}}      & BD_ADDR[18:10]) |    //page scan
           ({9{gips}}    & BD_ADDR[18:10]) |  //generlized interlace page scan
           ({9{is}}      & BD_ADDR[18:10]) |       //inquiry scan
           ({9{giis}}    & BD_ADDR[18:10]) |     //generlized interlace inquiry scan
           ({9{page}}    & BD_ADDR[18:10]) |
           ({9{inquiry}} & BD_ADDR[18:10]) |
           ({9{mpr}}     & BD_ADDR[18:10]) |   //master page respone
           ({9{spr}}     & BD_ADDR[18:10]) |   //slave page response
           ({9{ir}}      & BD_ADDR[18:10]) |    //inquiry response
           ({9{conns}}   & (BD_ADDR[18:10] ^ CLK[15:7]));     //connection state
           
assign E = {BD_ADDR[13],BD_ADDR[11],BD_ADDR[9],BD_ADDR[7],BD_ADDR[5],BD_ADDR[3],BD_ADDR[1]};           

//

//wire div_en_p = (CLK[6:0]==7'hff) & ms_tslot_p;
reg div_en_p;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     div_en_p <= 0;
  else 
     div_en_p <= (CLK[6:0]==7'hff) & ms_tslot_p;
end

wire divffclk = clk_6M;

wire [24:0] Ft, nc1;
div mod79_F(
.clk      (divffclk                   ),
.rstz     (rstz                       ),
.div_en_p (div_en_p                   ),
.dividend ({CLK[27:7],4'b0}           ),
.divisor  (7'd79                      ),
.result_o ({Ft[24:0],nc1[24:0]}       )
);

assign F = ({7{conns}} & Ft[6:0]);


wire [24:0] Fprimet, nc2;
div mod79_Fprime(
.clk      (divffclk                   ),
.rstz     (rstz                       ),
.div_en_p (div_en_p                   ),
.dividend ({CLK[27:7],4'b0}           ),
.divisor  (regi_AFH_N                 ),
.result_o ({Fprimet[24:0],nc2[24:0]}  )
);

assign Fprime = ({7{conns}} & Fprimet[6:0]);

//

endmodule
