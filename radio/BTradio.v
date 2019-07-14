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
k, rxk,
loadfreq_p,
//
txbitout, rxbitout,
stable_k

);

input clk_6M, rstz;
input txbitin, rxbitin;
input txen, rxen;
input [6:0] k, rxk;
input loadfreq_p;
//
output txbitout, rxbitout;
output [6:0] stable_k;
//
parameter PLL_SetUp_Time = 100000; // 100us

//
assign ttxbitout = txen ? txbitin : 1'bx;
reg [6:0] stable_k;
always @(posedge clk_6M or negedge rstz)
  begin
    if (!rstz)
      stable_k = 0;
    else if ( loadfreq_p)
      stable_k = #PLL_SetUp_Time k;
  end
assign rxbitout = rxen & (rxk==stable_k) ? rxbitin : 1'b0;

endmodule