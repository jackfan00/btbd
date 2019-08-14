//
// payload bit processing
//

module pypro(
clk_6M, rstz, p_1us,
dec_py_endp_d1,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
mpr, ir, spr,
daten, py_daten, py_datvalid_p, py_datperiod, py_crc16period, py_period,
dec_py_endp, dec_py_period,
py_st_p, dec_py_st_p,
txpybitin, 
pk_encode,
fec32bk_endp,
whitening,
fec32encode,
rxbit,
//
fec32encodeout, fec32decodeBus,
decode_latch_p,
dec_crcgood,
pydecdatout

);

input clk_6M, rstz, p_1us;
input [1:0] dec_py_endp_d1;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input mpr, ir, spr;
input daten, py_daten, py_datvalid_p, py_datperiod, py_crc16period, py_period;
input dec_py_endp, dec_py_period;
input py_st_p, dec_py_st_p;
input txpybitin;
input pk_encode;
input fec32bk_endp;
input [6:0] whitening;
input fec32encode;
input rxbit;
//
output fec32encodeout;
output [9:0] fec32decodeBus;
output decode_latch_p;
output dec_crcgood;
output pydecdatout;

wire crc16out;
wire whiteout,fec32decodebit;
wire [15:0] crc16rem;
//
//
wire [7:0] crc16ini = mpr ? regi_paged_BD_ADDR_UAP[7:0] :
                    spr ? regi_my_BD_ADDR_UAP[7:0] :
              ir ? 8'b0 : regi_master_BD_ADDR_UAP;

wire loadcrcini_p = pk_encode ? py_st_p : dec_py_st_p;
wire shiftcrc_in = pk_encode ? py_datperiod & daten : dec_py_period & daten;
wire shiftcrc_out = pk_encode ? py_crc16period & daten : 1'b0;
wire crcdatvalid_p =  py_datvalid_p;
wire crc16_datin = pk_encode ? txpybitin : whiteout;

crc16 crc16_u(
.clk_6M     (clk_6M        ), 
.rstz       (rstz          ),
.crc16_datin(crc16_datin   ), 
.datvalid_p (crcdatvalid_p ),
.loadini_p  (loadcrcini_p  ), 
.shift_in   (shiftcrc_in   ), 
.shift_out  (shiftcrc_out  ),
.crc16ini   (crc16ini      ),
//         (//             )
.crc16rem   (crc16rem      )

);
reg dec_crcgood;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_crcgood <= 0;
  else if (dec_py_endp_d1[0] & (!pk_encode))
     dec_crcgood <= (crc16rem==16'b0);
end
              
////////////////reg [15:0] crc16;
////////////////always @(posedge clk_6M or negedge rstz)
////////////////begin
////////////////  if (!rstz)
////////////////     crc16 <= 0;
////////////////  else if (py_st_p)
////////////////     crc16 <= {8'b0,crc16ini[7:0]};
////////////////  else if (py_datperiod & pk_encode)          //shift in
////////////////    begin   
////////////////      if (py_daten & py_datvalid_p)
////////////////        crc16 <= {crc16[14:12], crc16out^crc16[11], crc16[10:5], crc16out^crc16[4], crc16[3:0], crc16out};
////////////////    end                
////////////////  else if (dec_py_period & (!pk_encode))          //shift in
////////////////    begin   
////////////////      if (py_daten & py_datvalid_p)
////////////////        crc16 <= {crc16[14:12], crc16out^crc16[11], crc16[10:5], crc16out^crc16[4], crc16[3:0], crc16out};
////////////////    end                
////////////////  else if (py_crc16period & pk_encode)   //shift out
////////////////    begin
////////////////      if (daten & py_datvalid_p)
////////////////         crc16 <= {crc16[14:0], 1'b0};
////////////////    end                
////////////////end
////////////////
////////////////assign crc16out = pk_encode ? crc16_datin ^ crc16[15] : whiteout ^ crc16[15];


//
assign whiteout =  pk_encode ? (py_datperiod ? whitening[6] ^ crc16_datin : whitening[6] ^ crc16rem[15]) :
                   dec_py_period  ? fec32decodebit ^ whitening[6] : 1'b0 ;
//
assign pydecdatout = whiteout;
//
wire [4:0] fec32rem, syndrome;  
// fec32 
wire loadfec32ini_p = py_st_p | fec32bk_endp;
wire shiftfec32_in  = pk_encode ? py_period & daten : py_period|dec_py_period;
wire shiftfec32_out = pk_encode ? py_period & (!daten) : 1'b0;
wire fec32datvalid_p = py_datvalid_p;
wire fec32_datin = pk_encode ? whiteout : rxbit;
fec32 fec32_u(
.clk_6M     (clk_6M          ), 
.rstz       (rstz            ),
.loadini_p  (loadfec32ini_p  ), 
.shift_in   (shiftfec32_in   ), 
.shift_out  (shiftfec32_out  ), 
.datvalid_p (fec32datvalid_p ),
.fec32_datin(fec32_datin     ),
//                           
.fec32rem   (fec32rem        ),
.syndrome   (syndrome        )

);
/////////////wire fec32out_fb;
/////////////reg [4:0] fec32;
/////////////always @(posedge clk_6M or negedge rstz)
/////////////begin
/////////////  if (!rstz)
/////////////     fec32 <= 0;
/////////////  else if (py_st_p | fec32bk_endp)
/////////////     fec32 <= 0;
/////////////  else if (fec32_s1 & py_datvalid_p)
/////////////    begin
/////////////     fec32 <= {fec32out_fb^fec32[3], fec32[2], fec32out_fb^fec32[1], fec32[0], fec32out_fb};
/////////////    end                
/////////////  else if (fec32_s2 & py_datvalid_p)
/////////////    begin
/////////////     fec32 <= {fec32[3:0], 1'b0};
/////////////    end                
/////////////end
/////////////
/////////////assign fec32out_fb = fec32[4] ^ whiteout;

assign fec32encodeout = shiftfec32_out ? fec32rem[4] : 
                  shiftfec32_in ? whiteout : 1'b0;

//

//
////////////reg [4:0] syndrome;         
////////////always @(posedge clk_6M or negedge rstz)
////////////begin
////////////  if (!rstz)
////////////     syndrome <= 0;
////////////  else if (py_st_p)
////////////     syndrome <= 0;
////////////  else if (shift_in & fec32bk_endp & (!pk_encode))
////////////     syndrome <= {fec32out_fb^fec32[3], fec32[2], fec32out_fb^fec32[1], fec32[0], fec32out_fb};
////////////end

// fec32 decode
// syndrome:
// 10101
// 11111
// 11010
// 01101
// 10011
// 11100
// 01110
// 00111
// 10110
// 01011
// 10000
// 01000
// 00100
// 00010
// 00001

wire correct_b0 = (syndrome==5'b00001) & fec32encode;
wire correct_b1 = (syndrome==5'b00010) & fec32encode;
wire correct_b2 = (syndrome==5'b00100) & fec32encode;
wire correct_b3 = (syndrome==5'b01000) & fec32encode;
wire correct_b4 = (syndrome==5'b10000) & fec32encode;
wire correct_b5 = (syndrome==5'b01011) & fec32encode;
wire correct_b6 = (syndrome==5'b10110) & fec32encode;
wire correct_b7 = (syndrome==5'b00111) & fec32encode;
wire correct_b8 = (syndrome==5'b01110) & fec32encode;
wire correct_b9 = (syndrome==5'b11100) & fec32encode;




reg [9:0] rxfec32buf;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     rxfec32buf <= 0;
  else if ((py_period|dec_py_period) & daten & py_datvalid_p)
     rxfec32buf <= {rxfec32buf[8:0],rxbit};
end


reg [3:0] dec_bitcnt;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_bitcnt <= 4'd9;
  else if (fec32bk_endp)
     dec_bitcnt <= 4'd9;
  else if (dec_py_period & daten & py_datvalid_p & dec_bitcnt!=4'b0)
     dec_bitcnt <= dec_bitcnt-1'b1;
end

// LSB transmit first
assign fec32decodebit = fec32decodeBus[dec_bitcnt];

reg decode_latch_p;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     decode_latch_p <= 0;
  else 
     decode_latch_p <= (shiftfec32_in & fec32bk_endp & (!pk_encode));
end

// LSB transmit first
//assign fec32decodeBus = rxfec32buf[9:0] ^ {correct_b0,correct_b1,correct_b2,correct_b3,correct_b4,correct_b5,correct_b6,correct_b7,correct_b8, correct_b9};
reg [9:0] fec32decodeBus;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     fec32decodeBus <= 0;
  else if (decode_latch_p)
     fec32decodeBus <= rxfec32buf[9:0] ^ {correct_b0,correct_b1,correct_b2,correct_b3,correct_b4,correct_b5,correct_b6,correct_b7,correct_b8, correct_b9};
end

endmodule
