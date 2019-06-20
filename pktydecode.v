module pktydecode(
is_BRmode, is_eSCO, is_SCO, is_ACL,
pk_type,
regi_payloadlen,
//
pylenbit,
occpuy_slots,
fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK,
BRss,
existpyheader
);

input is_BRmode, is_eSCO, is_SCO, is_ACL;
input [3:0] pk_type;
input [9:0] regi_payloadlen;

//
output [12:0] pylenbit;
output [2:0] occpuy_slots;
output fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK;
output BRss;
output existpyheader;
//
reg [12:0] pylenbit;
reg [2:0] occpuy_slots;
reg fec31encode, fec32encode, crcencode, packet_BRmode, packet_DPSK;
reg existpyheader;

always @*
begin
  existpyheader = 1'b1;
  fec31encode = 1'b0;
  fec32encode = 1'b1;
  crcencode = 1'b1;
  packet_BRmode = 1'b1;
  packet_DPSK = 1'b1;
  occpuy_slots = 3'd1;
  pylenbit = is_ACL ? {regi_payloadlen+1'b1, 3'b0} : {regi_payloadlen, 3'b0};
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