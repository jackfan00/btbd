//
// 2019/04/24
// hopping kernal : core5.1 Spec 2.6.2
//

module hopkernal(
divffclk, div_en_p, rstz,
X, A, C,
B,
D,
E, F, Fprime,
Y1,
Y2,
regi_AFH_channel_map,
regi_AFH_modN,
fk

);

input divffclk, div_en_p, rstz;
input [4:0] X, C;
input [4:0] A;
input [3:0] B;
input [8:0] D;
input [6:0] E, F, Fprime;
input Y1;
input [5:0] Y2;
input [79:0] regi_AFH_channel_map;
input [6:0] regi_AFH_modN;
output [6:0] fk;

// first addition mod 32

wire [4:0] Zprime = X + A;

//XOR operation
wire [4:0] Z;
assign Z[0] = B[0] ^ Zprime[0];
assign Z[1] = B[1] ^ Zprime[1];
assign Z[2] = B[2] ^ Zprime[2];
assign Z[3] = B[3] ^ Zprime[3];
assign Z[4] =  Zprime[4];


//Permutation operation
wire [4:0] stage1_z, stage2_z, stage3_z, stage4_z, stage5_z, stage6_z, stage7_z;

wire [13:0] P = {C[4:0] ^ {5{Y1}}, D[8:0]};

assign stage1_z[1] = P[13] ? Z[2] : Z[1];
assign stage1_z[2] = P[13] ? Z[1] : Z[2];
assign stage1_z[0] = P[12] ? Z[3] : Z[0];
assign stage1_z[3] = P[12] ? Z[0] : Z[3];
assign stage1_z[4] = Z[4];

assign stage2_z[1] = P[11] ? stage1_z[3] : stage1_z[1];
assign stage2_z[3] = P[11] ? stage1_z[1] : stage1_z[3];
assign stage2_z[2] = P[10] ? stage1_z[4] : stage1_z[2];
assign stage2_z[4] = P[10] ? stage1_z[2] : stage1_z[4];
assign stage2_z[0] = stage1_z[0];

assign stage3_z[0] = P[9] ? stage2_z[3] : stage2_z[0];
assign stage3_z[3] = P[9] ? stage2_z[0] : stage2_z[3];
assign stage3_z[1] = P[8] ? stage2_z[4] : stage2_z[1];
assign stage3_z[4] = P[8] ? stage2_z[1] : stage2_z[4];
assign stage3_z[2] = stage2_z[2];

assign stage4_z[3] = P[7] ? stage3_z[4] : stage3_z[3];
assign stage4_z[4] = P[7] ? stage3_z[3] : stage3_z[4];
assign stage4_z[0] = P[6] ? stage3_z[2] : stage3_z[0];
assign stage4_z[2] = P[6] ? stage3_z[0] : stage3_z[2];
assign stage4_z[1] = stage3_z[1];

assign stage5_z[1] = P[5] ? stage4_z[3] : stage4_z[1];
assign stage5_z[3] = P[5] ? stage4_z[1] : stage4_z[3];
assign stage5_z[0] = P[4] ? stage4_z[4] : stage4_z[0];
assign stage5_z[4] = P[4] ? stage4_z[0] : stage4_z[4];
assign stage5_z[2] = stage4_z[2];

assign stage6_z[3] = P[3] ? stage5_z[4] : stage5_z[3];
assign stage6_z[4] = P[3] ? stage5_z[3] : stage5_z[4];
assign stage6_z[1] = P[2] ? stage5_z[2] : stage5_z[1];
assign stage6_z[2] = P[2] ? stage5_z[1] : stage5_z[2];
assign stage6_z[0] = stage5_z[0];

assign stage7_z[2] = P[1] ? stage6_z[3] : stage6_z[2];
assign stage7_z[3] = P[1] ? stage6_z[2] : stage6_z[3];
assign stage7_z[0] = P[0] ? stage6_z[1] : stage6_z[0];
assign stage7_z[1] = P[0] ? stage6_z[0] : stage6_z[1];
assign stage7_z[4] = stage6_z[4];

// second addition mod 79
// F < 79

wire [6:0] em79 = E[6:0] > 7'd78 ? E[6:0]-7'd79 : E[6:0];
//wire [6:0] fm79 = F[6:0] > 7'd78 ? F[6:0]-7'd79 : F[6:0];
wire [7:0] tmp1 = em79 + F[6:0]; //fm79;
wire [7:0] tmp1m79 = tmp1[7:0] > 8'd78 ? tmp1[7:0]-8'd79 : tmp1[7:0];  //should less than 7'd79
wire [7:0] tmp2 = tmp1m79[6:0] + stage7_z[4:0] + Y2;                   //should less than 79*2
wire [6:0] adder2m79 = tmp2 > 7'd78 ? tmp2-7'd79 : tmp2[6:0];

// basic hop mapping

wire rfchused = regi_AFH_channel_map[adder2m79[6:0]];

//
// remap function
// addition mod regi_AFH_modN, 20<N<79
// Fprime < N

wire [6:0] emN = {2'b0,E[6:0]} >= {regi_AFH_modN,2'b0}                 ? {2'b0,E[6:0]} - {regi_AFH_modN,2'b0} :
                 {2'b0,E[6:0]} >= ({regi_AFH_modN,1'b0}+regi_AFH_modN) ? {2'b0,E[6:0]} - ({regi_AFH_modN,1'b0}+regi_AFH_modN) :
                 {1'b0,E[6:0]} >= {regi_AFH_modN,1'b0}                 ? {1'b0,E[6:0]} - {regi_AFH_modN,1'b0} :
                 E[6:0]} >= regi_AFH_modN                              ? E[6:0]-regi_AFH_modN : E[6:0];
//
wire [7:0] tmp1N = emN + Fprime[6:0]; //should less than regi_AFH_modN*2
wire [7:0] tmp1mN = tmp1N[7:0] >= regi_AFH_modN ? tmp1N[7:0]-regi_AFH_modN : tmp1N[7:0];  //should less than regi_AFH_modN
wire [4:0] a7zmN = {2'b0,stage7_z[4:0]} >= regi_AFH_modN ? {2'b0,stage7_z[4:0]} - regi_AFH_modN : stage7_z[4:0];  
wire [7:0] tmp2N = tmp1mN[6:0] + a7zmN + Y2;                                     //should less than regi_AFH_modN*2
wire [6:0] adder2mN = tmp2N >= regi_AFH_modN ? tmp2N-regi_AFH_modN : tmp2N[6:0];

wire [6:0] kprimem = adder2mN;
//wire [8:0] kprimeall = E[6:0] + Fprime[6:0] + Y2 + stage7_z[4:0];
//wire [24:0] nc;
//wire [24:0] kprimemodN;
//div modn_remap(
//.clk      (divffclk                   ),
//.rstz     (rstz                       ),
//.div_en_p (div_en_p                   ),
//.dividend ({16'b0,kprimeall[8:0]}     ),
//.divisor  (regi_AFH_modN[6:0]         ),
//.result_o ({kprimemodN[24:0],nc[24:0]})
//);
//wire [6:0] kprimem = kprimemodN[6:0]; //less than 79

wire [6:0] fkprime, basicfk;
AFH_map_table AFH_map_table_u(
.A(kprimem),
.O(fkprime)
);

assign basicfk = (adder2m79<=7'd39) ? {adder2m79[5:0], 1'b0} : {(adder2m79-7'd40), 1'b1};

//wire [6:0] fkprime = AFH_map_table[kprimem];
//wire [6:0] basicfk = basic_map_table[adder2m79];

assign fk = rfchused ? basicfk : fkprime;

endmodule
