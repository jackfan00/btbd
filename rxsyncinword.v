module rxsyncinword(
clk_6M, rstz, p_1us,
rxbit,
correWindow,
regi_correthreshold,
ref_sync,
//
syncinword
);

input clk_6M, rstz, p_1us;
input rxbit;
input correWindow;
input [5:0] regi_correthreshold;
input [63:0] ref_sync;
output [63:0] syncinword;


reg [63:0] syncinword;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     syncinword <= 64'h0;
  else if (p_1us)
     //syncinword <= {syncinword[62:0],rxbit} ;
     syncinword <= {rxbit,syncinword[63:1]} ;  // LSB transmit first, MSB transmit last 
end


/////correlator correlator_u(
/////.clk_6M             (clk_6M             ), 
/////.rstz               (rstz               ), 
/////.p_1us              (p_1us              ),
/////.correWindow        (correWindow        ),
/////.sync_in            (syncinword         ), 
/////.ref_sync           (ref_sync           ),
/////.regi_correthreshold(regi_correthreshold),
///////                 (//                 )
/////.pscorr_trgp        (pscorr_trgp        )
/////
/////);

endmodule