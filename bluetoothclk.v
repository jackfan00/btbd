//
// 2019/04/24
// bluetooth CLK : core5.1 Spec 2.2.3
//
module bluetoothclk(
clk_6M, rstz,
page, mpr,
regi_esti_offset, regi_time_base_offset, regi_slave_offset,
regi_m_uncerWinSize, regi_s_uncerWinSize,
conns_corre_sync_p, ps_corre_sync_p, pssyncCLK_p,
fhs_CLK,
//
CLKN_master, CLK_master, CLKE_master,
CLKN_slave, CLK_slave,
Master_TX_tslot_endp, Master_RX_tslot_endp,
Slave_TX_tslot_endp, Slave_RX_tslot_endp,
m_tslot_p, s_tslot_p, p_1us, p_05us, p_033us,
m_half_tslot_p, s_half_tslot_p,
m_conns_uncerWindow, m_page_uncerWindow, spr_correWin, 
s_conns_uncerWindow,
regi_fhsslave_offset,
m_page_uncerWindow_endp

);

input clk_6M, rstz;
input page, mpr;
input [27:0] regi_esti_offset, regi_time_base_offset, regi_slave_offset;
input [8:0] regi_m_uncerWinSize;
input [8:0] regi_s_uncerWinSize;
input conns_corre_sync_p, ps_corre_sync_p, pssyncCLK_p ;
input [27:2] fhs_CLK;
//
output [27:0] CLKN_master, CLK_master, CLKE_master;
output [27:0] CLKN_slave, CLK_slave;
output Master_TX_tslot_endp, Master_RX_tslot_endp;
output Slave_TX_tslot_endp, Slave_RX_tslot_endp;
output m_tslot_p, s_tslot_p, p_1us, p_05us, p_033us;
output m_half_tslot_p, s_half_tslot_p;
output m_conns_uncerWindow, m_page_uncerWindow, spr_correWin;
output s_conns_uncerWindow;
output [27:2] regi_fhsslave_offset;
output m_page_uncerWindow_endp;

wire [27:0] CLKR_master, CLKR_slave;
wire [9:0] m_counter_1us, s_counter_1us;


wire p_1us;
reg [2:0] counter_6M;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     counter_6M <= 0;
  else if (p_1us)
     counter_6M <= 0;
  else 
     counter_6M <= counter_6M + 1'b1;
end

assign p_1us = counter_6M==3'd5;
assign p_05us = counter_6M==3'd2 | counter_6M==3'd5;
assign p_033us = counter_6M==3'd1 | counter_6M==3'd3 | counter_6M==3'd5;

wire [27:0] m_BTCLK, s_BTCLK;
timeslot timeslot_m(
.clk_6M               (clk_6M               ), 
.rstz                 (rstz                 ),
.p_1us                (p_1us                ),
.p_05us               (p_05us               ),
.regi_time_base_offset(regi_time_base_offset),
.corre_sync_p         (1'b0                 ),
.pssyncCLK_p          (1'b0                 ),
//                                         
.BTCLK                (m_BTCLK              ),
.tslot_p              (m_tslot_p            ), 
.half_tslot_p         (m_half_tslot_p       ),
.counter_1us          (m_counter_1us        )
);

assign CLKR_master = m_BTCLK;
assign CLKN_master = CLKR_master + regi_time_base_offset;
assign CLK_master  = CLKN_master;
assign CLKE_master = CLKN_master+regi_esti_offset;


//

wire corre_sync_p = conns_corre_sync_p | ps_corre_sync_p; //we dont know 1st or 2nd half, but following packet sync will correct it.

timeslot timeslot_s(
.clk_6M               (clk_6M               ), 
.rstz                 (rstz                 ),
.p_1us                (p_1us                ),
.p_05us               (p_05us               ),
.regi_time_base_offset(regi_time_base_offset),
.corre_sync_p         (corre_sync_p         ),
.pssyncCLK_p          (pssyncCLK_p          ),
//                                          
.BTCLK                (s_BTCLK              ),
.tslot_p              (s_tslot_p            ), 
.half_tslot_p         (s_half_tslot_p       ),
.counter_1us          (s_counter_1us        )

);
reg [27:2] regi_fhsslave_offset;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     regi_fhsslave_offset <= 0;
  else if (pssyncCLK_p)  
     regi_fhsslave_offset <= fhs_CLK[27:2]-CLKN_slave[27:2]+1'b1;
end

assign CLKR_slave = s_BTCLK;
assign CLKN_slave = CLKR_slave + regi_time_base_offset;
assign CLK_slave  = CLKN_slave + {regi_slave_offset[27:2], 2'b0};

assign Master_TX_tslot_endp = !CLK_master[1] & m_tslot_p;
assign Master_RX_tslot_endp = CLK_master[1]  & m_tslot_p;

assign Slave_TX_tslot_endp = CLK_slave[1]  & s_tslot_p;
assign Slave_RX_tslot_endp = !CLK_slave[1] & s_tslot_p;

//
reg m_conns_uncerWindow, m_page_uncerWindow;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     m_page_uncerWindow <= 0;
//first ID
  else if (m_counter_1us == 10'd615 && (!CLKE_master[1]) & (page|mpr))   
     m_page_uncerWindow <= 1'b1;
  else if (m_counter_1us == 10'd78 && CLKE_master[1] & (page|mpr) )
     m_page_uncerWindow <= 1'b0;
//second ID
  else if (m_counter_1us == 10'd302 && CLKE_master[1] & page)   
     m_page_uncerWindow <= 1'b1;
  else if (m_counter_1us == 10'd390 && CLKE_master[1] & page)
     m_page_uncerWindow <= 1'b0;
end

assign m_page_uncerWindow_endp = (m_counter_1us == 10'd78 && CLKE_master[1] & (page|mpr) ) |
                                 (m_counter_1us == 10'd390 && CLKE_master[1] & page) ;

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     m_conns_uncerWindow <= 0;
  else if (regi_m_uncerWinSize > 10'd312 )
     m_conns_uncerWindow <= 1'b1;     
  else if (m_counter_1us == (10'd625 - regi_m_uncerWinSize) && (!CLK_master[1]) )   
     m_conns_uncerWindow <= 1'b1;
  else if (m_counter_1us == (10'd68+regi_m_uncerWinSize) && CLK_master[1])
     m_conns_uncerWindow <= 1'b0;
end

reg s_conns_uncerWindow;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s_conns_uncerWindow <= 0;
  else if (regi_s_uncerWinSize > 10'd312 )
     s_conns_uncerWindow <= 1'b1;     
  else if (s_counter_1us == (10'd625 - regi_s_uncerWinSize) && (CLK_slave[1]) )   
     s_conns_uncerWindow <= 1'b1;
  else if (s_counter_1us == (10'd68+regi_s_uncerWinSize) && (!CLK_slave[1]))
     s_conns_uncerWindow <= 1'b0;
end

reg spr_correWin;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     spr_correWin <= 0;
  else if (regi_s_uncerWinSize > 10'd312 )
     spr_correWin <= 1'b1;     
  else if (s_counter_1us == (10'd625 - regi_s_uncerWinSize) && (CLKN_slave[1]) )   
     spr_correWin <= 1'b1;
  else if (s_counter_1us == (10'd68+regi_s_uncerWinSize) && (!CLKN_slave[1]))
     spr_correWin <= 1'b0;
end

endmodule
