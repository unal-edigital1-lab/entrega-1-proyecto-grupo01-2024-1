`timescale 1ns / 1ps
`include "/home/jpalaciosch/Desktop/Digital_I/DigitalLabs/proyecto-final/entrega-1-proyecto-grupo01-2024-1/src/Botones/bttnReset.v"

module bttnTestTB;

    // Inputs
    reg clk;
    reg rst;
    reg botonReset;
    wire btnRst;

    // Instantiate the module under test
    bttnReset #(1, 5) uut(
        .clk(clk),
        .rst(rst),
        .botonReset(botonReset),
        .btnRst(btnRst)
    );

    // Clock generation
	always #5 clk = ~clk;

    initial begin
        clk = 0;
        botonReset = 0;
        #5
        rst = 1;
        #10 rst = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #110 botonReset = 0;

        #30 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #50 botonReset = 1;
        #110 botonReset = 0;

        #30 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

        #10 botonReset = 1;
        #10 botonReset = 0;

    end

    initial begin:TEST_CASE
    $dumpfile("bttnResetTB.vcd");
	$dumpvars(-1, uut);
	#1000 $finish; 
end


endmodule