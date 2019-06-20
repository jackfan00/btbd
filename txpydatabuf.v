module txpydatabuf(
mpr, ir,
regi_packet_type,
regi_payloadlen,
CLK,
regi_FHS_LT_ADDR,
regi_myClass,
regi_my_BD_ADDR_NAP,
regi_my_BD_ADDR_UAP,
regi_SR,
regi_EIR,
regi_my_BD_ADDR_LAP,
regi_my_syncword,
is_BRmode, is_eSCO, is_SCO, is_ACL,
pk_type,
//
pylenbit,
occpuy_slots,
fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK,
BRss

);
input mpr, ir;
input [3:0] regi_packet_type;
input [9:0] regi_payloadlen;
input [27:0] CLK;
input [2:0] regi_FHS_LT_ADDR;
input [23:0] regi_myClass;
input [15:0] regi_my_BD_ADDR_NAP;
input [7:0] regi_my_BD_ADDR_UAP;
input [1:0] regi_SR;
input regi_EIR;
input [23:0] regi_my_BD_ADDR_LAP;
input [33:0] regi_my_syncword;
input is_BRmode, is_eSCO, is_SCO, is_ACL;
input [3:0] pk_type;
//
output [12:0] pylenbit;
output [2:0] occpuy_slots;
output fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK;
output BRss;

//
//wire [143:0] FHSpacket = {3'b0, CLK[27:2], regi_FHS_LT_ADDR[2:0], regi_myClass[23:0], regi_my_BD_ADDR_NAP[15:0], 
//                    regi_my_BD_ADDR_UAP[7:0], 2'b10, regi_SR[1:0], 1'b0, regi_EIR, regi_my_BD_ADDR_LAP[23:0], regi_my_syncword[33:0]};



wire [12:0] pylenbit;
wire [2:0] occpuy_slots;
wire fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK;

//wire [3:0] pk_type = mpr | ir ? 4'h2 : regi_packet_type;
//
pktydecode pktydecode_u(
.is_BRmode      (is_BRmode      ), 
.is_eSCO        (is_eSCO        ), 
.is_SCO         (is_SCO         ), 
.is_ACL         (is_ACL         ),
.pk_type        (pk_type        ),
.regi_payloadlen(regi_payloadlen),
//             (//             )
.pylenbit       (pylenbit       ),
.occpuy_slots   (occpuy_slots   ),
.fec31encode    (fec31encode    ), 
.fec32encode    (fec32encode    ), 
.crcencode      (crcencode      ), 
.packet_BRmode  (packet_BRmode  ), 
.packet_DPSK    (packet_DPSK    ),
.BRss           (BRss           )
);

//assign pybitout = pk_type==4'h2 ? FHSpacket[pybitcount] : 1'bz; //DataPacket[pybitcount];

endmodule