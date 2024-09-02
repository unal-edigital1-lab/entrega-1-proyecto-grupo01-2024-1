module Reset_AntiR(

    input btnRst_in,
    input clk_,
    output wire btnRst_out
	 
);

wire boton_ar;

Boton InstBTN(
    .clk(clk_), // Clock input in ms
    .btn_in(btnRst_in), // Button input
    .btn_out(boton_ar) // Debounced button output
);



bttnReset(
    // Declaración de entradas y salidas
    .btnRst_in(boton_ar),
    .clk(clk_),
    .btnRst_out(btnRst_out)
);


endmodule