module AFH_map_table(
A,
O
);

input [6:0] A;
output [6:0] O;

// fake
assign O = ~A;

endmodule