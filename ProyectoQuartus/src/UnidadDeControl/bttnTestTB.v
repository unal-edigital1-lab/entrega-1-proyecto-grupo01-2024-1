`timescale 1ns / 1ps
`include "/home/samarinbe/Desktop/LabsDig1/entrega-1-proyecto-grupo01-2024-1/ProyectoQuartus/src/UnidadDeControl/bttnTest.v"

module bttnTestTB;

    // Inputs
    reg clk;
    reg rst;
    reg botonTest;
    wire btnTest;
    wire contBtnPress;

    // Instantiate the module under test
    bttnTest #(1, 5) uut(
        .clk(clk),
        .rst(rst),
        .botonTest(botonTest),
        .btnTest(btnTest)
    );

    // Clock generation
	always #5 clk = ~clk;

    initial begin
        clk = 0;
        botonTest = 0;
        #5
        rst = 1;
        #10 rst = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #20 botonTest = 1;
        #100 botonTest = 0;

        #30 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #50 botonTest = 1;
        #110 botonTest = 0;

        #30 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

        #10 botonTest = 1;
        #10 botonTest = 0;

    end

    initial begin:TEST_CASE
    $dumpfile("bttnTestTB.vcd");
	$dumpvars(-1, uut);
	#1000 $finish; 
end


endmodule