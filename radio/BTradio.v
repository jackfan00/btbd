//
// 2019/07/12
// BT radio behavoir model
// freq = 2042+k Mhz
// GFSK : +-300Khz
// 

module BTradio(
clk_6M, rstz,
txbitin, rxbitin,
txen, rxen,
lc_fk, rxfk,
loadfreq_p,
//
txbitout, rxbitout,
txfk

);

input clk_6M, rstz;
input txbitin, rxbitin;
input txen, rxen;
input [6:0] lc_fk, rxfk;
input loadfreq_p;
//
output txbitout, rxbitout;
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

assign rxbitout = rxen & (rxfk==pll_fk) ? rxbitin : 1'b0;

assign txfk = txen ? pll_fk : 7'hx;

assign txbitout = txen ? txbitin : 1'b0;

endmodule