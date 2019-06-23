//
// Vol2 Part B ch 4.5
//
module pytxaclbufctrl (
clk_6M, rstz,
ack_p, nak_p, flushcmd_p,
bsm_addr, inctrl_addr,
bsm_din,
bsm_we,
bsm_cs, lnctrl_cs,
//
lnctrl_dout,
txaclSEQN
);

input clk_6M, rstz;
input ack_p, nak_p, flushcmd_p;
input [7:0] bsm_addr, inctrl_addr;
input [31:0] bsm_din;
input bsm_we;
input bsm_cs, lnctrl_cs;
//
output [31:0] lnctrl_dout;
output txaclSEQN;

reg s1a;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s1a <= 0;
  else if (ack_p | flushcmd_p)
     s1a <= ~s1a ;
end

assign txaclSEQN = s1a;

wire [7:0]  sram_a    = s1a ? bsm_addr : lnctrl_addr;
wire [31:0] sram_din  = s1a ? bsm_din  : 32'b0;
wire [7:0]  sram_we   = s1a ? bsm_we   : 1'b0;
wire        sram_cs   = s1a ? bsm_cs   : lnctrl_cs;

sram256x32_1p sram256x32_1p_u(
.A   (sram_a     ),
.DIN (sram_din   ),
.CLK (clk_6M     ),
.WE  (sram_we    ),
.CS  (sram_cs    ),
//
.DOUT(inctrl_dout)
);

 


endmodule
