module bufctrl();

input [12:0] txlnctrl_bitcount;

wire [31:0] lncacl_dout, lncsco_dout;

wire lncacl_cs=1'b1; //for tmp
wire lncsco_cs=1'b0; //for tmp

wire [7:0] txlnctrl_addr = lnctrl_bitcount[12:5];

wire [31:0] lnctrl_bufpacket = lncacl_cs ? lncacl_dout : 
                               lncsco_cs ? lncsco_dout : 32'b0;

assign lnctrl_bufbitin = lnctrl_bufpacket[txlnctrl_bitcount[4:0]];

pytxaclbufctrl pytxaclbufctrl_u(
.clk_6M     (clk_6M     ), 
.rstz       (rstz       ),
.bsm_addr   (bsm_addr   ), 
.lnctrl_addr(txlnctrl_addr),
.bsm_din    (bsm_din    ),
.bsm_we     (bsm_we     ),
.bsm_cs     (bsm_cs     ), 
.lnctrl_cs  (lncacl_cs  ),
.txSEQN     (txSEQN     ),
//
.lnctrl_dout(lncacl_dout)
);

pytxscobufctrl pytxscobufctrl_u(
.clk_6M     (clk_6M     ), 
.rstz       (rstz       ),
.tsco_p     (tsco_p     ), 
.bsm_addr   (bsm_addr   ), 
.lnctrl_addr(txlnctrl_addr),
.bsm_din    (bsm_din    ),
.bsm_we     (bsm_we     ),
.bsm_cs     (bsm_cs     ), 
.lnctrl_cs  (lncsco_cs  ),
//
.lnctrl_dout(lncsco_dout)
);


pyrxaclbufctrl pyrxaclbufctrl_u(
.clk_6M        (clk_6M        ), 
.rstz          (rstz          ),
.bsm_read_endp (bsm_read_endp ), 
.bsm_addr      (bsm_addr      ), 
.lnctrl_addr   (lnctrl_addr   ),
.lnctrl_din    (lnctrl_din    ),
.lnctrl_we     (lnctrl_we     ),
.bsm_cs        (bsm_cs        ), 
.lnctrl_cs     (lnctrl_cs     ),
//
.bsm_dout      (bsmacl_dout   )

);

pyrxscobufctrl pyrxscobufctrl_u(
.clk_6M        (clk_6M        ), 
.rstz          (rstz          ),
.tsco_p        (tsco_p        ), 
.bsm_addr      (bsm_addr      ), 
.lnctrl_addr   (lnctrl_addr   ),
.lnctrl_din    (lnctrl_din    ),
.lnctrl_we     (lnctrl_we     ),
.bsm_cs        (bsm_cs        ), 
.lnctrl_cs     (lnctrl_cs     ),
//
.bsm_dout      (bsmsco_dout   )

endmodule
