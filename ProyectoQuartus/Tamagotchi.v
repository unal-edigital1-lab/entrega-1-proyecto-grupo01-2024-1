//`include "/home/samarinbe/Desktop/LabsDig1/entrega-1-proyecto-grupo01-2024-1/src/UnidadDeControl/FSM_Central.v"
//`include "/home/samarinbe/Desktop/LabsDig1/entrega-1-proyecto-grupo01-2024-1/src/pantalla_LCD_16x2/lcd1602_cust_char.v"
module Tamagotchi (
// Entradas
   input clk,
   input rst,
   input BSleep,
	input BAwake,
	input BFeed,
	input BPlay,
	input Giro,
	input BTest,
	//input [3:0] pulseTest,
// Salidas
    output wire BUZZER;
    output wire rs_,        
    output wire rw_,
    output wire enable_,    
    output wire [7:0] data_,
	 
	 output [0:6] sseg,
	 output [3:0] led4,
	 output wire [3:0] An
	
);

/*
wire clk_ms;
DivisorReloj #(.DIV_FACTOR(25000)) divisor_clk_ms (
	.clk_in(clk),
	.reset(reset),
	.clk_out(clk_ms)
);*/


///////////////////////// BOTONES ///////////////////////////
wire reset;
Reset_AntiR BotonReset(
    .btnRst_in(rst),
    .clk_(clk),
    .btnRst_out(reset)
);


wire btnTest;
wire [3:0] NumPulse;
Test_AntiR BotonTest(
	.btnTest_in(BTest),
    .clk_(clk),
    .rst_(reset),
    .btnTest_out(btnTest),
    .NUMPULSE(NumPulse) 
);


wire btnSleep;
Boton_AR BotonSleep(
	 .reset(rst),
    .clk(clk),
    .boton_in(BSleep),
    .boton_out(btnSleep)
);


wire btnFeed;
Boton_AR BotonFeed(
	 .reset(rst),
    .clk(clk),
    .boton_in(~BFeed),
    .boton_out(btnFeed)
);


wire btnPlay;
Boton_AR BotonPlay(
	 .reset(rst),
    .clk(clk),
    .boton_in(~BPlay),
    .boton_out(btnPlay)
);


///////////////////////// UNIDAD DE CONTROL ///////////////////////////
wire [3:0] face_;
wire [2:0] energy_;
wire [2:0] hunger_;
wire [2:0] entertainment_;
//assign led4 =pulseTest;
FSM_Central InstFSM(
		.clk(clk),
		.rst(reset),
		.botonSleep(btnSleep),
		.botonAwake(sigAwake),
		.botonFeed(btnFeed),
		.botonPlay(btnPlay),
		.giro(Giro),
		.botonTest(btnTest),
      .BpulseTest(NumPulse),
		.face(face_),
		.led4(led4),
		.energy(energy_),
		.hunger(hunger_),
		.entertainment(entertainment_)
	);
	
wire sigAwake;	
mic InstMic(
    .mic(BAwake),
    .clk(clk),
    .rst(reset),
    .state_t(face_),
    .buzzer(BUZZER),
    .signal_awake(sigAwake)
);

LCD1602_CONTROLLER InstLCD(
    .clk(clk),   
    .reset(reset),
    .face(face_),   
    .feed_value(hunger_),
    .joy_value(entertainment_),
    .energy_value(energy_),
    .rs(rs_),  
    .rw(rw_),
    .enable(enable_),
    .data(data_)
);


///////////////////////// VISUALIZACIÓN ///////////////////////////
BCDtoSSeg InstSsegState(

	.BCD(face_),
	.SSeg(sseg),
	.an(An)

);


endmodule