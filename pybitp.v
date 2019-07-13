module pybitp(
clk_6M, rstz, p_1us, 
packet_BRmode, packet_DPSK,
mpr, ir, spr, psrxfhs, inquiryrxfhs,
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
pk_encode,
BRss,
existpyheader,
bufpacketin,
rxbit,
//
pybitcount,
txpybit, py_period,
daten,
dec_py_period,
dec_pylenByte,
dec_crcgood,
dec_LLID,
dec_pyFLOW,
fhs_Pbits,
fhs_LAP,
fhs_EIR,
fhs_SR,
fhs_SP,
fhs_UAP,
fhs_NAP,
fhs_CoD,
fhs_LT_ADDR,
fhs_CLK,
fhs_PSM,
rxpydin,
rxpyadr,
rxpydin_valid_p_wr,
py_endp,
dec_py_endp,
py_datperiod,
edrtailer,
edrtailer_endp

);

input clk_6M, rstz, p_1us;
input packet_BRmode, packet_DPSK;
input mpr, ir, spr, psrxfhs, inquiryrxfhs;
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
input pk_encode;
input BRss;
input existpyheader;
input bufpacketin;
input rxbit;
//
output [12:0] pybitcount;
output txpybit, py_period;
output daten;
output dec_py_period;
output [9:0] dec_pylenByte;
output dec_crcgood;
output [1:0] dec_LLID;
output dec_pyFLOW;
output [33:0] fhs_Pbits;
output [23:0] fhs_LAP;
output        fhs_EIR;
output [1:0]  fhs_SR;
output [1:0]  fhs_SP;
output [7:0]  fhs_UAP;
output [15:0] fhs_NAP;
output [23:0] fhs_CoD;
output [2:0]  fhs_LT_ADDR;
output [27:2] fhs_CLK;
output [2:0]  fhs_PSM;
output [31:0] rxpydin;
output [7:0] rxpyadr;
output rxpydin_valid_p_wr;
output py_endp;
output dec_py_endp;
output py_datperiod;
output edrtailer;
output edrtailer_endp;

//
reg py_period;
wire fec32bk_endp;
reg [12:0] bitcount;
reg [12:0] dec_pybitcnt;

wire [9:0] fec32decodeBus;

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

reg dec_py_period;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_py_period <= 0;
  else if (dec_py_endp & py_datvalid_p)
     dec_py_period <= 0;
  else if (fec32bk_endp & py_datvalid_p & (pylenbit!=13'd0) & (!pk_encode))
     dec_py_period <= 1'b1 ;
end

wire dec_py_st_p = fec32bk_endp & py_period & (!dec_py_period) & (!pk_encode);


//
reg [3:0] fec32count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec32count <= 0;
  else if (py_st_p | fec32bk_endp)
     fec32count <= 0;
  else if ((py_period|dec_py_period) & py_datvalid_p)
     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_1us & packet_BRmode)
/////////     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_05us & packet_DPSK & (!packet_BRmode) )
/////////     fec32count <= fec32count + 1'b1 ;
/////////  else if (py_period & p_033us & (!packet_DPSK) & (!packet_BRmode) )
/////////     fec32count <= fec32count + 1'b1 ;
end

assign fec32bk_endp = fec32encode ? fec32count==4'd14 & py_datvalid_p : fec32count==4'd9 & py_datvalid_p;
assign daten = (fec32count <= 4'd9) & (py_period|dec_py_period);
assign fec32en = (fec32count > 4'd9 && fec32count<=4'd15) & (py_period|dec_py_period);

reg [12:0] processlen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     processlen <= 0;
  else if (py_st_p)
     processlen <= 11'd10;
  else if (fec32bk_endp)
     processlen <= processlen + 4'd10 ;
end

assign py_endp = fec32encode ? (processlen >= payloadlen_crc) & fec32bk_endp : (bitcount==(payloadlen_crc-1'b1)) & py_datvalid_p;
assign dec_py_endp = fec32encode ? (processlen >= (payloadlen_crc+4'd10)) & fec32bk_endp : (dec_pybitcnt==(payloadlen_crc-1'b1)) & py_datvalid_p;

wire edrtailer_endp;
reg edrtailer;
reg [2:0] edrtailer_cnt;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     edrtailer <= 0;
  else if (py_endp & !packet_BRmode )
     edrtailer <= 1'b1;
  else if (edrtailer_endp)
     edrtailer <= 1'b0 ;
end
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     edrtailer_cnt <= 0;
  else if ((py_endp & !packet_BRmode) | py_period)
     edrtailer_cnt <= 0;
  else if (py_datvalid_p & edrtailer)
     edrtailer_cnt <= edrtailer_cnt + 1'b1 ;
end
assign edrtailer_endp = packet_DPSK ? edrtailer_cnt==3'd3 : edrtailer_cnt==3'd5;

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
assign pybitcount = bitcount;
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

wire txpybitin = pk_type==4'h2 ? FHSpacket[bitcount] : bufpacketin; //DataPacket[pybitcount];

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
.dec_py_period          (dec_py_period          ),
.py_st_p                (py_st_p                ),
.dec_py_st_p            (dec_py_st_p            ),
.dec_py_endp            (dec_py_endp            ),
.txpybitin              (txpybitin              ),
.pk_encode              (pk_encode              ),
.fec32bk_endp           (fec32bk_endp           ),
.whitening              (whitening              ),
.fec32encode            (fec32encode            ),
.rxbit                  (rxbit                  ),
//                     (//                     )
.fec32encodeout         (fec32encodeout         ),
.fec32decodeBus         (fec32decodeBus         ),
.decode_latch_p         (decode_latch_p         ),
.dec_crcgood            (dec_crcgood            ),
.pydecdatout            (pydecdatout            )
);

assign txpybit = fec32encodeout;


//
// payload header decode
//
reg [8:0] pydecdatout_d;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pydecdatout_d <= 0;
  else if (py_datvalid_p)
     pydecdatout_d <= {pydecdatout_d[7:0],pydecdatout};
end
reg [1:0] dec_LLID;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_LLID <= 0;
  else if (bitcount==12'hb & py_datvalid_p & existpyheader)
     dec_LLID <= {pydecdatout,pydecdatout_d[0]};
end
reg dec_pyFLOW;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_pyFLOW <= 0;
  else if (bitcount==12'hc & py_datvalid_p & existpyheader)
     dec_pyFLOW <= pydecdatout;
end

reg [9:0] dec_pylenByte;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_pylenByte <= 0;
  else if (bitcount==12'h11 & py_datvalid_p & BRss & existpyheader)
     dec_pylenByte <= {5'b0,pydecdatout,pydecdatout_d[0],pydecdatout_d[1],pydecdatout_d[2],pydecdatout_d[3]};
  else if (bitcount==12'h16 & py_datvalid_p & (!BRss) & existpyheader)
     dec_pylenByte <= {pydecdatout,pydecdatout_d[0],pydecdatout_d[1],pydecdatout_d[2],pydecdatout_d[3],
                       pydecdatout_d[4],pydecdatout_d[5],pydecdatout_d[6],pydecdatout_d[7],pydecdatout_d[8]};
end

//assign dec_LLID = py_header[1:0];
//assign dec_FLOW = py_header[2];
//assign dec_pylenByte = BRss ? {5'b0,py_header[7:3]} : py_header[12:3];
wire [12:0] dec_pylenbit = dec_pylenByte > 10'd1021 ? {10'd1021,3'b0} : {dec_pylenByte,3'b0};

//
// pyload data word
reg [4:0] pydin_bitcnt;
reg [31:0] rxpydin;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxpydin <= 0;
  else if (daten & dec_py_period & py_datvalid_p)
     rxpydin <= {pydecdatout,rxpydin[31:1]};
end

reg dec_py_period_ext;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_pybitcnt <= 0;
  else if (dec_py_st_p)
     dec_pybitcnt <= 0;
  else if ((daten & dec_py_period & py_datvalid_p) | dec_py_period_ext)
     dec_pybitcnt <= dec_pybitcnt + 1'b1 ;
end

//extend to make 32 bit
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_py_period_ext <= 0;
  else if (dec_py_endp & dec_pybitcnt[4:0]!=5'd31)
     dec_py_period_ext <= 1'b1;
  else if (dec_pybitcnt[4:0]==5'd31 & py_datvalid_p)
     dec_py_period_ext <= 1'b0 ;
end
wire rxpydin_valid_p = (dec_pybitcnt[4:0]==5'd31) & py_datvalid_p;

reg rxpydin_valid_p_d1;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxpydin_valid_p_d1 <= 0;
  else if (rxpydin_valid_p)
     rxpydin_valid_p_d1 <= 1'b1;
  else if (py_datvalid_p)
     rxpydin_valid_p_d1 <= 1'b0 ;
end

assign rxpydin_valid_p_wr = rxpydin_valid_p_d1 & py_datvalid_p;

reg [7:0] rxpyadr;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxpyadr <= 0;
  else if (dec_py_st_p)
     rxpyadr <= 0;
  else if (rxpydin_valid_p_wr)
     rxpyadr <= rxpyadr + 1'b1 ;
end

//
wire rxfhs = psrxfhs | inquiryrxfhs;
//
decFHS decFHS_u(
.clk_6M       (clk_6M       ), 
.rstz         (rstz         ),
.dec_py_st_p  (dec_py_st_p  ), 
.daten        (daten        ), 
.dec_py_period(dec_py_period), 
.py_datvalid_p(py_datvalid_p), 
.pydecdatout  (pydecdatout  ),
.rxfhs        (rxfhs        ),
//
.Pbits        (fhs_Pbits        ),
.LAP          (fhs_LAP          ),
.EIR          (fhs_EIR          ),
.SR           (fhs_SR           ),
.SP           (fhs_SP           ),
.UAP          (fhs_UAP          ),
.NAP          (fhs_NAP          ),
.CoD          (fhs_CoD          ),
.LT_ADDR      (fhs_LT_ADDR      ),
.CLK          (fhs_CLK          ),
.PSM          (fhs_PSM          )
);

endmodule
