module timeslot(
clk_6M, rstz, p_1us, p_05us,
regi_time_base_offset,
corre_sync_p, pssyncCLK_p,
//
BTCLK,
tslot_p, half_tslot_p,
counter_1us

);

input clk_6M, rstz, p_1us, p_05us;
input [27:0] regi_time_base_offset;
input corre_sync_p, pssyncCLK_p;
//
output [27:0] BTCLK;
output tslot_p, half_tslot_p;
output [9:0] counter_1us;

wire tslot_p;
reg [9:0] counter_1us;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     counter_1us <= 0;
  else if (tslot_p)
     counter_1us <= 0;
  else if (corre_sync_p)
     counter_1us <= 10'd68;   // 4(preamble length) + 64 (syncword-length)
  else if (p_1us)
     counter_1us <= counter_1us + 1'b1;
end
assign tslot_p = (counter_1us == 10'd624) & p_1us;
assign half_tslot_p = (counter_1us == 10'd312) & p_1us; //p_05us;

reg [27:0] BTCLK;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     BTCLK <= 0;
  else if (pssyncCLK_p | corre_sync_p)
     BTCLK <= {BTCLK[27:2], 1'b0, 1'b0};
  else if (half_tslot_p || tslot_p)
     BTCLK <= BTCLK + 1'b1;
end

//



endmodule
