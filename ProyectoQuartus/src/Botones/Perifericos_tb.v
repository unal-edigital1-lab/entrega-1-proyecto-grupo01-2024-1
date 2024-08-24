`timescale 1us / 1ns
`include "Perifericos.v"

module Perifericos_tb;

    // Parameters
    localparam CLK_PERIOD = 250; // 50 MHz clock
    localparam DELAY = 1e3; // 1 ms delay
    localparam BTN_PRESS_TIME_10ms = 10e3; // Press button for 10 ms
    localparam BTN_PRESS_TIME_3ms = 3e3; // Press button for 3 ms
    // Signals
    reg clk;
    reg reset;
    reg btn_in;
    wire btn_out;

    // Instantiate the debounce module
    Perifericos uut (
        .clk(clk),
        .reset(reset),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    // Clock generation
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        clk = 1;
        reset = 1;
        btn_in = 5'b0;
        
        // Reset
        #15 reset = 0;

        #DELAY btn_in = 0;

        // Test button 0
        #DELAY btn_in = 1;
        #BTN_PRESS_TIME_10ms btn_in = 0;
        // expected btn_out = 1;
      
        #DELAY btn_in = 1;    
        #BTN_PRESS_TIME_3ms btn_in = 0;
        // expected btn_out = 0;  

        $finish; 

    end
 
	initial begin: TEST_CASE
     $dumpfile("perifericos_tb.vcd");
     $dumpvars(-1, uut);
    end

endmodule