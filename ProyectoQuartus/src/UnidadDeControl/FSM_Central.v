// Dormir 
module FSM_Central#(parameter COUNT_MAX = 50000 , Ener = 40000, Feed = 10000, Entert= 20000, CONTUNI = 200000)(
// Entradas
	input clk,
	input rst,
	input botonSleep,
	input botonAwake,
	input botonFeed,
	input botonPlay,
	input giro,
	input botonTest,
	input [3:0] BpulseTest,
// Salidas
	output reg [3:0] state,
	output reg [2:0] energy,
	output reg [2:0] hunger,
	output reg [2:0] entertainment,
	output  [3:0] led4
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
	localparam TEST = 4'd9;    // 9
	
	
	//Registros 
	//reg [3:0] state;
	reg [3:0] next;
	reg clkms;
	reg [$clog2(COUNT_MAX)-1:0] counter;
	//reg [$clog2(CONTUNI)-1:0] contTime;
	reg [$clog2(CONTUNI)-1:0] contTimeEnergy, contTimeHunger, contTimeEntertainment;
	assign led4 =BpulseTest;
	//Valores de Inicio
	initial begin
		state <= IDLE;
		next <= IDLE;
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
					end else if(botonTest) begin
                        next = TEST;
                    end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end 
				end
				NEUTRAL: begin 
						if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(botonTest) begin
                        	next = TEST;
                    	end else if(energy <= 3'd2 && hunger > 3'd2 && entertainment > 3'd2) begin
							next = TIRED;
						end else if(hunger <= 3'd2 && energy > 3'd2 && entertainment > 3'd2) begin
							next = HUNGRY;
						end else if(entertainment <= 3'd2 && energy > 3'd2 && hunger > 3'd2) begin
							next = BORED;
						end else if((hunger < 3'd2 && energy < 3'd2) || (entertainment < 3'd2 && energy < 3'd2) || (hunger < 3'd2 && entertainment < 3'd2)) begin
							next = SAD;
						end  else begin
							next = NEUTRAL;
						end
				end
				TIRED: begin 
					if (botonSleep) begin
							next = SLEEP;
						end else if(botonTest) begin
                        	next = TEST;
                    	end else if(energy < 3'd2 || hunger <= 3'd2 || entertainment <= 3'd2) begin
							next = SAD;
						end else if(hunger == 3'd0 || energy == 3'd0 || entertainment == 3'd0) begin
							next = DEATH;
						end else begin
							next = TIRED;
						end
				end

				HUNGRY: begin 
					if (botonSleep && !botonPlay) begin
							next = SLEEP;
						end else if(!botonSleep && botonPlay) begin
							next = PLAYING;
						end else if(botonTest) begin
                        	next = TEST;
                    	end else if(hunger == 3'd0 || energy == 3'd0 || entertainment == 3'd0) begin
							next = DEATH;
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
						end else if(botonTest) begin
                        	next = TEST;
                    	end else if(hunger == 3'd0 || energy == 3'd0 || entertainment == 3'd0) begin
							next = DEATH;
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
						end else if(botonTest) begin
                        	next = TEST;
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
					end else if(botonTest) begin
                        	next = TEST;
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
					end else if(botonTest) begin
                        	next = TEST;
                    end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end else if (energy == 3'd5) begin
						next = NEUTRAL;
					end  else begin
						next = SLEEP;
					end
				end

				TEST: begin
					if (!botonTest) begin
						if(BpulseTest == 4'd1) begin
						//energy = 3'd5;
						//hunger = 3'd5;
						//entertainment = 3'd5;
                        	next = IDLE;
						end else if (BpulseTest == 4'd2) begin
						//energy = 3'd4;
						//hunger = 3'd4;
						//entertainment = 3'd4;
                        	next = NEUTRAL;
						end else if (BpulseTest == 4'd3) begin
						//energy = 3'd2;
						//hunger = 3'd5;
						//entertainment = 3'd5;
                        	next = TIRED;
						end else if (BpulseTest == 4'd4) begin
							//energy = 3'd2;
							//hunger = 3'd5;
							//entertainment = 3'd5;
							next = SLEEP;
						end else if (BpulseTest == 4'd5) begin
							//energy = 3'd5;
							//hunger = 3'd2;
							//entertainment = 3'd5;
							next = HUNGRY;
						end else if (BpulseTest == 4'd6) begin
							//energy = 3'd2;
							//hunger = 3'd2;
							//entertainment = 3'd5;
							next = SAD;
						end else if (BpulseTest == 4'd7) begin
							//energy = 3'd5;
							//hunger = 3'd5;
							//entertainment = 3'd2;
							next = PLAYING;
						end else if (BpulseTest == 4'd8) begin
						//energy = 3'd5;
						//hunger = 3'd5;
						//entertainment = 3'd2;
                        	next = BORED;
						end else if (BpulseTest == 4'd9) begin
						//energy = 3'd0;
						//hunger = 3'd0;
						//entertainment = 3'd0;
                        	next = DEATH;
					end else begin
                        next = TEST;
                    end
            end else begin
                next = TEST;
            end
					
				end

				default: next = DEATH;
		endcase
	end


// Incrementador y disminuidor de energía
always @(posedge clkms or posedge rst) begin
    if (rst) begin
        energy <= 3'd5;
        contTimeEnergy <= 0;
    end else begin
        if (state == TEST) begin
				contTimeEnergy <= 0;
            case (BpulseTest)
                4'd1: energy <= 3'd5;
                4'd2: energy <= 3'd4;
                4'd3: energy <= 3'd2;
                4'd4: energy <= 3'd2;
                4'd5: energy <= 3'd5;
                4'd6: energy <= 3'd2;
                4'd7: energy <= 3'd5;
                4'd8: energy <= 3'd5;
                4'd9: energy <= 3'd0;
            endcase
            contTimeEnergy <= 0;
        end else if (state == SLEEP && state != TEST && energy < 3'd5 && contTimeEnergy == Ener-1) begin
            energy <= energy + 1;
            contTimeEnergy <= 0;
        end else if (state != DEATH && state != TEST && energy > 0) begin
            if (contTimeEnergy == Ener-1) begin
                energy <= energy - 1;
                contTimeEnergy <= 0;
            end else begin
                contTimeEnergy <= contTimeEnergy + 1;
            end
        end
    end
end

// Incrementador y disminuidor de Hambre
always @(posedge clkms or posedge rst) begin
    if (rst) begin
        hunger <= 3'd5;
        contTimeHunger <= 0;
    end else begin
        if (state == TEST) begin
				contTimeHunger <= 0;
            case (BpulseTest)
                4'd1: hunger <= 3'd5;
                4'd2: hunger <= 3'd4;
                4'd3: hunger <= 3'd5;
                4'd4: hunger <= 3'd5;
                4'd5: hunger <= 3'd2;
                4'd6: hunger <= 3'd2;
                4'd7: hunger <= 3'd5;
                4'd8: hunger <= 3'd5;
                4'd9: hunger <= 3'd0;
            endcase
            contTimeHunger <= 0;
        end else if (botonFeed && hunger < 3'd5 && state != TEST) begin
            hunger <= hunger + 1;
            contTimeHunger <= 0;
        end else if (state != DEATH && state != TEST && hunger > 0) begin
            if (contTimeHunger == Feed-1) begin
                hunger <= hunger - 1;
                contTimeHunger <= 0;
            end else begin
                contTimeHunger <= contTimeHunger + 1;
            end
        end
    end
end

// Incrementador y disminuidor de entretenimiento
always @(posedge clkms or posedge rst) begin
    if (rst) begin
        entertainment <= 3'd5;
        contTimeEntertainment <= 0;
    end else begin
        if (state == TEST) begin
				contTimeEntertainment <= 0;
            case (BpulseTest)
                4'd1: entertainment <= 3'd5;
                4'd2: entertainment <= 3'd4;
                4'd3: entertainment <= 3'd5;
                4'd4: entertainment <= 3'd5;
                4'd5: entertainment <= 3'd5;
                4'd6: entertainment <= 3'd5;
                4'd7: entertainment <= 3'd2;
                4'd8: entertainment <= 3'd2;
                4'd9: entertainment <= 3'd0;
            endcase
            contTimeEntertainment <= 0;
        end else if (state == PLAYING && state != TEST && entertainment < 3'd5 && contTimeEntertainment == Entert-1) begin
            entertainment <= entertainment + 1;
            contTimeEntertainment <= 0;
        end else if (state != DEATH && state != TEST && entertainment > 0) begin
            if (contTimeEntertainment == Entert-1) begin
                entertainment <= entertainment - 1;
                contTimeEntertainment <= 0;
            end else begin
                contTimeEntertainment <= contTimeEntertainment + 1;
            end
        end
    end
end

/*// Contador de tiempo en general 
	always @(posedge clkms or posedge rst) begin
		if(rst)begin
			contTime <= 0;
		end else begin
            contTime <= contTime+1;
        end
	end*/

endmodule
