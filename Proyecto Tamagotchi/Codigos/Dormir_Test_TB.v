`timescale 1ms/1us
`include "/home/samarinbe/Desktop/Ingeniería Electrónica UN/3. Tercer Semestre/Electrónica Digital 1/entrega-1-proyecto-grupo01-2024-1/Proyecto Tamagotchi/Codigos/Dormir_Test.v"


module Dormir_Test_TB;

	reg clk;
	reg rst;
	reg BSleep;
	reg BAwake;
	reg BFeed;
	wire SIDLE;
	wire SSLEEP;
	wire SNEUTRAL;
	wire STIRED;
	wire SDEATH;
	wire SHUNGRY;
	wire SSAD;
	
	Dormir_Test #(5,4,4,20) uut(
		.clk(clk),
		.rst(rst),
		.botonSleep(BSleep),
		.botonAwake(BAwake),
		.botonFeed(BFeed),
		.sign_IDLE(SIDLE),
		.sign_SLEEP(SSLEEP),
		.sign_NEUTRAL(SNEUTRAL),
		.sign_TIRED(STIRED),
		.sign_DEATH(SDEATH),
		.sign_HUNGRY(SHUNGRY),
		.sign_SAD(SSAD)
	);
	
	always #1 clk = ~clk;
	
	initial begin
	clk=0;
	BSleep = 0; BAwake = 0; BFeed=0;
	rst = 1;
	#50;
	rst = 0;
	#250;
	BSleep = 1;
	#127;
	BAwake = 1; BSleep =0;
	//#10 BSleep = 1; BAwake = 0;
	//#10 BSleep =0; BAwake = 1;
	//#10 BAwake =0;
	//#10 BAwake =1;
	//#10 BAwake =0;
	//#10 BSleep = 1;
	//#10 BSleep =0;
	
	end

initial begin:TEST_CASE
    $dumpfile("Dormir_Test_TB.vcd");
	$dumpvars(-1, uut);
	#1000 $finish; 
end

	
	
endmodule