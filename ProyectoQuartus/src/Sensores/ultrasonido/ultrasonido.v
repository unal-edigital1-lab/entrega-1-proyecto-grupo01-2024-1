module ultrasonido (
    input wire clk,         // Clock de sistema (50 MHz)
    input wire reset_n,     // Reset asincrónico (activo bajo)
    input wire echo,        // Señal de eco del ultrasonido
    input wire boton,
    output reg led,          // LED de salida
    output reg trigger
);


localparam DISTANCIA_MINIMA = 50; // Distancia mínima en centímetros (1 metro = 100 cm)
//localparam T_CLK =  20 * 0.00000002; // Período del clock en usegundos (50 MHz)
localparam T_CLK =  2; // Período del clock en usegundos (50 kHz)


reg [15:0] cuenta_echo;     // Contador para medir el tiempo de eco
reg [15:0] distancia_cm;    // Distancia calculada en centímetros
reg [3:0] estado, next_estado; 
reg clk_out; // Estados actuales y próximos


localparam V_SONIDO = 34300; // Velocidad del sonido en el aire a 20°C en metros por segundo
localparam DIVISOR = 100;

// Definición de la máquina de estados
localparam IDLE = 3'd0;
localparam START = 3'd1;
localparam WAIT_FOR_ECHO = 3'd2;
localparam MEASURE_DISTANCE = 3'd3;
localparam OPERATION = 3'd4;
reg [9:0] contador;

initial begin
		estado <= IDLE;
		next_estado <= IDLE;
        contador <= 0;
        cuenta_echo <= 0;
	end

// Máquina de estados
always @(posedge clk) begin
    if (reset_n==0) begin
        estado <= IDLE;
    end else begin
        estado <= next_estado;
    end
end

reg [9:0] count;

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

// Divisor de frecuencia

always @(posedge clk) begin
        if (reset_n==0) begin
            contador <= 0;
            clk_out <= 0;
        end else begin
            if (contador == (DIVISOR - 1)) begin
                clk_out <= ~clk_out; // Alternar el estado del reloj de salida
                contador <= 0;
            end else begin
                contador <= contador + 1;
            end
        end
end;

// Definición de la máquina de estados
localparam IDLE = 3'd0;

always @(posedge clk) begin
    if (reset_n==0) begin 
        count <= 0;
    end else begin
        case(estado)
            IDLE: begin
                count <= 0;
            end

            START: begin
                
                trigger = 1;
                count = count + 1;

            end
               
            WAIT_FOR_ECHO: begin  
                distancia_cm = 0;
                trigger = 0;
                count = 0;
            end

            OPERATION: begin
                count = count + 1;
                 // multiplicado por 100 para convertir a centímetros
                    if (cuenta_echo >= 1000) begin
                        led = 1'b1;
                    end else begin
                        led = 1'b0;
                    end                          
            end

            
    endcase

    end
end

always @(posedge clk_out) begin
    if (estado == MEASURE_DISTANCE) begin
        cuenta_echo <= cuenta_echo + 1;
    end else if (estado==START)begin
		cuenta_echo <= 0;
	end
end



// Lógica para controlar el LED
/*always @(posedge clk or posedge reset_n) begin
    distancia_cm <= (cuenta_echo+1) * T_CLK * (V_SONIDO/2); // multiplicado por 100 para convertir a centímetros
    if (distancia_cm >= DISTANCIA_MINIMA) begin
        led = 1'b0;
    end else begin
        led = 1'b1;
    end
end*/

// Contador para medir el eco
/*always @(posedge clk or posedge reset_n) begin
    if (reset_n) begin
        cuenta_echo <= 16'd0;
    end
end*/

endmodule
