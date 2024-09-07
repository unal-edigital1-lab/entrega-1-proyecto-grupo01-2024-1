`timescale 1ns / 1ps
`include "test_lcd1602.v"

module TEST_tb;

    // Declare signals
    reg clk;
    reg reset;
    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    // Instantiate the TEST module
    TEST #(
        .COUNT_MAX(8)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    // Generate clock signal
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;

        // Apply reset
        reset = 0;
        #10;
        reset = 1;

        // Wait for some time to observe the behavior
        #(10e5);

        // Finish simulation
        $finish;
    end

    // Monitor signals
    initial begin: TEST_CASE
        $dumpfile("lcd_controller_tb.vcd");
        $dumpvars(-1, uut);
    end


endmodule