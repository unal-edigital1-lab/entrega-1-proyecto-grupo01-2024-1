module ultrasonido (
    input wire clk,         // Clock de sistema (50 MHz)
    input wire reset_n,     // Reset asincrónico (activo bajo)
    input wire echo,        // Señal de eco del ultrasonido
    input wire boton,
    output reg led,          // LED de salida
    output reg trigger
);


localparam V_SONIDO = 34300; // Velocidad del sonido en el aire a 20°C en metros por segundo
localparam DIVISOR = 100;
localparam DISTANCIA_MINIMA = 50; // Distancia mínima en centímetros (1 metro = 100 cm)
// Período del clock en usegundos (50 MHz) 2*10⁻8
//distancia_cm <= (cuenta_echo+1) * T_CLK * (V_SONIDO/2); // multiplicado por 100 para convertir a centímetros
// 50 --> 146000
//100 --> 292000
// 25 --> 73000
// 10 --> 30000
//450 --> 1314000

reg [21:0] cuenta_echo;     // Contador para medir el tiempo de eco
reg [21:0] max_echo;
reg [9:0] count;
reg [$clog2(50000000)-1:0] counteat;
reg act;



// FSM
reg [3:0] estado, next_estado; 
// Estados de la máquina de estados
localparam IDLE = 3'd0;
localparam START = 3'd1;
localparam WAIT_FOR_ECHO = 3'd2;
localparam MEASURE_DISTANCE = 3'd3;
localparam OPERATION = 3'd4;


initial begin
		estado <= IDLE;
		next_estado <= IDLE;
        //contador <= 0;
        cuenta_echo <= 0;
        act <= 1;
        counteat <= 0;
        count <= 0;
	end

// Máquina de estados
always @(posedge clk) begin
    if (reset_n==0) begin
        estado <= IDLE;
    end else begin
        estado <= next_estado;
    end
end



// Lógica de la máquina de estados
always @(*) begin
    case (estado)
        IDLE: begin
            if (boton == 1) begin
                next_estado = START;
            end else begin
                next_estado = IDLE;
            end
        end
        START: begin
            if (count == 499) begin // 499 en escenario fisico
                next_estado = WAIT_FOR_ECHO;
            end else begin
                next_estado = START;
            end
        end  
        WAIT_FOR_ECHO: begin
            if (echo) begin
                next_estado = MEASURE_DISTANCE;
                
            end else if (max_echo >= 900000) begin
                next_estado = IDLE;
            end else begin
                next_estado = WAIT_FOR_ECHO;
            end
        end
        MEASURE_DISTANCE: begin
            if (!echo) begin
                next_estado = OPERATION;
                // Calcular distancia en centímetros
            end else begin
                next_estado = MEASURE_DISTANCE;
            end
        end
        OPERATION : begin
            if (count >= 10) begin
                next_estado = IDLE;
            end else begin
                next_estado = OPERATION;
            end 
        end

        default: next_estado = IDLE;
    endcase
end


// Definición de la máquina de estados

always @(posedge clk) begin
    if (reset_n==0) begin 
        cuenta_echo <= 0;
        act <= 1;
        counteat <= 0;
        count <= 0;
    end else begin
        case(estado)
            IDLE: begin
                count <= 0;
                cuenta_echo <= 0;
            end

            START: begin
                
                trigger = 1;
                count = count + 1;
                max_echo = 0;
            end
            WAIT_FOR_ECHO: begin  
                //distancia_cm = 0;
                trigger = 0;
                count = 0;
                max_echo = max_echo +1;
            end

            MEASURE_DISTANCE: begin
                
                cuenta_echo <= cuenta_echo + 1;
                
            end

            OPERATION: begin
                count = count + 1;
                 // multiplicado por 100 para convertir a centímetros
		    if (cuenta_echo >= 30000) begin
                        act = 1'b1; //lejos
                    end else begin
                        act = 1'b0; //no lejose
                    end                          
            end

            

            
    endcase

    end
end

//logica de un segundo

always @(posedge clk) begin
    if (act==0) begin
        counteat=counteat+1;
    end else begin
        counteat=0;
    end
	if (counteat == 50000000) begin
        led = 1;
    end else begin
        led = 0;
    end
end




endmodule
