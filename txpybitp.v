module txpybitp(
clk_6M, rstz, p_1us, 
mpr, ir, spr,
py_st_p,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP,
whitening,
CLK,
regi_FHS_LT_ADDR,
regi_myClass,
regi_my_BD_ADDR_NAP,
regi_my_BD_ADDR_UAP,
regi_SR,
regi_EIR,
regi_my_BD_ADDR_LAP,
regi_my_syncword,
//is_BRmode, is_eSCO, is_SCO, is_ACL,
pk_type,
pylenbit,
crcencode, fec31encode, fec32encode,
py_datvalid_p,
//
txpybit, py_period,
daten,
);

input clk_6M, rstz, p_1us;
input mpr, ir, spr;
input py_st_p;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP;
input [6:0] whitening;
input [27:0] CLK;
input [2:0] regi_FHS_LT_ADDR;
input [23:0] regi_myClass;
input [15:0] regi_my_BD_ADDR_NAP;
input [7:0] regi_my_BD_ADDR_UAP;
input [1:0] regi_SR;
input regi_EIR;
input [23:0] regi_my_BD_ADDR_LAP;
input [33:0] regi_my_syncword;
//input is_BRmode, is_eSCO, is_SCO, is_ACL;
input [3:0] pk_type;
input [12:0] pylenbit;
input crcencode, fec31encode, fec32encode;
input py_datvalid_p;
//
output txpybit, py_period;
output daten;

wire py_endp;
reg py_period;
wire fec32bk_endp;

wire [12:0] payloadlen_crc = crcencode ? pylenbit + 5'd16 : pylenbit;
                   

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     py_period <= 0;
  else if (py_endp & py_datvalid_p)
     py_period <= 0;
  else if (py_st_p & (pylenbit!=13'd0))
     py_period <= 1'b1 ;
end

//
reg [3:0] fec32count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec32count <= 0;
  else if (py_st_p | fec32bk_endp)
     fec32count <= 0;
  else if (py_period & py_datvalid_p)
     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_1us & packet_BRmode)
/////////     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_05us & packet_DPSK & (!packet_BRmode) )
/////////     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_033us & (!packet_DPSK) & (!packet_BRmode) )
/////////     fec32count <= fec32count + 1'b1 ;
end

assign fec32bk_endp = fec32encode ? fec32count==4'd14 & py_datvalid_p : fec32count==4'd9 & py_datvalid_p;
assign daten = (fec32count <= 4'd9) & py_period;
assign fec32en = (fec32count > 4'd9 && fec32count<=4'd15) & py_period;

reg [12:0] encodeclen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     encodeclen <= 0;
  else if (py_st_p)
     encodeclen <= 11'd10;
  else if (fec32bk_endp)
     encodeclen <= encodeclen + 4'd10 ;
end

assign py_endp = (encodeclen >= payloadlen_crc) & fec32bk_endp;

reg [1:0] fec31count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec31count <= 0;
  else if ((fec31count==2'd2 & py_datvalid_p) | (!py_period) )
     fec31count <= 0;
  else if (py_period & py_datvalid_p)
     fec31count <= fec31count + 1'b1 ;
end

assign fec31inc_p = fec31count==2'd2 & py_datvalid_p;

reg [12:0] bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     bitcount <= 0;
  else if (py_st_p )
     bitcount <= 11'd0;
  else if (daten & py_period & fec31inc_p & fec31encode)
     bitcount <= bitcount + 1'b1 ;
  else if (daten & py_period & py_datvalid_p)
     bitcount <= bitcount + 1'b1 ;
////////  else if (daten & py_period & p_1us & packet_BRmode)
////////     bitcount <= bitcount + 1'b1 ;
////////  else if (daten & py_period & p_05us & packet_DPSK & (!packet_BRmode))
////////     bitcount <= bitcount + 1'b1 ;
////////  else if (daten & py_period & p_033us & (!packet_DPSK) & (!packet_BRmode))
////////     bitcount <= bitcount + 1'b1 ;
end

assign py_crc16period = py_period & (bitcount >= pylenbit);
assign py_datperiod = py_period & (bitcount < pylenbit);
assign py_daten = py_datperiod & daten;
//assign py_datvalid_p = packet_BRmode ? p_1us :
//                  packet_DPSK ? p_05us : p_033us;

/////////////////wire [3:0] pk_type = mpr | ir ? 4'h2 : regi_packet_type;
/////////////////
/////////////////txpydatabuf txpydatabuf_u(
/////////////////.mpr                (mpr                ), 
/////////////////.ir                 (ir                 ),
/////////////////.regi_packet_type   (regi_packet_type   ),
/////////////////.regi_payloadlen    (regi_payloadlen    ),
/////////////////.CLK                (CLK                ),
/////////////////.regi_FHS_LT_ADDR   (regi_FHS_LT_ADDR   ),
/////////////////.regi_myClass       (regi_myClass       ),
/////////////////.regi_my_BD_ADDR_NAP(regi_my_BD_ADDR_NAP),
/////////////////.regi_my_BD_ADDR_UAP(regi_my_BD_ADDR_UAP),
/////////////////.regi_SR            (regi_SR            ),
/////////////////.regi_EIR           (regi_EIR           ),
/////////////////.regi_my_BD_ADDR_LAP(regi_my_BD_ADDR_LAP),
/////////////////.regi_my_syncword   (regi_my_syncword   ),
/////////////////.is_BRmode          (is_BRmode          ), 
/////////////////.is_eSCO            (is_eSCO            ), 
/////////////////.is_SCO             (is_SCO             ), 
/////////////////.is_ACL             (is_ACL             ),
/////////////////.pk_type            (pk_type            ),
///////////////////                 (//                 )
/////////////////.pylenbit           (pylenbit           ),
/////////////////.occpuy_slots       (occpuy_slots       ),
/////////////////.fec31encode        (fec31encode        ), 
/////////////////.fec32encode        (fec32encode        ), 
/////////////////.crcencode          (crcencode          ), 
/////////////////.packet_BRmode      (packet_BRmode      ), 
/////////////////.packet_DPSK        (packet_DPSK        ),
/////////////////.BRss               (BRss               )
/////////////////
/////////////////);

wire [143:0] FHSpacket = {3'b0, CLK[27:2], regi_FHS_LT_ADDR[2:0], regi_myClass[23:0], regi_my_BD_ADDR_NAP[15:0], 
                    regi_my_BD_ADDR_UAP[7:0], 2'b10, regi_SR[1:0], 1'b0, regi_EIR, regi_my_BD_ADDR_LAP[23:0], regi_my_syncword[33:0]};

wire txpybitout = pk_type==4'h2 ? FHSpacket[bitcount] : 1'bz; //DataPacket[pybitcount];

//
pypro pypro_u(
.clk_6M                 (clk_6M                 ), 
.rstz                   (rstz                   ), 
.p_1us                  (p_1us                  ),
.regi_paged_BD_ADDR_UAP (regi_paged_BD_ADDR_UAP ), 
.regi_master_BD_ADDR_UAP(regi_master_BD_ADDR_UAP),
.regi_my_BD_ADDR_UAP    (regi_my_BD_ADDR_UAP    ),
.mpr                    (mpr                    ), 
.ir                     (ir                     ),
.spr                    (spr                    ), 
.daten                  (daten                  ), 
.py_daten               (py_daten               ), 
.py_datvalid_p          (py_datvalid_p          ), 
.py_datperiod           (py_datperiod           ), 
.py_crc16period         (py_crc16period         ),
.py_period              (py_period              ),
.py_st_p                (py_st_p                ),
.dec_py_st_p            (1'b0                   ),
.dec_py_endp            (1'b0                   ),
.dec_py_period          (1'b0                   ),
.txpybitout             (txpybitout             ),
.pk_encode              (1'b1                   ),
.fec32bk_endp           (fec32bk_endp           ),
.whitening              (whitening              ),
.rxbit                  (1'b0                   ),
//                     (//                     )
.fec32encodeout         (fec32encodeout         )
);

assign txpybit = fec32encodeout;
endmodule