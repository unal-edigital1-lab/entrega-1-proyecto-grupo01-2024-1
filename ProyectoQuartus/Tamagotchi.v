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


wire clk_ms;
DivisorReloj #(.DIV_FACTOR(25000)) divisor_clk_ms (
	.clk(clk),
	.reset(reset),
	.clk_out(clk_ms)
);


///////////////////////// BOTONES ///////////////////////////
wire reset;
Reset_AntiR BotonReset(
    .btnRst_in(rst),
    .clk_(clk_ms),
    .btnRst_out(reset)
);


wire btnTest;
wire [3:0] NumPulse;
Test_AntiR BotonTest(
	.btnTest_in(BTest),
    .clk_(clk_ms),
    .rst_(reset),
    .btnTest_out(btnTest),
    .NUMPULSE(NumPulse) 
);


wire btnSleep;
Boton BotonSleep(
    .clk(clk_ms),
    .btn_in(BSleep),
    .btn_out(btnSleep)
);


wire btnFeed;
Boton BotonFeed(
    .clk(clk_ms),
    .btn_in(BFeed),
    .btn_out(btnFeed)
);


wire btnPlay;
Boton BotonPlay(
    .clk(clk_ms),
    .btn_in(BPlay),
    .btn_out(btnPlay)
);


///////////////////////// UNIDAD DE CONTROL ///////////////////////////
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
		.btnTest_out(btnTest),
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


///////////////////////// VISUALIZACIÓN ///////////////////////////
BCDtoSSeg InstSseg(

	.BCD(state),
	.SSeg(sseg),
	.an(An)

);


endmodule