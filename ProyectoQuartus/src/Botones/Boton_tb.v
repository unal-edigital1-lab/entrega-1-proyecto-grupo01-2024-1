`timescale 1ns / 1ps
`include "Boton.v"
// 1us = 1e3 ns, 1ms = 1e6 ns

module Boton_tb;
    // Parameters
    localparam CLK_PERIOD = 10; // 50 MHz clock
    localparam BTN_PRESS_TIME_10ms = 10e3; // Press button for 10 ms
    localparam BTN_PRESS_TIME_3ms = 3e3; // Press button for 3 ms
    
    // Boton signals
    reg clk; 
    reg btn_in;
    wire btn_out;

    // Instantiate the boton module
    Boton #(.MIN_TIME(500), .TIME_ANTIREBOTE(10)) uut_boton(
        .clk(clk),
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
        btn_in = 0;
        
        // Test button
        #(1e3) btn_in = 1;
        #BTN_PRESS_TIME_10ms btn_in = 0;
        // expected btn_out = 1;
      
        #(1e3) btn_in = 1;    
        #BTN_PRESS_TIME_3ms btn_in = 0;
        // expected btn_out = 0;

        #(1e3) btn_in = 1;    
        #BTN_PRESS_TIME_3ms btn_in = 0;
        // expected btn_out = 0;  
        #(1e3) btn_in = 1;   
        
        #(1e3)
        $finish; 

    end
 
	initial begin: TEST_CASE
     $dumpfile("boton_tb.vcd");
     $dumpvars(-1, uut_boton);
    end

endmodule