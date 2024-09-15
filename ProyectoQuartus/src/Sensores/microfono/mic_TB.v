`timescale 1ms / 1ps
`include "/home/jpalaciosch/Desktop/Digital_I/DigitalLabs/proyecto-final/entrega-1-proyecto-grupo01-2024-1/ProyectoQuartus/src/Sensores/microfono/mic.v"

module mic_TB;

    // Inputs
    reg clk;
    reg rst;
    reg mic;
    reg [3:0] state_t;
    wire buzzer;
    wire signal_awake;

    // Instantiate the module under test
    mic #(50) uut(
        .clk(clk),
        .rst(rst),
        .mic(mic),
        .state_t(state_t),
        .buzzer(buzzer),
        .signal_awake(signal_awake)
    );

    // Clock generation
	always #5 clk = ~clk;

    initial begin
        clk = 0;
        mic = 0;
        state_t = 0;
        rst = 1;
        #1000 rst = 0;
        #1000 rst = 1;

        #100 state_t = 0;
        #100000 mic = 1;
        #1000 mic = 0;


        #10 state_t = 4;

        #50000 mic = 1;
        #100000 mic = 0;

        #100state_t = 8;
        #20000 mic = 1;
        #10000 mic = 0;
    end

    initial begin:TEST_CASE
    $dumpfile("mic_TB.vcd");
	$dumpvars(-1, uut);
	#1000000 $finish; 
end


endmodule