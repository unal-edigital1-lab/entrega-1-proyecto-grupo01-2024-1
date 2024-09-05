module Reset_AntiR(

    input btnRst_in,
    input clk_,
    output wire btnRst_out
	 
);

wire boton_ar;

Boton InstBTN(
    .clk(clk_),
    .btn_in(btnRst_in),
    .btn_out(boton_ar)// Debounced button output
);



bttnReset InstRst(
    // Declaración de entradas y salidas
    .btnRst_in(boton_ar),
    .clk(clk_),
    .btnRst_out(btnRst_out)
);


endmodule