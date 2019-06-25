module bufctrl();

input clk_6M, rstz;
input ms_tslot_p;
input [12:0] pybitcount;
input regi_LMPcmd_p;
input tx_reservedslot, rx_reservedslot, txtsco_p, rxtsco_p;
input [7:0] txbsmacl_addr, txbsmsco_addr;
input [31:0] txbsmacl_din, txbsmsco_din;
input txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs;
input [7:0] txlnctrl_addr;
input [7:0] rxbsmacl_addr, rxbsmsco_addr, rxlnctrl_addr;
input [31:0] rxlnctrl_din;
input rxlnctrl_we, rxlnctrl_cs, rxbsmacl_cs, rxbsmsco_cs;
input txaclSEQN;
output lnctrl_txpybitin;

wire [31:0] lncacl_dout, lncsco_dout;


reg LMPcmd, LMP_c_slot;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     LMPcmd <= 1'b0;
  else if (regi_LMPcmd_p)
     LMPcmd <= 1'b1;
  else if (ms_tslot_p)
     LMPcmd <= 1'b0 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     LMP_c_slot <= 1'b0;
  else if (LMPcmd & ms_tslot_p)
     LMP_c_slot <= 1'b1;
  else if (ms_tslot_p)
     LMP_c_slot <= 1'b0 ;
end

wire [7:0] txlnctrl_addr = pybitcount[12:5];
wire lncacl_cs = py_datperiod & (LMP_c_slot | (!tx_reservedslot);
wire lncsco_cs = py_datperiod & ((!LMP_c_slot) & tx_reservedslot);

wire [31:0] lnctrl_bufpacket = ({32{txlncacl_cs}} & lncacl_dout) |
                               ({32{txlncsco_cs}} & lncsco_dout) ;

assign lnctrl_txpybitin = lnctrl_bufpacket[pybitcount[4:0]];

pytxaclbufctrl pytxaclbufctrl_u(
.clk_6M     (clk_6M     ), 
.rstz       (rstz       ),
.bsm_addr   (txbsmacl_addr   ), 
.lnctrl_addr(txlnctrl_addr),
.bsm_din    (txbsmacl_din    ),
.bsm_we     (txbsmacl_we     ),
.bsm_cs     (txbsmacl_cs     ), 
.lnctrl_cs  (txlncacl_cs  ),
.txaclSEQN  (txaclSEQN  ),
//
.lnctrl_dout(lncacl_dout)
);

pytxscobufctrl pytxscobufctrl_u(
.clk_6M     (clk_6M     ), 
.rstz       (rstz       ),
.tsco_p     (txtsco_p     ), 
.bsm_addr   (txbsmsco_addr   ), 
.lnctrl_addr(txlnctrl_addr),
.bsm_din    (txbsmsco_din    ),
.bsm_we     (txbsmsco_we     ),
.bsm_cs     (txbsmsco_cs     ), 
.lnctrl_cs  (txlncsco_cs  ),
//
.lnctrl_dout(lncsco_dout)
);

wire rxlnctrlacl_cs = rxlnctrl_cs & (dec_LMP_c_slot | (!rx_reservedslot));
wire rxlnctrlsco_cs = rxlnctrl_cs & ((!dec_LMP_c_slot) & rx_reservedslot);

pyrxaclbufctrl pyrxaclbufctrl_u(
.clk_6M        (clk_6M        ), 
.rstz          (rstz          ),
.bsm_addr      (rxbsmacl_addr      ), 
.lnctrl_addr   (rxlnctrl_addr   ),
.lnctrl_din    (rxlnctrl_din    ),
.lnctrl_we     (rxlnctrl_we     ),
.bsm_cs        (rxbsmacl_cs        ), 
.lnctrl_cs     (rxlnctrlacl_cs     ),
//
.bsm_dout      (bsmacl_dout   )

);

pyrxscobufctrl pyrxscobufctrl_u(
.clk_6M        (clk_6M        ), 
.rstz          (rstz          ),
.tsco_p        (rxtsco_p        ), 
.bsm_addr      (rxbsmsco_addr      ), 
.lnctrl_addr   (rxlnctrl_addr   ),
.lnctrl_din    (rxlnctrl_din    ),
.lnctrl_we     (rxlnctrl_we     ),
.bsm_cs        (rxbsmsco_cs        ), 
.lnctrl_cs     (rxlnctrlsco_cs     ),
//
.bsm_dout      (bsmsco_dout   )

assign bsm_dout = ({32{rxbsmacl_cs}} & bsmacl_dout) |
                  ({32{rxbsmsco_cs}} & bsmsco_dout) ;

endmodule
