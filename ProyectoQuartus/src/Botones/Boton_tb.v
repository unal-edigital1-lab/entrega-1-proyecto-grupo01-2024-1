`timescale 1ns / 1ps
`include "Boton.v"
`include "DivisorReloj.v"

module Boton_tb;
    // 1us = 1e3 ns, 1ms = 1e6 ns
    // Parameters
    localparam CLK_PERIOD = 10; // 50 MHz clock
    localparam DELAY = 1e6; //
    
    
    //1 ms delay
    localparam BTN_PRESS_TIME_10ms = 10e6; // Press button for 10 ms
    localparam BTN_PRESS_TIME_3ms = 3e6; // Press button for 3 ms
    
    // Signalsfor clock and reset
    reg clk;
    reg reset;     
    wire clk_ms;
    
    // Boton signals
    reg btn_in;
    wire btn_out;

    // Instantiate the divisorReloj module
    DivisorReloj #(.DIV_FACTOR(25000)) uut_clk_ms (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_ms)
    );

    // Instantiate the boton module
    Boton #(.MIN_TIME(10)) uut(
        .clk(clk_ms),
        .reset(reset),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    // Clock 50 MHz generation
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 1;
        reset = 1;
        btn_in = 0;
        
        // Reset
        #15 reset = 0;

        // Test button
        #DELAY btn_in = 1;
        #BTN_PRESS_TIME_10ms btn_in = 0;
        // expected btn_out = 1;
      
        #DELAY btn_in = 1;    
        #BTN_PRESS_TIME_3ms btn_in = 0;
        // expected btn_out = 0;  

        $finish; 

    end
 
	initial begin: TEST_CASE
     $dumpfile("boton_tb.vcd");
     $dumpvars(-1, uut);
    end

endmodule