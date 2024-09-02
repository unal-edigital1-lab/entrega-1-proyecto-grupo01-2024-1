`timescale 1ns / 1ps
`include "/home/samarinbe/Desktop/LabsDig1/entrega-1-proyecto-grupo01-2024-1/ProyectoQuartus/src/Botones/bttnReset.v"

module bttnResestTB;

    // Inputs
    reg clk;
    reg btnRst_in;
    wire btnRst_out;

    // Instantiate the module under test
    bttnReset #(1, 10) uut(
        .clk(clk),
        .btnRst_in(btnRst_in),
        .btnRst_out(btnRst_out)
    );

    // Clock generation
	always #5 clk = ~clk;

    initial begin
        clk = 0;
        btnRst_in = 0;
        #5

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #210 btnRst_in = 0;

        #30 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #50 btnRst_in = 1;
        #210 btnRst_in = 0;

        #30 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

        #10 btnRst_in = 1;
        #10 btnRst_in = 0;

    end

    initial begin:TEST_CASE
    $dumpfile("bttnResetTB.vcd");
	$dumpvars(-1, uut);
	#1000 $finish; 
end


endmodule