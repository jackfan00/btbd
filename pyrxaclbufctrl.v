//
// Vol2 Part B ch 4.5
//
module pyrxaclbufctrl (
clk_6M, rstz,
bsm_read_endp,
bsm_addr, inctrl_addr,
lnctrl_din,
lnctrl_we,
bsm_cs, lnctrl_cs,
//
bsm_dout
);

input clk_6M, rstz;
input bsm_read_endp;
input [7:0] bsm_addr, inctrl_addr;
input [31:0] lnctrl_din;
input lnctrl_we;
input bsm_cs, lnctrl_cs;
//
output [31:0] bsm_dout;

reg s1a;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s1a <= 0;
  else if (bsm_read_endp)
     s1a <= ~s1a ;
end

wire [7:0]  sram_a    = s1a ? lnctrl_addr : bsm_addr;
wire [31:0] sram_din  = s1a ? lnctrl_din  : 32'b0;
wire [7:0]  sram_we   = s1a ? lnctrl_we   : 1'b0;
wire        sram_cs   = s1a ? lnctrl_cs   : bsm_cs;

sram256x32_1p sram256x32_1p_u(
.A   (sram_a     ),
.DIN (sram_din   ),
.CLK (clk_6M     ),
.WE  (sram_we    ),
.CS  (sram_cs    ),
//
.DOUT(bsm_dout   )
);

 


endmodule
