module pktydecode(
clk_6M, rstz,
pktype_data,
ms_tslot_p,
is_BRmode, is_eSCO, is_SCO, is_ACL,
pk_type,
regi_payloadlen,
conns_1stslot,
pk_encode_1stslot,
//
pylenbit_f,
occpuy_slots_f,
fec31encode_f, fec32encode_f, crcencode_f, packet_BRmode_f, packet_DPSK_f,
BRss_f,
existpyheader_f,
allowedeSCOtype,
extendslot
);
input clk_6M, rstz;
input pktype_data;
input ms_tslot_p;
input is_BRmode, is_eSCO, is_SCO, is_ACL;
input [3:0] pk_type;
input [9:0] regi_payloadlen;
input conns_1stslot;
input pk_encode_1stslot;
//
output [12:0] pylenbit_f;
output [2:0] occpuy_slots_f;
output fec31encode_f, fec32encode_f, crcencode_f, packet_BRmode_f, packet_DPSK_f;
output BRss_f;
output existpyheader_f;
output allowedeSCOtype;
output extendslot;
//
//
wire BRss;
reg [12:0] pylenbit;
reg [2:0] occpuy_slots;
reg fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK;
reg existpyheader;


//reg [12:0] pylenbit_f;
//reg [2:0] occpuy_slots_f;
//reg fec31encode_f, fec32encode_f, crcencode_f, packet_BRmode_f, packet_DPSK_f;
//reg BRss_f;
//reg existpyheader_f;


//always @(posedge clk_6M or negedge rstz)
//begin
//  if (!rstz)
//    begin
//      pylenbit_f <= 0 ;
//      occpuy_slots_f <= 0;
//      fec31encode_f <= 0;
//      fec32encode_f <= 0;
//      crcencode_f <= 0;
//      packet_BRmode_f <= 0;
//      packet_DPSK_f <= 0;
//      BRss_f <= 0;
//      existpyheader_f <= 0;
//    end
//  else if (pk_encode_1stslot)
//    begin
//      pylenbit_f <= pylenbit ;
//      occpuy_slots_f <= occpuy_slots;
//      fec31encode_f <= fec31encode;
//      fec32encode_f <= fec32encode;
//      crcencode_f <= crcencode;
//      packet_BRmode_f <= packet_BRmode;
//      packet_DPSK_f <= packet_DPSK;
//      BRss_f <= BRss;
//      existpyheader_f <= existpyheader;
//    end
//end


assign       pylenbit_f = pylenbit ;
assign       occpuy_slots_f = occpuy_slots;
assign       fec31encode_f = fec31encode;
assign       fec32encode_f = fec32encode;
assign       crcencode_f = crcencode;
assign       packet_BRmode_f = packet_BRmode;
assign       packet_DPSK_f = packet_DPSK;
assign       BRss_f = BRss;
assign       existpyheader_f = existpyheader;


reg extendslot;
reg [2:0] extendslotcnt;
always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     extendslotcnt <= 3'd2;
    end 
  else if (conns_1stslot)
    begin
     extendslotcnt <= 3'd2;
    end 
  else if (ms_tslot_p & extendslot)
    begin
     extendslotcnt <= extendslotcnt+1'b1;
    end 
end

always @(posedge clk_6M or negedge rstz)
begin
  if (!rstz)
    begin
     extendslot <= 0;
    end 
  else if (conns_1stslot & ms_tslot_p & (occpuy_slots>3'd1))
    begin
     extendslot <= 1'b1;
    end 
  else if (ms_tslot_p & (occpuy_slots==extendslotcnt))
    begin
     extendslot <= 1'b0;
    end 
end

assign allowedeSCOtype = pk_type==4'd0 | pk_type==4'd1 | pk_type==4'd6 | pk_type==4'd7 | pk_type==4'hc | pk_type==4'hd;

//

always @*
begin
  existpyheader = 1'b1;
  fec31encode = 1'b0;
  fec32encode = 1'b1;
  crcencode = 1'b1;
  packet_BRmode = 1'b1;
  packet_DPSK = 1'b1;
  occpuy_slots = 3'd1;
  pylenbit = pktype_data ? {regi_payloadlen+1'b1, 3'b0} : {regi_payloadlen, 3'b0};
  case(pk_type)
    4'h0:         //NULL
      begin
        pylenbit = 13'd0;
        existpyheader = 1'b0;
      end
    4'h1:         //POLL
      begin
        pylenbit = 13'd0;
        existpyheader = 1'b0;
      end
    4'h2:         //FHS
      begin
        pylenbit = 13'd144;
        existpyheader = 1'b0;
      end
    4'h3:       //DM1
      begin
      end
    4'h4:       //DH1/2-DH1
      begin
        fec32encode = 1'b0;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;
      end
    4'h5:       //HV1
      begin
        pylenbit = 13'd80;
        fec31encode = 1'b1;
        crcencode = 1'b0;
        existpyheader = 1'b0;
      end
    4'h6:       //HV2/2-EV3
      begin
        if (is_eSCO)
          begin
            packet_BRmode = 1'b0;
            fec32encode = 1'b0;
            existpyheader = 1'b0;
          end
        else
          begin  
            pylenbit = 13'd160;
            crcencode = 1'b0;
            existpyheader = 1'b0;
          end
      end
    4'h7:       //HV3/EV3/3-EV3
      begin
        if (is_eSCO & is_BRmode)  //EV3
          begin
            fec32encode = 1'b0;
            existpyheader = 1'b0;
          end
        else if (is_eSCO & (!is_BRmode))  //3-EV3
          begin
            crcencode = 1'b0;
            packet_BRmode = 1'b0;
            packet_DPSK = 1'b0;
            existpyheader = 1'b0;
          end
        else //if (is_SCO)
          begin  
            fec32encode = 1'b0;
            crcencode = 1'b0;
            pylenbit = 13'd240;
            existpyheader = 1'b0;
          end
      end
    4'h8:       //DV/3-DH1
      begin
        if (is_SCO)  //DV
          begin
            pylenbit = 13'd80 + {regi_payloadlen+1'b1,3'b0};
          end
        else //if (is_ACL)
          begin
            packet_BRmode = 1'b0;
            packet_DPSK = 1'b0;
            fec32encode = 1'b0;
          end  
      end
    4'h9:       //AUX1
      begin
        crcencode = 1'b0;
      end
    4'ha:       //DM3/2-DH3
      begin
        occpuy_slots = 3'd3;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;
      end
    4'hb:       //DH3/3-DH3
      begin
        occpuy_slots = 3'd3;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;
        packet_DPSK = is_BRmode ? 1'b1 : 1'b0;
      end
    4'hc:       //EV4/2-EV5
      begin
        existpyheader = 1'b0;
        occpuy_slots = 3'd3;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;        
      end
    4'hd:       //EV5/3-EV5
      begin
        existpyheader = 1'b0;
        occpuy_slots = 3'd3;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;
        packet_DPSK = is_BRmode ? 1'b1 : 1'b0;      
      end
    4'he:       //DM5/2-DH5
      begin
        occpuy_slots = 3'd5;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;                
      end
    4'hf:       //DH5/3-DH5
      begin
        occpuy_slots = 3'd5;
        packet_BRmode = is_BRmode ? 1'b1 : 1'b0;
        packet_DPSK = is_BRmode ? 1'b1 : 1'b0;      
      end
  endcase
end

assign BRss = packet_BRmode & (occpuy_slots==3'd1);

endmodule
