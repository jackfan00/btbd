//
// 2019/05/18
// Link Controller : core5.1 Spec Chapter 8.4.1 Inquiry Scan substate
//

module is_ctrl(
clk_6M, rstz, tslot_p, p_1us,
regi_Tsco,
regi_scolink_num,
regi_Tisinterval, regi_Tiswindow,
regi_isinterlace,
regi_InquiryScanEnable,
is, giis,
//
InquiryScanWindow
);

input clk_6M, rstz, tslot_p, p_1us;
input [2:0] regi_Tsco;
input [1:0] regi_scolink_num;
input [15:0] regi_Tisinterval, regi_Tiswindow;
input regi_isinterlace;
input regi_InquiryScanEnable;
input is, giis;
//
output InquiryScanWindow;


wire [15:0] Tisinterval = regi_Tisinterval > 16'h1000 ? 16'h1000 : regi_Tisinterval;  // The inquiry scan interval shall be less than or equal to 2.56 s

reg [15:0] Tiswindow;
always @*
begin
  if (regi_Tsco==3'd6)
    begin
      case(regi_scolink_num)
        2'd0:
          begin
            Tiswindow = regi_Tiswindow;
          end
        2'd1:
          begin
            Tiswindow = regi_Tiswindow > 16'd36 ? regi_Tiswindow : 16'd36 ;
          end
        default: //2'd2:
          begin
            Tiswindow = regi_Tiswindow > 16'd54 ? regi_Tiswindow : 16'd54 ;
          end
      endcase
    end
  else
    Tiswindow = regi_Tiswindow;
end  

reg [15:0] pswindow_counter_tslot;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
     pswindow_counter_tslot <= 0;
  else if (!regi_InquiryScanEnable)
     pswindow_counter_tslot <= 0;
  else if (pswindow_counter_tslot==Tisinterval)
     pswindow_counter_tslot <= 0;
  else if (tslot_p)
     pswindow_counter_tslot <= pswindow_counter_tslot + 1'b1;
end

wire NorInquiryScanWindow = (pswindow_counter_tslot < Tiswindow);

wire InterInquiryScanWindow = (pswindow_counter_tslot < {Tiswindow,1'b0}) ;

assign InquiryScanWindow_raw =  regi_isinterlace & (Tisinterval >= {Tiswindow,1'b0}) ? InterInquiryScanWindow : NorInquiryScanWindow;

assign InquiryScanWindow = InquiryScanWindow_raw & regi_InquiryScanEnable;  //(is | giis) ;
//



endmodule