`timescale 1ms / 1ps
`include "/home/samarinbe/Desktop/Ingeniería Electrónica UN/3. Tercer Semestre/Electrónica Digital 1/entrega-1-proyecto-grupo01-2024-1/Proyecto Tamagotchi/Codigos/mic.v"

module mic_TB;

    // Inputs
    reg clk;
    reg rst;
    reg mic;
    wire buzzer;

    // Instantiate the module under test
    mic #(50) uut(
        .clk(clk),
        .rst(rst),
        .mic(mic),
        .buzzer(buzzer)
    );

    // Clock generation
	always #5 clk = ~clk;

    initial begin
        clk = 0;
        mic = 0;
        rst = 1;
        #1000 rst = 0;

        #1000 mic = 1;
        #1000 mic = 0;

        #5000 mic = 1;
        #10000 mic = 0;
        #2000 mic = 1;
        #1000 mic = 0;
    end

    initial begin:TEST_CASE
    $dumpfile("mic_TB.vcd");
	$dumpvars(-1, uut);
	#1000000 $finish; 
end


endmodule