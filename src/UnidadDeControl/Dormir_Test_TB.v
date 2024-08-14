`timescale 1ms/1us
`include "/home/samarinbe/Desktop/Ingeniería Electrónica UN/3. Tercer Semestre/Electrónica Digital 1/entrega-1-proyecto-grupo01-2024-1/src/UnidadDeControl/Dormir_Test.v"


module Dormir_Test_TB;

	reg clk;
	reg rst;
	reg BSleep;
	reg BAwake;
	reg BFeed;
	reg BPlay;
	reg Giro;
	reg BTest;
	reg [3:0] PulseTest;

	wire SIDLE;
	wire SSLEEP;
	wire SNEUTRAL;
	wire STIRED;
	wire SDEATH;
	wire SHUNGRY;
	wire SSAD;
	wire SPLAYING;
	wire SBORED;
	
	Dormir_Test #(5,4,4,4,20) uut(
		.clk(clk),
		.rst(rst),
		.botonSleep(BSleep),
		.botonAwake(BAwake),
		.botonFeed(BFeed),
		.botonPlay(BPlay),
		.giro(Giro),
		.botonTest(BTest),
        .pulseTest(PulseTest),
		.sign_IDLE(SIDLE),
		.sign_SLEEP(SSLEEP),
		.sign_NEUTRAL(SNEUTRAL),
		.sign_TIRED(STIRED),
		.sign_DEATH(SDEATH),
		.sign_HUNGRY(SHUNGRY),
		.sign_SAD(SSAD),
		.sign_PLAYING(SPLAYING),
		.sign_BORED(SBORED)
	);
	
	always #1 clk = ~clk;
	
	initial begin
	clk=0;
	BSleep = 0; BAwake = 0; BFeed=0; BPlay=0; Giro=0; BTest=0; PulseTest=0;
	rst = 1;
	#50;
	rst = 0;
	#250;
	BTest = 1; PulseTest = 4'd5;
	#2;
	BTest = 0;

	/*
	BSleep = 1;
	#103;
	BFeed = 1;
	#2;
	BFeed = 0; BSleep = 0;
	#2;
	BFeed = 1;
	#2;
	BFeed = 0;
	#2;
	BFeed = 1;
	#2;
	BFeed = 0;
	#2;
	BFeed = 1;
	#2;
	BFeed = 0;
	#10;
	BAwake = 1; BSleep =0;
	#10;
	rst = 1;
	#2;
	rst = 0;
	
	#10 BSleep = 1; BAwake = 0;
	#10 BSleep =0; BAwake = 1;
	#10 BAwake =0;
	#10 BAwake =1;
	#10 BAwake =0;
	#10 BSleep = 1;
	#10 BSleep =0;
	*/
	end

initial begin:TEST_CASE
    $dumpfile("Dormir_Test_TB.vcd");
	$dumpvars(-1, uut);
	#1000 $finish; 
end

	
	
endmodule