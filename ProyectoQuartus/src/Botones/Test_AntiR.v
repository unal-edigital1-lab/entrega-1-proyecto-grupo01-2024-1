module Test_AntiR(

	 input botonTest,
    input clk_,
    input rst_,
    output wire BOTONTest,
    output wire [3:0] NUMPULSE
	 
);

wire boton_ar;

Boton InstBTN(
    .clk(clk_), // Clock input in ms
    .btn_in(botonTest), // Button input
    .btn_out(boton_ar) // Debounced button output
);



bttnTest InstTest(
	
	 .botonTest(boton_ar),
    .clk(clk_),
    .rst(rst_),
    .btnTest(BOTONTest),
    .contBtnPress(NUMPULSE)
	
);


endmodule