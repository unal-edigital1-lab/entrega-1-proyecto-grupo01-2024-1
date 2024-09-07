//`timescale 1ns / 1ps
//`include "lcd1602_controller.v"


module LCD1602_CONTROLLER_tb;

    // Declare signals
    reg clk;
    reg reset;
    reg [$clog2(9)-1:0] face;
    reg [$clog2(5)-1:0] feed_value;
    reg [$clog2(5)-1:0] joy_value;
    reg [$clog2(5)-1:0] energy_value;
    wire rs;
    wire rw;
    wire enable;
    wire [7:0] data;

    // Instantiate the LCD1602_TEXT module
    LCD1602_CONTROLLER #(
        .MAX_VALUE(5),
        .NUM_FACES(9),
        .COUNT_MAX(8)
    ) uut (
        .clk(clk),
        .reset(reset),
        .face(face),
        .food_value(feed_value),
        .joy_value(joy_value),
        .energy_value(energy_value),
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
        face = 0;
        feed_value = 5;
        joy_value = 5;
        energy_value = 5;

        // Apply reset
        reset = 0;
        #10;
        reset = 1;

        #(6e4);

        // Set face and values
        #20 face = 3;
        #20 feed_value = 0;
        #20 joy_value = 1;
        #20 energy_value = 2;

        // Wait for some time to observe the behavior
        #(2e4);

        #(1e3) reset = 0;
        #(10) begin face = 0; feed_value = 5; joy_value = 5; energy_value = 5; end
        #(1e3) reset = 1;
        #(6e4);

        // Change values
        #20 face = 4;
        #20 feed_value = 5;
        #20 joy_value = 5;
        #20 energy_value = 5;

        // Wait for some time to observe the behavior
        #(2e4);

        // Finish simulation
        $finish;
    end

    initial begin: TEST_CASE
        $dumpfile("lcd_controller_tb.vcd");
        $dumpvars(-1, uut);
    end

endmodule