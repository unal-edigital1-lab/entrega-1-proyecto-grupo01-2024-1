`include "Boton.v"
`include "DivisorReloj.v"

module Perifericos (
    input wire clk, // Clock input
    input wire reset, // Reset input
    input wire in_reset, // Button input for reset
    input wire in_jugar, // Button input for jugar
    output wire out_reset // Button debounced output for reset
    output wire out_jugar // Button debounced output for jugar
);

    wire clk_ms;

    // Instantiate the divisorReloj module
    DivisorReloj #(.DIV_FACTOR(25000)) uut_clk_ms (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_ms)
    );

    // Instantiate the boton module for reset
    Boton #(.MIN_TIME(5000)) boton_reset(
        .clk(clk_ms),
        .reset(reset),
        .btn_in(in_reset),
        .btn_out(out_reset)
    );

    // Instantiate the boton module for jugar
    Boton #(.MIN_TIME(300)) boton_jugar(
        .clk(clk_ms),
        .reset(reset),
        .btn_in(in_jugar),
        .btn_out(out_jugar)
    );
    
endmodule