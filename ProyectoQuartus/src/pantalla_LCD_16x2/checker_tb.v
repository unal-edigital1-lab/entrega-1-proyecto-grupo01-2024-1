//`timescale 1ns / 1ps
//`include "checker.v"

module checker_tb;

    // Parameters
    parameter MAX_VALUE = 5;
    parameter CLK_PERIOD = 10; // 50 MHz clock
    parameter DIV_FACTOR = 80; // 2480 ns period, 403.2258 kHz
    parameter NEW_FREQ = 50e6/(DIV_FACTOR*2);
    parameter CLKR_PERIOD = (1/NEW_FREQ)*1e9; 

    // Declaracion de señales
    reg clk = 0;
    reg reset;
    reg [$clog2(MAX_VALUE)-1:0] the_signal;
    wire change;

    // Instancia del UUT
    checker #(.PERIOD_COUNT(MAX_VALUE)) uut (
        .clk(clk),
        .reset(reset),
        .the_signal(the_signal),
        .change(change)
    );

    // Generacion de clock
    always begin
        #CLK_PERIOD  clk = ~clk;
    end

    initial begin
        reset = 0;
        the_signal = 0;
        
        
        #CLKR_PERIOD reset = 1;
        #CLKR_PERIOD the_signal = 1;
        #CLKR_PERIOD the_signal = 2;
        #CLKR_PERIOD the_signal = 3;

        #CLKR_PERIOD
        #(CLKR_PERIOD*10)
        $finish;
    
    end

    initial begin: TEST_CASE
        $dumpfile("checker_tb.vcd");
        $dumpvars(-1, uut);
    end
    
endmodule
