//
// Vol2 Part B ch 4.5
//
module pytxaclbufctrl (
clk_6M, rstz,
bsm_addr, lnctrl_addr,
bsm_din,
bsm_we,
bsm_cs, lnctrl_cs,
s1a,
//
lnctrl_dout
);

input clk_6M, rstz;
input [7:0] bsm_addr, lnctrl_addr;
input [31:0] bsm_din;
input bsm_we;
input bsm_cs, lnctrl_cs;
input s1a;

//
output [31:0] lnctrl_dout;


//wire s1a = txaclSEQN;

wire [7:0]  u0_sram_a    = s1a ? bsm_addr : lnctrl_addr;
wire [31:0] u0_sram_din  = s1a ? bsm_din  : 32'b0;
wire        u0_sram_we   = s1a ? bsm_we   : 1'b0;
wire        u0_sram_cs   = s1a ? bsm_cs   : lnctrl_cs;

wire [31:0] u0_dout;
sram256x32_1p sram256x32_1p_u0(
.A   (u0_sram_a     ),
.DIN (u0_sram_din   ),
.CLK (clk_6M        ),
.WE  (u0_sram_we    ),
.CS  (u0_sram_cs    ),
//
.DOUT(u0_dout       )
);

wire [7:0]  u1_sram_a    = !s1a ? bsm_addr : lnctrl_addr;
wire [31:0] u1_sram_din  = !s1a ? bsm_din  : 32'b0;
wire        u1_sram_we   = !s1a ? bsm_we   : 1'b0;
wire        u1_sram_cs   = !s1a ? bsm_cs   : lnctrl_cs;

wire [31:0] u1_dout;
sram256x32_1p sram256x32_1p_u1(
.A   (u1_sram_a     ),
.DIN (u1_sram_din   ),
.CLK (clk_6M        ),
.WE  (u1_sram_we    ),
.CS  (u1_sram_cs    ),
//
.DOUT(u1_dout       )
);

wire [31:0] dout = s1a ? u1_dout : u0_dout;
wire sram_cs = s1a ? u1_sram_cs : u0_sram_cs;
//
reg [31:0] inctrl_dout;
always @(posedge clk_6M)
begin
  if (sram_cs)
     inctrl_dout <= dout ;
end 


endmodule
