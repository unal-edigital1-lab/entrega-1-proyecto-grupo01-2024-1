//`include "BotonAntirebote.v"
module Boton #(parameter MIN_TIME = 25000000, TIME_ANTIREBOTE = 5000)(
    input wire clk, // Clock input in ms
    input wire reset,
    input wire boton_in, // Button input
    output wire boton_out // Debounced button output
);

    wire btn_procesado; // Processed button output
    // Instantiate the boton module
    BotonAntirebote #(.MIN_TIME(TIME_ANTIREBOTE)) instBotonAntirebote(
        .clk(clk),
        .btn_in(btn_in),
        .btn_out(btn_procesado)
    );
    
    // Instantiate the boton module
    BotonAntirebote #(.MIN_TIME(MIN_TIME)) instBoton(
        .clk(clk),
        .btn_in(btn_procesado),
        .btn_out(btn_out)
    );
endmodule