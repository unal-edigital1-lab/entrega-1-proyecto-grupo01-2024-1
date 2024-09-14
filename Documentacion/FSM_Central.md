# Módulo: FSM_Central.v

Este módulo constituye el cerebro de todo el tamagotchi y es quien controla el ciclo de vida del tamagotchi, la forma en la que el usuario puede interactuar con el tamagotchi y la forma en la que el transcurrir del tiempo lo afecta.

En el código [FSM_Central.v](./ProyectoQuartus/src/UnidadDeControl/FSM_Central.v). pueden encontrar lo siguiente:

**Definición de Entradas y Salidas**

En el fragmento de código adjunto a continuación, se puede observar el nombre que se le da al módulo de la máquina central del tamagotchi, se puede apreciar que se definen las entradas y salidas. Como entradas a este módulo se tienen las entradas de los botones y de los sensores. Despues de varias interaciones de diseño se llegó a lo siguente:

- El botónFeed va a ser la entrada de la señal del Utrasonido la cual indica cuando se coloca comida frente al tamagotchi.
- El botónAwake va a ser la señal proveniente del micrófono que indica que se hizo un ruido para despertar el tamagotchi.
- El botónSleep es la entrada de la señal del módulo anti-rebote correspondiente al botón de dormir.
- El botónPlay es la entrada de la señal del módulo anti-rebote correspondiente al botón de jugar.
- El botónTest es la entrada de la señal del módulo antirebote y del módulo del botón Test correspondiente al botón Test.
- El input giro, corresponde a la señal de entrada del dipswitch que saca el tamagotchi del modo jugar.
- El input BpulseTest es una entrada de 4 bits que corresponde a la cantidad de veces que se presiona el botón de test y va a definir a cual de los estados del tamagotchi se va a entrar.

```verilog
module FSM_Central#(parameter COUNT_MAX = 25000 , Ener = 1500000000, Feed = 500000000, Entert= 1000000000, CONTUNI = 10000000000)( //30s , 10s , 20s
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
	output reg [3:0] face,
	output reg [2:0] energy,
	output reg [2:0] hunger,
	output reg [2:0] entertainment,
	output wire [3:0] led4
	);
```

Adicionalmente hay algunos parámetros los cuales se usarán para definir el tiempo que se van a tardar los indicadores en subir o baja. En este caso, se manejan como múltiplos de 50MHz. Ya que el clock de la FPGA es de 50MHz. El indicador de la energía va a bajar cada 30 segundos en un punto, si está durmiendo va a subir en 1 cada 30 segundos. El indicador de comida va a bajar en un punto cada 10 segundos y el indicador de diversión va a bajar en un punto cada 20 segundos. El indicador de comida sube cada que le llega un uno en la señal de botonFeed, y el indicador de comida sube en 1 si se mantiene jugando por 2o segundos.

**Definición de regisotros, contadores y parámetros iniciales**

En el siguiente fragmento de código se pueden apreciar los estados de la maquina de estados que se usará, de manera parametrizada, además se muestran los registros de state y next los cuales se usaran para manejar el cambio de estados de la FSM. Luego se definen los registros correspondientes a los contadores, cuyo tamaño se encuentra parametrizado de acorde a los parámetros de entrada al módulo que se mostraron anteriormente. En este caso es posible observar que hay un contador para controlar cada indicador del tamagotchi. Posteriormente se hace una asignación de la salida led4 la cual es una ayuda visual que se usó para depurar el código ya que mostraba el estado actual de tamagotchi en unos leds de la FPGA.

Finalmente se puede apreciar que se crea un initial begin para definir los valors iniciales de algunos registros.


``` verilog
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
	reg [3:0] state;
	reg [3:0] next;
	reg clkms;
	reg [$clog2(COUNT_MAX)-1:0] counter;
	//reg [$clog2(CONTUNI)-1:0] contTime;
	reg [$clog2(CONTUNI)-1:0] contTimeEnergy, contTimeHunger, contTimeEntertainment;
	assign led4 =state;
	//Valores de Inicio
	initial begin
		state <= IDLE;
		face <= state;
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
	
		//Reset de la máquina de estados
		
	always @(posedge clk) begin
		if (state != TEST) begin
			face <= state;
		end 
	end
```

**Divisor de Frecuencia**

En este fragmento de código se puede apreciar el divisor de frecuencia usado para pasar del reloj de la FPGA de 50MHz a un reloj den con periodo de 1ms.

``` verilog
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
	
```

**Always que gestiona el cambio de estados del tamagotchi**

Este fragmento de código es un always que se ejecuta cada que hay un cambio de alguna señales presentes en el módulo. Este always se encarga exclusivamente de gestionar el cambio de estados de la máquina de estados, a partir de el cumplimiento de algunas condiciones. En este caso, el tamagotchi cambia de estados según el valor en el que se encuentren los tres indicadores (hunger, energy y entertainment). Además de esto, los botones afectan también el estado en el que se encuentra el tamagotchi ya que algunos botones pueden forzar que el tamagotchi entre a algún estado en particular.

``` verilog
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
						end else if(hunger == 3'd5 && energy == 3'd5 && entertainment == 3'd5) begin
							next = IDLE;
						end else begin
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
						end else if ((energy >= 3'd3 && energy < 3'd5) && (hunger >= 3'd3 && hunger < 3'd5) && (entertainment >= 3'd3 && entertainment < 3'd5)) begin
							next = NEUTRAL;
						end
					end else if(botonTest) begin
                     next = TEST;
                end else if (energy == 3'd5 && hunger == 3'd5 && entertainment == 3'd5) begin
						next = IDLE;
					end else if (entertainment == 3'd5) begin
						next = NEUTRAL;
					end else begin
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
						end else if ((energy >= 3'd3 && energy < 3'd5) && (hunger >= 3'd3 && hunger < 3'd5) && (entertainment >= 3'd3 && entertainment < 3'd5)) begin
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
```

**Control de Incremento y decremento de indicadores**

A continuación se muestra el fragmento de código encargado de aumentar y disminuir cada indicador cada vez que se llene el contador correspondiente. Adicionalmente se maneja el caso en el que entra en el estado TEST y se evalúa a cual estado del tamagotchi se quiere entrar de manera forzada. Esto hace que se fije un valor de energy, entertainment, y hunger, omitiendo el valor en el que se encontraba antes.


```verilog
// Incrementador y disminuidor de energía
always @(posedge clk or posedge rst) begin
    if (rst) begin
        energy <= 3'd5;
        contTimeEnergy <= 0;
    end else begin
        if (next == TEST) begin
				//contTimeEnergy <= 0;
            case (BpulseTest)
                4'd1: energy <= 3'd5; //IDLE
                4'd2: energy <= 3'd4; //NEUTRAL
                4'd3: energy <= 3'd2; //TIRED
                4'd4: energy <= 3'd2; //SLEEP
                4'd5: energy <= 3'd5; //HUNGRY
                4'd6: energy <= 3'd2; //SAD
                4'd7: energy <= 3'd5; //PLAYING
                4'd8: energy <= 3'd5; //BORED
                4'd9: energy <= 3'd0; //DEATH
            endcase
            contTimeEnergy <= 0;
        end else if ((next == SLEEP) && (next != TEST) && (energy < 3'd5) && (contTimeEnergy == Ener-1)) begin
            energy <= energy + 1;
            contTimeEnergy <= 0;
        end else if ((next != DEATH) && (next != TEST) && (energy > 0)) begin
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
always @(posedge clk or posedge rst) begin
    if (rst) begin
        hunger <= 3'd5;
        contTimeHunger <= 0;
    end else begin
        if (next == TEST) begin
				//contTimeHunger <= 0;
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
        end else if (botonFeed && (hunger < 3'd5) && (next != TEST)) begin
            hunger <= hunger + 1;
            contTimeHunger <= 0;
        end else if ((next != DEATH) && (next != TEST) && (hunger > 0) && (next != SLEEP)) begin
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
always @(posedge clk or posedge rst) begin
    if (rst) begin
        entertainment <= 3'd5;
        contTimeEntertainment <= 0;
    end else begin
        if (next == TEST) begin
				//contTimeEntertainment <= 0;
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
        end else if ((next == PLAYING) && (next != TEST) && (entertainment < 3'd5) && (contTimeEntertainment == Entert-1)) begin
            entertainment <= entertainment + 1;
            contTimeEntertainment <= 0;
        end else if ((next != DEATH) && (next != TEST) && (entertainment > 0) && (next != SLEEP)) begin
            if (contTimeEntertainment == Entert-1) begin
                entertainment <= entertainment - 1;
                contTimeEntertainment <= 0;
            end else begin
                contTimeEntertainment <= contTimeEntertainment + 1;
            end
        end
    end
end

endmodule
```
Con lo anterior se resume la funcionalidad del código [FSM_Central.v](./ProyectoQuartus/src/UnidadDeControl/FSM_Central.v) parte por parte y de manera detallada.