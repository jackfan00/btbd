//
// 2019/04/24
// div : 
//

module div(
clk, rstz,
div_en_p,
dividend,
divisor,
result_o
);

input clk, rstz;
input div_en_p;
input [24:0] dividend;
input [6:0] divisor;
output [49:0] result_o;

parameter IDLE=2'h0, DIVON=2'h1, DIVEnd=2'h2;
reg [1:0] cs, ns;
wire [25:0] div_temp;
reg [50:0] op_dividend;
reg [4:0] divcnt;
always @(posedge clk or negedge rstz)
begin
  if (!rstz)
    begin
      op_dividend <= 0;
      divcnt <=0;
    end  
  else if (div_en_p && (cs==IDLE))
    begin
      op_dividend <= {25'b0,dividend[24:0],1'b0};
      divcnt <=0;
    end  
  else if (cs==DIVON)
    begin
      op_dividend <= div_temp[25] ? {op_dividend[49:0],1'b0} : {div_temp[24:0],op_dividend[24:0],1'b1};
      divcnt <= divcnt + 1'b1;
    end  
end

reg [49:0] result_o;
always @(posedge clk or negedge rstz)
begin
  if (!rstz)
    result_o <= 0;
  else if (cs==DIVEnd)
    result_o <= {op_dividend[50:26],op_dividend[24:0]};  //rem, div
end

assign div_temp = {1'b0, op_dividend[49:25]} - {1'b0, divisor};

always @(posedge clk or negedge rstz)
begin
  if (!rstz)
    cs <= 0;
  else 
    cs <= ns;
end

always @*
begin
  ns = cs;
  case(cs)
    IDLE:
      begin
        if (div_en_p) ns = DIVON;
      end
    DIVON:
      begin
        if (divcnt==5'd24) ns = DIVEnd;
      end  
    DIVEnd:
      ns = IDLE;  
  endcase
end
endmodule