`timescale 1ms/1us
`include "/home/samarinbe/Desktop/LabsDig1/entrega-1-proyecto-grupo01-2024-1/ProyectoQuartus/src/UnidadDeControl/FSM_Central.v"


module FSM_Central_TB;

	reg clk;
	reg rst;
	reg BSleep;
	reg BAwake;
	reg BFeed;
	reg BPlay;
	reg Giro;
	reg BTest;
	reg [3:0] PulseTest;

	/*wire SIDLE;
	wire SSLEEP;
	wire SNEUTRAL;
	wire STIRED;
	wire SDEATH;
	wire SHUNGRY;
	wire SSAD;
	wire SPLAYING;
	wire SBORED;
	*/
	wire [3:0] face_;
	wire [2:0] energy;
	wire [2:0] hunger;
	wire [2:0] entertainment;
	
	FSM_Central #(25,40,15,20,200) uut(
		.clk(clk),
		.rst(rst),
		.botonSleep(BSleep),
		.botonAwake(BAwake),
		.botonFeed(BFeed),
		.botonPlay(BPlay),
		.giro(Giro),
		.botonTest(BTest),
        .BpulseTest(PulseTest),
		.face(face_),
		.energy(energy),
		.hunger(hunger),
		.entertainment(entertainment)
	);
	
	always #1 clk = ~clk;
	
	initial begin
	clk=0;
	BSleep = 0; BAwake = 0; BFeed=0; BPlay=0; Giro=0; BTest=0; PulseTest=0;
	rst = 1;
	#50;
	rst = 0;
	#110;
	BPlay =1; Giro=1;
	#5;
	BPlay = 0;
	#10;
	Giro = 1;
	#2 BFeed =1;
	#2 BFeed =0;
	#2 BFeed =1;
	#2 BFeed =0;
	#2 BFeed =1;
	#2 BFeed =0;
	#2 BFeed =1;
	#2 BFeed =0;
	#10;
	Giro = 0;
	/*
	BTest = 1; 
	#10
	PulseTest = 4'd1;
	#10
	BTest = 0;
	#10
	PulseTest = 4'd0;
*/
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
    $dumpfile("FSM_Central_TB.vcd");
	$dumpvars(-1, uut);
	#2000; $finish; 
end

endmodule