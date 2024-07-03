// Dormir 
module Dormir_Test#(parameter COUNT_MAX = 50000 , Ener = 40000, Feed = 10000, CONTUNI = 200000)(
// Entradas
	input clk,
	input rst,
	input botonSleep,
	input botonAwake,
	input botonFeed,
// Salidas
	output wire sign_IDLE,
	output wire sign_NEUTRAL,
	output wire sign_TIRED,
	output wire sign_SLEEP,
	output wire sign_DEATH
	);
	
	// Parámetros de la FSM
	localparam IDLE = 3'd0;
	localparam SLEEP = 3'd1;
	localparam NEUTRAL = 3'd2;
	localparam TIRED = 3'd4;
	localparam DEATH = 3'd5;
	
	//Registros 
	reg [2:0] state;
	reg [2:0] next;
	reg clkms;
	reg [$clog2(COUNT_MAX)-1:0] counter;
	reg [$clog2(CONTUNI)-1:0] contTime;
	//reg en_death;
	reg [2:0] energy;
	reg [2:0] Hunger;
	
	//Valores de Inicio
	initial begin
		state <= IDLE;
		next <= IDLE;
		//en_death <= 'b0;
		clkms <= 'b0;
		energy <= 3'd5;
		Hunger <= 3'd5;
	end
	
	//Reset de la máquina de estados
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= IDLE;
		end else begin
			state <= next;
		end
	end
	
// Divisor de frecuencia , a reloj en ms
		always @(posedge clk or posedge rst) begin
		if(rst)begin
			clkms <=0;
			counter <=0;
		end else begin
		if (counter == COUNT_MAX-1) begin
			clkms <= ~clkms;
			counter <= 0;
			end else begin
				counter = counter +1;
			end
		end
	end
	
	
// Máquina de Estados , general: Cambio entre estados 	
	always @(*) begin
		case (state)
				IDLE: begin 
					if (botonSleep & energy != 3'd5) begin
						next = SLEEP;
					end else if (energy < 3'd5) begin
						next = NEUTRAL;
					end else if (energy == 3'd5) begin
						next = IDLE;
					end 
				end
				NEUTRAL: begin 
						if (botonSleep) begin
							next = SLEEP;
						end else if(energy <= 3'd2) begin
							next = TIRED;
						end else begin
							next = NEUTRAL;
						end
				end
				TIRED: begin 
					if (botonSleep) begin
							next = SLEEP;
					end else if(energy == 0) begin
							next = DEATH;
						end  else begin
							next = TIRED;
						end
				end
				SLEEP: begin 
					if(botonAwake) begin
						if(energy < 2) begin
							next = TIRED;
						end else if (energy < 5) begin
							next = NEUTRAL;
						end
					end else if (energy == 5) begin
						next = IDLE;
					end else begin
						next = SLEEP;
					end
				end
				default: next = DEATH;
		endcase
	end

// Incrementador y disminuidor de energía
	always@(posedge clk or posedge rst) begin
		if(rst)begin
			energy <= 3'd5;
		end else begin
			if (state == SLEEP & energy < 3'd5 & contTime == Ener-1) begin
				energy <= energy + 1;
				contTime <= 0;
			end else if (state != DEATH) begin
				if(contTime == Ener-1) begin
					energy <= energy - 1;
					contTime <= 0;
				end
			end 
			

		end
	end

// Contador de tiempo en general 
	always @(posedge clkms or posedge rst) begin
		if(rst)begin
			contTime <= 0;
		end else begin
            contTime <= contTime+1;
        end
	end

	assign sign_IDLE = (state == IDLE);  // Update sign_IDLE based on the next state
	assign sign_NEUTRAL = (state == NEUTRAL);  // Update sign_IDLE based on the next state
	assign sign_TIRED = (state == TIRED);  // Update sign_IDLE based on the next state
	assign sign_SLEEP= (state == SLEEP);  // Update sign_IDLE based on the next state
	assign sign_DEATH= (state == DEATH);  // Update sign_IDLE based on the next state


	
endmodule
