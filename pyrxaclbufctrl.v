//
// Vol2 Part B ch 4.5
//
module pyrxaclbufctrl (
clk_6M, rstz,
m_tslot_p, s_tslot_p, pk_encode, hecgood, crcgood,
regi_isMaster,
dec_pylenByte,
bsm_valid_p,
bsm_addr, lnctrl_addr,
lnctrl_din,
lnctrl_we,
bsm_cs, lnctrl_cs,
//
bsm_dout
);

input clk_6M, rstz;
input m_tslot_p, s_tslot_p, pk_encode, hecgood, crcgood;
input regi_isMaster;
input [9:0] dec_pylenByte;
input bsm_valid_p;
input [7:0] bsm_addr, lnctrl_addr;
input [31:0] lnctrl_din;
input lnctrl_we;
input bsm_cs, lnctrl_cs;
//
output [31:0] bsm_dout;

wire bsm_read_endp;
wire [31:0] u0_bsm_dout, u1_bsm_dout;

wire ms_tslot_p = regi_isMaster ? m_tslot_p : s_tslot_p;
reg s1a;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     s1a <= 0;
  else if (bsm_read_endp)
     s1a <= ~s1a ;
end

wire [7:0]  u0_sram_a    = s1a ? lnctrl_addr : bsm_addr;
wire [31:0] u0_sram_din  = s1a ? lnctrl_din  : 32'b0;
wire [7:0]  u0_sram_we   = s1a ? lnctrl_we   : 1'b0;
wire        u0_sram_cs   = s1a ? lnctrl_cs   : bsm_cs;

reg [9:0] u0_length;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     u0_length <= 0;
  else if (ms_tslot_p & !pk_encode & hecgood & crcgood & s1a)
     u0_length <= dec_pylenByte;
end
sram256x32_1p sram256x32_1p_u0(
.A   (u0_sram_a     ),
.DIN (u0_sram_din   ),
.CLK (clk_6M        ),
.WE  (u0_sram_we    ),
.CS  (u0_sram_cs    ),
//
.DOUT(u0_bsm_dout   )
);

wire [7:0]  u1_sram_a    = !s1a ? lnctrl_addr : bsm_addr;
wire [31:0] u1_sram_din  = !s1a ? lnctrl_din  : 32'b0;
wire [7:0]  u1_sram_we   = !s1a ? lnctrl_we   : 1'b0;
wire        u1_sram_cs   = !s1a ? lnctrl_cs   : bsm_cs;

reg [9:0] u1_length;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     u1_length <= 0;
  else if (ms_tslot_p & !pk_encode & hecgood & crcgood & !s1a)
     u1_length <= dec_pylenByte;
end

sram256x32_1p sram256x32_1p_u1(
.A   (u1_sram_a     ),
.DIN (u1_sram_din   ),
.CLK (clk_6M        ),
.WE  (u1_sram_we    ),
.CS  (u1_sram_cs    ),
//
.DOUT(u1_bsm_dout   )
);

assign bsm_dout = s1a ? u1_bsm_dout : u0_bsm_dout;
wire [9:0] pylenByte = s1a ? u1_length : u0_length;
wire [7:0] endaddr = (pylenByte[1:0]==2'b0) ? pylenByte[9:2]-1'b1 : pylenByte[9:2];
assign bsm_read_endp = (bsm_addr >= endaddr) & bsm_valid_p;

endmodule