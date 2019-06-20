module inquiry_ctrl(
clk_6M, rstz,
inquiry,  Master_RX_tslot_endp, m_tslot_p,
regi_Ninquiry,
regi_Inquiry_Length, regi_Extended_Inquiry_Length,
//
inquiryAB_2Ninquiry_count,
inquiryTO_status_p,
Atrain
);

input clk_6M, rstz;
input inquiry,  Master_RX_tslot_endp, m_tslot_p;
input [9:0] regi_Ninquiry;
input [15:0] regi_Inquiry_Length, regi_Extended_Inquiry_Length;
//
output [3:0] inquiryAB_2Ninquiry_count;
output inquiryTO_status_p;
output Atrain;

//
wire [9:0] Ninquiry = regi_Ninquiry >= 10'd256 ? regi_Ninquiry : 10'd256;


//
reg [2:0] p_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     p_count <= 0;
  else if (!inquiry)
     p_count <= 0;
  else if (Master_RX_tslot_endp)
     p_count <= p_count + 1'b1 ;
end

reg [9:0] train_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     train_count <= 0;
  else if ((train_count==Ninquiry & p_count==3'd7 & Master_RX_tslot_endp) | !inquiry)
     train_count <= 0;
  else if (p_count==3'd7 & Master_RX_tslot_endp)
     train_count <= train_count + 1'b1 ;
end

reg AB_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     AB_count <= 0;
  else if (!inquiry)
     AB_count <= 0;
  else if (train_count==Ninquiry & p_count==3'd7 & Master_RX_tslot_endp)
     AB_count <= AB_count + 1'b1 ;
end

assign Atrain = !AB_count;

reg [3:0] inquiryAB_2Ninquiry_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     inquiryAB_2Ninquiry_count <= 0;
  else if (!inquiry)
     inquiryAB_2Ninquiry_count <= 0;
  else if (AB_count==1'b1 & train_count==Ninquiry & p_count==3'd7 & Master_RX_tslot_endp)
     inquiryAB_2Ninquiry_count <= inquiryAB_2Ninquiry_count + 1'b1 ;
end

//
reg inquiryTO_status_p;
reg [15:0] inquirytimeout_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     inquirytimeout_count <= 0;
  else if (inquiryTO_status_p | !inquiry)
     inquirytimeout_count <= 0;
  else if (m_tslot_p)
     inquirytimeout_count <= inquirytimeout_count + 1'b1 ;
end

wire [15:0] inquiry_len = regi_Inquiry_Length + regi_Extended_Inquiry_Length;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     inquiryTO_status_p <= 0;
  else if (inquiryTO_status_p & m_tslot_p)
     inquiryTO_status_p <= 0;
  else if (m_tslot_p)
     inquiryTO_status_p <= (inquirytimeout_count > inquiry_len) ;
end

//




endmodule