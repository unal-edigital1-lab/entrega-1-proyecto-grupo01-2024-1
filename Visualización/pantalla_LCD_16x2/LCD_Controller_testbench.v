`timescale 1ns / 1ps
`include "/home/jpalaciosch/Desktop/Digital_I/DigitalLabs/entrega-1-proyecto-grupo01-2024-1/ProyectoTamagotchi/LCD_Controller.v"
module LCD_Controller_testbench;
    // Inputs
    reg clk;
    // Outputs
    wire rs, ena, rw;
    wire [7:0] dat;

    parameter COUNT_MAX = 1000000;

    // Instantiate the LCD_Controller module
    LCD_Controller #(.COUNT_MAX(10))uut (
        .clk(clk),
        .rs(rs),
        .ena(ena),
        .rw(rw),
        .dat(dat)
    );

    // Clock generation
    always begin
        clk = 0;
        #50;
        clk = 1;
        #50;
    end

    // Stimulus generation
    initial begin
        #COUNT_MAX;
        $finish;
    end

    initial begin: TEST_CASE
		$dumpfile("LCD_Controller_testbench.vcd");
		$dumpvars(-1,uut);
		#COUNT_MAX $finish;
	end
endmodule