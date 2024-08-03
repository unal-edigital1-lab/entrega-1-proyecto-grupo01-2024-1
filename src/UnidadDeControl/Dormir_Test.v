// Dormir 
module Dormir_Test#(parameter COUNT_MAX = 50000 , Ener = 40000, Feed = 10000, Entert= 20000, CONTUNI = 200000)(
// Entradas
	input clk,
	input rst,
	input botonSleep,
	input botonAwake,
	input botonFeed,
	input botonPlay,
	input giro,
// Salidas
	output wire sign_IDLE,
	output wire sign_SLEEP,
	output wire sign_NEUTRAL,
	output wire sign_TIRED,
	output wire sign_DEATH,
	output wire sign_HUNGRY,
	output wire sign_SAD,
	output wire sign_PLAYING,
	output wire sign_BORED
	);
	

	// Parámetros de la FSM
	localparam IDLE = 4'd0;    // 0
	localparam NEUTRAL = 4'd1; // 1
	localparam TIRED = 4'd2;   // 2
	localparam SLEEP = 4'd3;   // 3
	localparam HUNGRY = 4'd4;  // 4
	localparam SAD = 4'd5;     // 5
	localparam PLAYING = 4'd6; // 6
	localparam BORED = 4'd7;   // 7
	localparam DEATH = 4'd8;   // 8
	
	//Registros 
	reg [3:0] state;
	reg [3:0] next;
	reg clkms;
	reg [$clog2(COUNT_MAX)-1:0] counter;
	reg [$clog2(CONTUNI)-1:0] contTime;
	//reg en_death;
	reg [2:0] energy;
	reg [2:0] hunger;
	reg [2:0] entertainment;
	
	//Valores de Inicio
	initial begin
		state <= IDLE;
		next <= IDLE;
		//en_death <= 'b0;
		clkms <= 'b0;
		energy <= 3'd5;
		hunger <= 3'd5;
		entertainment <= 3'd5;
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
					if (botonSleep && energy != 3'd5 && !botonPlay) begin
						next = SLEEP;
					end else if (!botonSleep && entertainment != 3'd5 && botonPlay) begin
						next = PLAYING;
					end else if (energy < 3'd5 || hunger < 3'd5 || entertainment < 3'd5) begin
						next = NEUTRAL;
					end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end 
				end
				NEUTRAL: begin 
						if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(energy <= 3'd2 && hunger > 3'd2 && entertainment > 3'd2) begin
							next = TIRED;
						end else if(hunger <= 3'd2 && energy > 3'd2 && entertainment > 3'd2) begin
							next = HUNGRY;
						end else if(entertainment <= 3'd2 && energy > 3'd2 && hunger > 3'd2) begin
							next = BORED;
						end else if(hunger < 3'd2 && energy < 3'd2 && entertainment < 3'd2) begin
							next = SAD;
						end  else begin
							next = NEUTRAL;
						end
				end
				TIRED: begin 
					if (botonSleep) begin
							next = SLEEP;
						end else if(energy < 3'd2 || hunger <= 3'd2 || entertainment <= 3'd2) begin
							next = SAD;
						end  else begin
							next = TIRED;
						end
				end

				HUNGRY: begin 
					if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(hunger < 3'd2 || energy <= 3'd2 || entertainment <= 3'd2) begin
							next = SAD;
						end else if(hunger > 3'd2) begin
							next = NEUTRAL;
						end else begin
							next = HUNGRY;
						end
				end

				BORED: begin 
					if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(entertainment < 3'd2 || hunger <= 3'd2 || energy <= 3'd2) begin
							next = SAD;
						end  else begin
							next = BORED;
						end
				end

				SAD: begin 
					if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(hunger == 3'd0 || energy == 3'd0 || entertainment == 3'd0) begin
							next = DEATH;
						end else if(hunger > 3'd1 && energy > 3'd2 && entertainment > 3'd2) begin
							next = HUNGRY;
						end  else begin
							next = SAD;
						end
				end

				PLAYING: begin 
					if(!giro) begin
						if(energy <= 3'd2 && hunger > 3'd2 && entertainment > 3'd2) begin
							next = TIRED;
						end else if (energy > 3'd2 && hunger <= 3'd2 && entertainment > 3'd2) begin
							next = HUNGRY;
						end else if (energy > 3'd2 && entertainment <= 3'd2 && hunger > 3'd2) begin
							next = BORED;
						end else if (energy < 3'd5 && hunger < 3'd5 && entertainment < 3'd5) begin
							next = NEUTRAL;
						end
					end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end else if (entertainment == 3'd5) begin
						next = NEUTRAL;
					end  else begin
						next = PLAYING;
					end
				end				

				SLEEP: begin 
					if(botonAwake || botonFeed) begin
						if(energy <= 3'd2 && hunger > 3'd2 && entertainment > 3'd2) begin
							next = TIRED;
						end else if (energy > 3'd2 && hunger <= 3'd2 && entertainment > 3'd2) begin
							next = HUNGRY;
						end else if (energy > 3'd2 && entertainment <= 3'd2 && hunger > 3'd2) begin
							next = BORED;
						end else if (energy < 3'd5 && hunger < 3'd5 && entertainment < 3'd5) begin
							next = NEUTRAL;
						end
					end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end else if (energy == 3'd5) begin
						next = NEUTRAL;
					end  else begin
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
			end else if (state != DEATH & energy > 0) begin
				if(contTime == Ener-1) begin
					energy <= energy - 1;
					contTime <= 0;
				end
			end 
			

		end
	end

// Incrementador y disminuidor de Hambre
	always@(posedge clk or posedge rst) begin
		if(rst)begin
			hunger <= 3'd5;
		end else begin
			if (botonFeed & hunger < 3'd5) begin
				hunger <= hunger + 1;
			end else if (state != DEATH & hunger >0 ) begin
				if(contTime == Feed-1) begin
					hunger <= hunger - 1;
					contTime <= 0;
				end
			end 
			

		end
	end

// Incrementador y disminuidor de entretenimiento
	always@(posedge clk or posedge rst) begin
		if(rst)begin
			entertainment <= 3'd5;
		end else begin
			if (state == PLAYING & entertainment < 3'd5 & contTime == Entert-1) begin
				entertainment <= entertainment + 1;
				contTime <= 0;
			end else if (state != DEATH & entertainment > 0) begin
				if(contTime == Entert-1) begin
					entertainment <= entertainment - 1;
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

	assign sign_IDLE = (state == IDLE);  
	assign sign_SLEEP= (state == SLEEP);  
	assign sign_NEUTRAL = (state == NEUTRAL);  
	assign sign_TIRED = (state == TIRED);  
	assign sign_DEATH= (state == DEATH);  
	assign sign_HUNGRY = (state == HUNGRY);  
	assign sign_SAD = (state == SAD);  
	assign sign_PLAYING = (state == PLAYING);  
	assign sign_BORED = (state == BORED);  

	
endmodule
