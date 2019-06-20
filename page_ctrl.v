module page_ctrl(
clk_6M, rstz,
p_corre_threshold, mpr, CLKE,
page, Master_TX_tslot_endp, Master_RX_tslot_endp, m_tslot_p,
regi_Npage,
regi_slave_SRmode,
regi_Tsco,
regi_scolink_num,
regi_Page_Timeout,
//
pageAB_2Npage_count,
pageTO_status_p,
Atrain,
pagerespTO
);

input clk_6M, rstz;
input p_corre_threshold, mpr;
input [27:0] CLKE;
input page, Master_TX_tslot_endp, Master_RX_tslot_endp, m_tslot_p;
input [9:0] regi_Npage;
input [1:0] regi_slave_SRmode;
input [2:0] regi_Tsco;
input [1:0] regi_scolink_num;
input [15:0] regi_Page_Timeout;
//
output [3:0] pageAB_2Npage_count;
output pageTO_status_p;
output Atrain;
output pagerespTO;

//
reg [9:0] Npage;
always @*
begin
  if (regi_Tsco==3'd6)
    begin
      case(regi_scolink_num)
        2'd0:
          begin        
              Npage = (regi_slave_SRmode==2'd0) ? (regi_Npage>=10'd0 ? regi_Npage : 10'd0) :
                      (regi_slave_SRmode==2'd1) ? (regi_Npage>=10'd127 ? regi_Npage : 10'd127) :
                                             (regi_Npage>=10'd255 ? regi_Npage : 10'd255) ;
          end
        2'd1:
          begin        
              Npage = (regi_slave_SRmode==2'd0) ? (regi_Npage>=10'd1 ? regi_Npage : 10'd1) :
                      (regi_slave_SRmode==2'd1) ? (regi_Npage>=10'd255 ? regi_Npage : 10'd255) :
                                             (regi_Npage>=10'd511 ? regi_Npage : 10'd511) ;
          end
        default:
          begin        
              Npage = (regi_slave_SRmode==2'd0) ? (regi_Npage>=10'd2 ? regi_Npage : 10'd2) :
                      (regi_slave_SRmode==2'd1) ? (regi_Npage>=10'd383 ? regi_Npage : 10'd383) :
                                             (regi_Npage>=10'd767 ? regi_Npage : 10'd767) ;
          end
      endcase
    end
  else
    Npage = regi_Npage;
end

//
reg [2:0] p_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     p_count <= 0;
  else if (!page)
     p_count <= 0;
  else if (Master_RX_tslot_endp)
     p_count <= p_count + 1'b1 ;
end

reg [9:0] train_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     train_count <= 0;
  else if ((train_count==Npage & p_count==3'd7 & Master_RX_tslot_endp) | !page)
     train_count <= 0;
  else if (p_count==3'd7 & Master_RX_tslot_endp)
     train_count <= train_count + 1'b1 ;
end

reg AB_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     AB_count <= 0;
  else if (!page)
     AB_count <= 0;
  else if (train_count==Npage & p_count==3'd7 & Master_RX_tslot_endp)
     AB_count <= AB_count + 1'b1 ;
end

assign Atrain = !AB_count;

reg [3:0] pageAB_2Npage_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pageAB_2Npage_count <= 0;
  else if (!page)
     pageAB_2Npage_count <= 0;
  else if (AB_count==1'b1 & train_count==Npage & p_count==3'd7 & Master_RX_tslot_endp)
     pageAB_2Npage_count <= pageAB_2Npage_count + 1'b1 ;
end

//
reg pageTO_status_p;
reg [15:0] pagetimeout_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pagetimeout_count <= 0;
  else if (pageTO_status_p | !page)
     pagetimeout_count <= 0;
  else if (m_tslot_p)
     pagetimeout_count <= pagetimeout_count + 1'b1 ;
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pageTO_status_p <= 0;
  else if (pageTO_status_p & m_tslot_p)
     pageTO_status_p <= 0;
  else if (m_tslot_p)
     pageTO_status_p <= (pagetimeout_count > regi_Page_Timeout) ;
end

//

reg [2:0] pagerespTO_count;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pagerespTO_count <= 0;
  else if ((page & p_corre_threshold & CLKE[1] & m_tslot_p) | (!mpr))
     pagerespTO_count <= 0;
  else if (m_tslot_p & mpr)
     pagerespTO_count <= pagerespTO_count + 1'b1;
end

assign pagerespTO = (pagerespTO_count==3'h7) & m_tslot_p;



endmodule