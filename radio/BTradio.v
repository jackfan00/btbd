//
// 2019/07/12
// BT radio behavoir model
// freq = 2042+k Mhz
// GFSK : +-300Khz
// 

module BTradio(
clk_6M, rstz, p_1us,
connsactive, CLK,
txsymbolin, rxsymbolin,
txen, rxen,
lc_fk, rxfk,
loadfreq_p,
//
txsymbolout, rxsymbolout,
txfk

);

input clk_6M, rstz, p_1us;
input connsactive;
input [27:0] CLK;
input [2:0] txsymbolin, rxsymbolin;
input txen, rxen;
input [6:0] lc_fk, rxfk;
input loadfreq_p;
//
output [2:0] txsymbolout, rxsymbolout;
output [6:0] txfk;
//
parameter PLL_SetUp_Time = 600; // 100us

//
reg [6:0] pllload_fk;
always @(posedge clk_6M or negedge rstz)
  begin
    if (!rstz)
      pllload_fk <= 0;
    else if ( loadfreq_p)
      pllload_fk <= lc_fk;
  end

// simulate pll locking time
wire [6:0] pll_fk;
wire plllocking;
reg [9:0] pllcnt;
always @(posedge clk_6M or negedge rstz)
  begin
    if (!rstz)
      pllcnt <= 0;
    else if (loadfreq_p & (pll_fk!=lc_fk))
      pllcnt <= 0;
    else if (plllocking)
      pllcnt <= pllcnt+1'b1;
  end
assign plllocking = pllcnt < PLL_SetUp_Time;

assign pll_fk = plllocking ? pllload_fk ^ {pllcnt[6:1],1'b1} : pllload_fk;

assign rxsymbolout = rxen & (rxfk==pll_fk) ? rxsymbolin : 3'b0;

assign txfk = txen ? pll_fk : 7'hx;

wire biterr;
assign txsymbolout = txen ? txsymbolin^{2'b0,biterr} : 3'b0;

//
// for test re-tx
reg [10:0] bitcnt;
always @(posedge clk_6M or negedge rstz)
  begin
    if (!rstz)
      bitcnt <= 0;
    else if (!txen)
      bitcnt <= 0;
    else if (txen & p_1us)
      bitcnt <= bitcnt+1'b1;
  end

assign biterr = connsactive & bitcnt==11'd135 & CLK[2];



endmodule