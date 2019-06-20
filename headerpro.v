//
// header bit processing
//

module headerpro(
clk_6M, rstz, p_1us,
pk_encode,
regi_whitening,
regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP,
mpr, ir, spr,
header_st_p, header_en, hec_en, py_st_p,
fec31inc_p,
py_period, daten, py_datvalid_p, dec_py_period,
pkheader_bitin, dec_headerbit,
Xprm, Xir, Xprs,
CLK,
//
encodeout, decodeout,
whitening,
hecrem

);

input clk_6M, rstz, p_1us;
input pk_encode;
input regi_whitening;
input [7:0] regi_paged_BD_ADDR_UAP, regi_master_BD_ADDR_UAP, regi_my_BD_ADDR_UAP;
input mpr, ir, spr;
input header_st_p, header_en, hec_en, py_st_p;
input fec31inc_p;
input py_period, daten, py_datvalid_p, dec_py_period;
input pkheader_bitin, dec_headerbit;
input [4:0] Xprm, Xir, Xprs;
input [27:0] CLK;
//
output encodeout, decodeout;
output [6:0] whitening;
output [7:0] hecrem;

wire hecout;
wire [6:0] whitening;
wire fec31decode;
//
//
wire [7:0] hecremini = mpr ? regi_paged_BD_ADDR_UAP[7:0] :
                   spr ? regi_my_BD_ADDR_UAP[7:0] :
              ir ? 8'b0 : regi_master_BD_ADDR_UAP;

wire loadhecini_p = header_st_p;
wire hecshift_in = pk_encode ? header_en : (header_en|hec_en);
wire hecshift_out = pk_encode ? hec_en : 1'b0;
wire hecdatvalid_p = fec31inc_p;

//

wire hec_datin = pk_encode ? pkheader_bitin : whitening[6] ^ fec31decode;

hec hec_u(
.clk_6M    (clk_6M    ), 
.rstz      (rstz      ),
.loadini_p (loadhecini_p ),
.hecremini (hecremini ),
.shift_in  (hecshift_in  ), 
.shift_out (hecshift_out ), 
.datvalid_p(hecdatvalid_p), 
.hec_datin (hec_datin ),   
//
.hecrem    (hecrem    )
);

reg py_st_p_d1;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     py_st_p_d1 <= 0;
  else 
     py_st_p_d1 <= py_st_p;
end

reg dec_hecgood;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_hecgood <= 0;
  else if (py_st_p_d1 & (!pk_encode))
     dec_hecgood <= (hecrem==8'b0);
end

              
////////////////reg [7:0] hec;
////////////////always @(posedge clk_6M or negedge rstz)
////////////////begin
////////////////  if (!rstz)
////////////////     hec <= 0;
////////////////  else if (header_st_p)
////////////////     hec <= hecini[7:0];
////////////////  else if (header_en & fec31inc_p)
////////////////    begin
////////////////     hec <= {hecout^hec[6], hec[5], hecout^hec[4], hec[3], hec[2], hecout^hec[1], hecout^hec[0], hecout};
////////////////    end                
////////////////  else if (hec_en & fec31inc_p)
////////////////    begin
////////////////     hec <= {hec[6:0], 1'b0};
////////////////    end                
////////////////end
////////////////
////////////////assign hecout = pk_encode ? hec_datin ^ hec[7] : (whitening[6] ^ hec_datin) ^ hec[7];
//
//
wire [6:0] whitening_ini = mpr ? {2'b11,Xprm[4:0]} :
                 spr ? {2'b11,Xprs[4:0]} :
                ir ? {2'b11,Xir[4:0]} : {1'b1,CLK[6:1]};

wire whiteningEnable = regi_whitening;
wire loadwhiteini_p = header_st_p;
wire datvalid_p = pk_encode ? ((header_en | hec_en) & fec31inc_p) | (py_period & daten & py_datvalid_p) :
                              ((header_en | hec_en) & fec31inc_p) | (dec_py_period & daten & py_datvalid_p)  ;

whiten whiten_u(
.clk_6M         (clk_6M         ), 
.rstz           (rstz           ),
.whiteningEnable(whiteningEnable),
.loadini_p      (loadwhiteini_p      ), 
.datvalid_p     (datvalid_p     ),
.whitening_ini  (whitening_ini  ),
.whitening      (whitening      )
);

/////////////////reg [6:0] whitening;
/////////////////always @(posedge clk_6M or negedge rstz)
/////////////////begin
/////////////////  if (!rstz)
/////////////////     whitening <= 0;
/////////////////  else if (!regi_whitening)
/////////////////     whitening <= 0;
/////////////////  else if (header_st_p)
/////////////////     whitening <= mpr ? {2'b11,Xprm[4:0]} :
/////////////////                 spr ? {2'b11,Xprs[4:0]} :
/////////////////                ir ? {2'b11,Xir[4:0]} : {1'b1,CLK[6:1]};
///////////////////header
/////////////////  else if ((header_en | hec_en) & fec31inc_p)
/////////////////    begin
/////////////////     whitening <= {whitening[5:4],whitening[3]^whitening[6],whitening[2:0],whitening[6]};
/////////////////    end                
/////////////////
///////////////////payload
/////////////////  else if (py_period & daten & py_datvalid_p)
/////////////////    begin
/////////////////     whitening <= {whitening[5:4],whitening[3]^whitening[6],whitening[2:0],whitening[6]};
/////////////////    end                
/////////////////end

//
reg [1:0] dec_headerbit_d;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     dec_headerbit_d <= 0;
  else if (p_1us)
     dec_headerbit_d <= {dec_headerbit_d[0], dec_headerbit};
end

wire [1:0] fec31dat = (dec_headerbit_d[1]+dec_headerbit_d[0]+dec_headerbit);

assign fec31decode = fec31dat<=2'd1 ? 1'b0 : 1'b1;

//
assign encodeout =
                   header_en ? whitening[6] ^ pkheader_bitin :
                   hec_en    ? whitening[6] ^ hecrem[7]    : 1'b0;
               
//

assign decodeout = header_en & (!pk_encode) ? whitening[6] ^ fec31decode : 1'b0;

endmodule