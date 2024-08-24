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
	output wire [3:0] state,
	output wire [2:0] energy,
	output wire [2:0] hunger,
	output wire [2:0] entertainment,
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data

);

FSM_Central uut(
		.clk(clk),
		.rst(rst),
		.botonSleep(BSleep),
		.botonAwake(BAwake),
		.botonFeed(BFeed),
		.botonPlay(BPlay),
		.giro(Giro),
		.botonTest(BTest),
        .pulseTest(PulseTest),
		/*
		.sign_IDLE(SIDLE),
		.sign_SLEEP(SSLEEP),
		.sign_NEUTRAL(SNEUTRAL),
		.sign_TIRED(STIRED),
		.sign_DEATH(SDEATH),
		.sign_HUNGRY(SHUNGRY),
		.sign_SAD(SSAD),
		.sign_PLAYING(SPLAYING),
		.sign_BORED(SBORED),
		*/
		.state(state),
		.energy(energy),
		.hunger(hunger),
		.entertainment(entertainment)
	);
lcd1602_cust_char_v2 uut(

    .clk(clk),
    .reset(rst),
    .state(state),
    .rs(rs),
    .rw(rw),
    .enable(enable),
    .data(data)

);

    // Agrega aquí la lógica y la funcionalidad de tu Tamagotchi

endmodule