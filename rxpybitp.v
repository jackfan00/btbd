module rxpybitp(
clk_6M, rstz, p_1us, p_05us, p_033us,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
mpr, ir, spr,
py_st_p,
packet_BRmode, packet_DPSK,
rxpybitlen,
whitening,
BRss,
crcencode,
existpyheader,
rxbit,
//
daten, py_datvalid_p,
dec_py_period,
dec_pylenByte,
dec_pylenbit,
dec_crcgood,
dec_LLID,
dec_FLOW
);

input clk_6M, rstz, p_1us, p_05us, p_033us;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input mpr, ir, spr;
input py_st_p;
input packet_BRmode, packet_DPSK;
input [12:0] rxpybitlen;
input [6:0] whitening;
input BRss;        // Basic Rate single-slot
input crcencode;
input existpyheader;
input rxbit;
//
output daten, py_datvalid_p;
output dec_py_period;
output [9:0] dec_pylenByte;
output [12:0] dec_pylenbit;
output dec_crcgood;
output [1:0] dec_LLID;
output dec_FLOW;


wire py_endp, dec_py_endp;
wire fec32bk_endp;

//
wire [12:0] payloadlen_crc = crcencode ?  rxpybitlen + 5'd16 : rxpybitlen;

reg py_period;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     py_period <= 0;
  else if (py_endp & p_1us)
     py_period <= 0;
  else if (py_st_p & p_1us & (rxpybitlen!=13'd0))
     py_period <= 1'b1 ;
end

reg dec_py_period;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_py_period <= 0;
  else if (dec_py_endp & p_1us)
     dec_py_period <= 0;
  else if (fec32bk_endp & p_1us & (rxpybitlen!=13'd0))
     dec_py_period <= 1'b1 ;
end

wire dec_py_st_p = fec32bk_endp & py_period & (!dec_py_period);
//
reg [3:0] fec32count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec32count <= 0;
  else if (py_st_p | fec32bk_endp)
     fec32count <= 0;
  else if ((py_period|dec_py_period) & p_1us & packet_BRmode)
     fec32count <= fec32count + 1'b1 ;
  else if ((py_period|dec_py_period) & p_05us & packet_DPSK & (!packet_BRmode) )
     fec32count <= fec32count + 1'b1 ;
  else if ((py_period|dec_py_period) & p_033us & (!packet_DPSK) & (!packet_BRmode) )
     fec32count <= fec32count + 1'b1 ;
end

assign fec32bk_endp = fec32count==4'd14 & p_1us;
assign daten = (fec32count <= 4'd9) & (py_period|dec_py_period);
assign fec32en = (fec32count > 4'd9 && fec32count<=4'd15) & (py_period|dec_py_period);

reg [12:0] processlen;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     processlen <= 0;
  else if (py_st_p & p_1us)
     processlen <= 11'd10;
  else if (fec32bk_endp)
     processlen <= processlen + 4'd10 ;
end

assign py_endp = (processlen >= payloadlen_crc) & fec32bk_endp;

assign dec_py_endp = (processlen >= (payloadlen_crc+4'd10)) & fec32bk_endp;

reg [11:0] bitcount;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     bitcount <= 0;
  else if (py_st_p & p_1us)
     bitcount <= 11'd0;
  else if (daten & py_period & p_1us & packet_BRmode)
     bitcount <= bitcount + 1'b1 ;
  else if (daten & py_period & p_05us & packet_DPSK & (!packet_BRmode))
     bitcount <= bitcount + 1'b1 ;
  else if (daten & py_period & p_033us & (!packet_DPSK) & (!packet_BRmode))
     bitcount <= bitcount + 1'b1 ;
end

wire py_crc16period = py_period & (bitcount >= rxpybitlen);
wire py_datperiod = py_period & (bitcount < rxpybitlen);
wire py_daten = py_datperiod & daten;
wire py_datvalid_p = packet_BRmode ? p_1us :
                  packet_DPSK ? p_05us : p_033us;
                 
//
wire [9:0] fec32decodeBus;
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
.dec_py_endp            (dec_py_endp            ),
.py_st_p                (py_st_p                ),
.dec_py_st_p            (dec_py_st_p            ),
.txpybitout             (1'b0                   ),
.pk_encode              (1'b0                   ),
.fec32bk_endp           (fec32bk_endp           ),
.whitening              (whitening              ),
.rxbit                  (rxbit                  ),
//                     (//                     )
.fec32decodeBus         (fec32decodeBus         ),
.decode_latch_p         (decode_latch_p         ),
.dec_crcgood            (dec_crcgood            ),
.pydecdatout            (pydecdatout            )
);

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
reg dec_FLOW;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_FLOW <= 0;
  else if (bitcount==12'hc & py_datvalid_p & existpyheader)
     dec_FLOW <= pydecdatout;
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
assign dec_pylenbit = dec_pylenByte > 10'd1021 ? {10'd1021,3'b0} : {dec_pylenByte,3'b0};
endmodule