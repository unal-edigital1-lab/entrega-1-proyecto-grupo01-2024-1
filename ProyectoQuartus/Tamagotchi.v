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
	input [3:0] pulseTest,
// Salidas
	//output wire [3:0] state,
	//output wire [2:0] energy,
	//output wire [2:0] hunger,
	//output wire [2:0] entertainment,
		 /*
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
	 */
	output [0:6] sseg,
	output [3:0] led4,
	output wire [3:0] An
	
);

wire reset;
Reset_AntiR RestInst(
    .btnRst_in(rst),
    .clk_(clk),
    .btnRst_out(reset)
);

wire bottonTest;
wire [3:0] NumPulse;
Test_AntiR(
	 .botonTest(BTest),
    .clk_(clk),
    .rst_(reset),
    .BOTONTest(bottonTest),
    .NUMPULSE(NumPulse) 
);

wire btnSleep;
Boton BotonSleep(
    .clk(clk),
    .btn_in(BSleep),
    .btn_out(btnSleep)
);

wire btnFeed;
Boton BotonFeed(
    .clk(clk),
    .btn_in(BFeed),
    .btn_out(btnFeed)
);

wire btnPlay;
Boton BotonPlay(
    .clk(clk),
    .btn_in(BPlay),
    .btn_out(btnPlay)
);
wire [3:0] state;
//assign led4 =pulseTest;
FSM_Central InstFSM(
		.clk(clk),
		.rst(reset),
		.botonSleep(btnSleep),
		.botonAwake(BAwake),
		.botonFeed(btnFeed),
		.botonPlay(btnPlay),
		.giro(Giro),
		.botonTest(bottonTest),
      .BpulseTest(NumPulse),
		.state(state),
		.led4(led4)
		//.energy(energy),
		//.hunger(hunger),
		//.entertainment(entertainment)
	);
	/*
lcd1602_cust_char_v2 InstLCD(

    .clk(clk),
    .reset(rst),
    .state(state),
    .rs(rs),
    .rw(rw),
    .enable(enable),
    .data(data)

);*/

BCDtoSSeg InstSseg(

	.BCD(state),
	.SSeg(sseg),
	.an(An)

);


endmodule