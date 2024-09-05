module Test_AntiR(

	 input btnTest_in,
    input clk_,
    input rst_,
    output wire btnTest_out,
    output wire [3:0] NUMPULSE
	 
);

wire boton_ar;

Boton InstBTN(
    .clk(clk_), // Clock input in ms
    .btn_in(btnTest_in), // Button input
    .btn_out(boton_ar) // Debounced button output
);



bttnTest InstTest(
	
	.btnTest_in(boton_ar),
    .clk(clk_),
    .rst(rst_),
    .btnTest(btnTest_out),
    .contBtnPress(NUMPULSE)
	
);


endmodule