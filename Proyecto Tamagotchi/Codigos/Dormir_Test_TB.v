`timescale 1ms/1us
`include "/home/samarinbe/Desktop/LabsDig1/ProyectoTamagotchi/Pruebas/Dormir_Test.v"


module Dormir_Test_TB;

	reg clk;
	reg rst;
	reg BSleep;
	reg BAwake;
	reg BFeed;
	wire SIDLE;
	wire SNEUTRAL;
	wire STIRED;
	wire SSLEEP;
	wire SDEATH;
	
	Dormir_Test #(5,4,1,20) uut(
		.clk(clk),
		.rst(rst),
		.botonSleep(BSleep),
		.botonAwake(BAwake),
		.botonFeed(BFeed),
		.sign_IDLE(SIDLE),
		.sign_NEUTRAL(SNEUTRAL),
		.sign_TIRED(STIRED),
		.sign_SLEEP(SSLEEP),
		.sign_DEATH(SDEATH)
	);
	
	always #1 clk = ~clk;
	
	initial begin
	clk=0;
	BSleep = 0; BAwake = 0;
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