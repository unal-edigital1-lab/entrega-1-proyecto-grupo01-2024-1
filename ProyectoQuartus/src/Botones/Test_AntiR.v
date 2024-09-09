module Test_AntiR(

	 input btnTest_in,
    input clk_,
    input rst_,
    output wire btnTest_out,
    output wire [3:0] NUMPULSE
	 
);

wire boton_ar;
Antirebote InstAntirebote(
    .clk(clk_),
    .btn_in(btnTest_in),
    .btn_out(boton_ar)// Debounced button output
);



bttnTest InstTest(
	 .botonTest(boton_ar),
    .clk(clk_),
    .rst(rst_),
    .btnTest(btnTest_out),
    .contBtnPress(NUMPULSE)
	
);


endmodule