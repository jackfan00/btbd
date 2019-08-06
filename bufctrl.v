module bufctrl(
clk_6M, rstz,
sendnewpy,
regi_txdatready,
hec_endp, tx_packet_st_p,
pktype_data,
regi_chgbufcmd_p,
LMP_c_slot,
dec_hecgood, dec_crcgood,
dec_pylenByte,
header_st_p,
pk_encode,
py_endp,
ms_lt_addr,
dec_arqn, dec_flow,
ms_tslot_p,
pybitcount,
dec_LMPcmd,
py_datperiod, dec_py_period,
tx_reservedslot, rx_reservedslot, txtsco_p, rxtsco_p,
txbsmacl_addr, txbsmsco_addr,
txbsmacl_din, txbsmsco_din,
txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs,
//[7:0] txlnctrl_addr,
rxbsmacl_addr, rxbsmsco_addr, rxlnctrl_addr,
rxbsm_valid_p,
rxlnctrl_din,
rxlnctrl_we, rxbsmacl_cs, rxbsmsco_cs,
//
lnctrl_txpybitin,
bsm_dout,
regi_aclrxbufempty,
regi_txs1a
);

input clk_6M, rstz;
input sendnewpy;
input regi_txdatready;
input hec_endp, tx_packet_st_p;
input pktype_data;
input regi_chgbufcmd_p;
input LMP_c_slot;
input dec_hecgood, dec_crcgood;
input [9:0] dec_pylenByte;
input header_st_p;
input pk_encode;
input py_endp;
input [2:0] ms_lt_addr;
input [7:0] dec_arqn, dec_flow;
input ms_tslot_p;
input [12:0] pybitcount;
input dec_LMPcmd;
input py_datperiod, dec_py_period;
input tx_reservedslot, rx_reservedslot, txtsco_p, rxtsco_p;
input [7:0] txbsmacl_addr, txbsmsco_addr;
input [31:0] txbsmacl_din, txbsmsco_din;
input txbsmacl_we, txbsmsco_we, txbsmacl_cs, txbsmsco_cs;
//input [7:0] txlnctrl_addr;
input [7:0] rxbsmacl_addr, rxbsmsco_addr, rxlnctrl_addr;
input rxbsm_valid_p;
input [31:0] rxlnctrl_din;
input rxlnctrl_we, rxbsmacl_cs, rxbsmsco_cs;

//
output lnctrl_txpybitin;
output [31:0] bsm_dout;
output regi_aclrxbufempty;
output regi_txs1a;

wire [31:0] lncacl_dout, lncsco_dout;
wire [31:0] bsmacl_dout, bsmsco_dout;


//reg LMPcmd, LMP_c_slot;
//always @(posedge clk_6M or negedge rstz)
//begin
//  if (!rstz)
//     LMPcmd <= 1'b0;
//  else if (regi_LMPcmd_p)
//     LMPcmd <= 1'b1;
//  else if (ms_tslot_p)
//     LMPcmd <= 1'b0 ;
//end

////LMP command contain only 1 slot
//always @(posedge clk_6M or negedge rstz)
//begin
//  if (!rstz)
//     LMP_c_slot <= 1'b0;
//  else if (LMPcmd & ms_tslot_p)
//     LMP_c_slot <= 1'b1;
//  else if (ms_tslot_p)
//     LMP_c_slot <= 1'b0 ;
//end

wire [7:0] txlnctrl_addr = pybitcount[12:5];
wire txlncacl_cs = py_datperiod & (LMP_c_slot | (!tx_reservedslot));
wire txlncsco_cs = py_datperiod & ((!LMP_c_slot) & tx_reservedslot);

wire [31:0] lnctrl_bufpacket = ({32{txlncacl_cs}} & lncacl_dout) |
                               ({32{txlncsco_cs}} & lncsco_dout) ;

assign lnctrl_txpybitin = lnctrl_bufpacket[pybitcount[4:0]];

//
//determine whether can tx next pyload or not 
//
////////reg [7:0] cantxnxtpy;
////////always @(posedge clk_6M or negedge rstz)
////////begin
////////  if (!rstz)
////////     cantxnxtpy <= 0;
////////  else if (dec_arqn[ms_lt_addr] & dec_flow[ms_lt_addr] & & dec_hecgood & hec_endp & (!pk_encode))  
////////     cantxnxtpy[ms_lt_addr] <= 1'b1;
////////  else if (hec_endp)
////////     cantxnxtpy[ms_lt_addr] <= 1'b0;  
////////end

//
// master: mcu issue tx cmd every time he want to tx
//  in case of re-transmit (NAK), mcu check whether regi_txs1a change or not
//  mcu continue issue tx cmd, because regi_txs1a not change, it send old data
//  mcu should write new data to fifo after regi_txs1a change
// slave : just simple follow master's tx slot, mcu dont need issue tx cmd 

reg regi_txs1a;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     regi_txs1a <= 1'b0;
  else if (regi_chgbufcmd_p)  //switch condition is control by mcu for 1st packet 
     regi_txs1a <= ~regi_txs1a;
//after mcu write tx data to sram, mcu set ready flag, then BB_LC tx   
//  else if (cantxnxtpy[ms_lt_addr] & regi_txdatready & tx_packet_st_p)
  else if (sendnewpy & tx_packet_st_p)  //& regi_txdatready
     regi_txs1a <= ~regi_txs1a;
//
//  mcu must write next pyload before
//  ack=1 and flow=1 then transmit next pyload 
  //else if (dec_arqn[ms_lt_addr] & dec_flow[ms_lt_addr] & & dec_hecgood & hec_endp & (!pk_encode))  
  //   regi_txs1a <= ~regi_txs1a;
  // change back to previous packet, if previous flow is STOP
  // Vol2 PartB  4.5.3.2
  //else if ((dec_flow[ms_lt_addr] == 1'b0) & pk_encode & header_st_p)  
  //   regi_txs1a <= ~regi_txs1a;
      
end

pytxaclbufctrl pytxaclbufctrl_u(
.clk_6M     (clk_6M          ), 
.rstz       (rstz            ),
.bsm_addr   (txbsmacl_addr   ), 
.lnctrl_addr(txlnctrl_addr   ),
.bsm_din    (txbsmacl_din    ),
.bsm_we     (txbsmacl_we     ),
.bsm_cs     (txbsmacl_cs     ), 
.lnctrl_cs  (txlncacl_cs     ),
.s1a        (regi_txs1a      ),
//
.lnctrl_dout(lncacl_dout     )
);

pytxscobufctrl pytxscobufctrl_u(
.clk_6M     (clk_6M          ), 
.rstz       (rstz            ),
.tsco_p     (txtsco_p        ), 
.bsm_addr   (txbsmsco_addr   ), 
.lnctrl_addr(txlnctrl_addr   ),
.bsm_din    (txbsmsco_din    ),
.bsm_we     (txbsmsco_we     ),
.bsm_cs     (txbsmsco_cs     ), 
.lnctrl_cs  (txlncsco_cs     ),
//
.lnctrl_dout(lncsco_dout     )
);

//LMP command contain only 1 slot
reg dec_LMP_c_slot;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_LMP_c_slot <= 1'b0;
  else if (dec_LMPcmd & ms_tslot_p)
     dec_LMP_c_slot <= 1'b1;
  else if (ms_tslot_p)
     dec_LMP_c_slot <= 1'b0;
end

wire rxlnctrlacl_cs = dec_py_period & (dec_LMP_c_slot | (!rx_reservedslot));
wire rxlnctrlsco_cs = dec_py_period & ((!dec_LMP_c_slot) & rx_reservedslot);

pyrxaclbufctrl pyrxaclbufctrl_u(
.clk_6M        (clk_6M          ), 
.rstz          (rstz            ),
.pktype_data   (pktype_data     ),
.pk_encode     (pk_encode       ), 
.dec_hecgood   (dec_hecgood     ), 
.dec_crcgood   (dec_crcgood     ),
.ms_tslot_p    (ms_tslot_p      ),
.dec_pylenByte (dec_pylenByte   ),
.bsm_valid_p   (rxbsm_valid_p   ),
.bsm_addr      (rxbsmacl_addr   ), 
.lnctrl_addr   (rxlnctrl_addr   ),
.lnctrl_din    (rxlnctrl_din    ),
.lnctrl_we     (rxlnctrl_we     ),
.bsm_cs        (rxbsmacl_cs     ), 
.lnctrl_cs     (rxlnctrlacl_cs  ),
//
.bsm_dout      (bsmacl_dout     ),
.regi_aclrxbufempty(regi_aclrxbufempty)

);

pyrxscobufctrl pyrxscobufctrl_u(
.clk_6M        (clk_6M          ), 
.rstz          (rstz            ),
.tsco_p        (rxtsco_p        ), 
.bsm_addr      (rxbsmsco_addr   ), 
.lnctrl_addr   (rxlnctrl_addr   ),
.lnctrl_din    (rxlnctrl_din    ),
.lnctrl_we     (rxlnctrl_we     ),
.bsm_cs        (rxbsmsco_cs     ), 
.lnctrl_cs     (rxlnctrlsco_cs  ),
//
.bsm_dout      (bsmsco_dout     )
);

assign bsm_dout = ({32{rxbsmacl_cs}} & bsmacl_dout) |
                  ({32{rxbsmsco_cs}} & bsmsco_dout) ;

endmodule
