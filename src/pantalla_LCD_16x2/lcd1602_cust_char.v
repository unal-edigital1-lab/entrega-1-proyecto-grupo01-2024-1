module lcd1602_cust_char_v2 #(parameter num_commands = 3, 
                                      num_data_all = 48,  
                                      row_char_data = 8, 
                                      num_cgram_addrs = 6,
                                      num_states = 4,
                                      COUNT_MAX = 800000)(
    input clk,            
    input reset,
    input [1:0] state,          
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
);

// Definición de los estados del controlador
localparam IDLE = 0;
localparam INIT_CONFIG = 1;
localparam CREATE_CHARS = 2;
localparam CLEAR_COUNTERS1 = 3;
localparam SET_CURSOR_AND_WRITE = 4;
localparam CHECK_ACTUAL_STATE = 5;

localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;
localparam CHANGE_LINE = 4;

// Maquina de estados
reg [3:0] fsm_state = IDLE;
reg [3:0] next;

// flags para cambiar de estado
reg init_config_executed= 1'b0;
reg done_cgram_write = 1'b0;
reg done_lcd_write = 1'b0;
reg [1:0] create_char_task = SET_CGRAM_ADDR;
reg new_state = 1'b0;
reg [$clog2(num_states) - 1 : 0] last_state_done = 'b0;
reg [$clog2(num_states) - 1 : 0] previus_state = 'b0;
reg [$clog2(num_states) - 1 : 0] actual_state = 'b0;

// Divisor de frecuencia
reg clk_16ms = 'b0;
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq = 'b0; // Contador para el divisor de frecuencia

// Comandos de configuración
localparam CLEAR_DISPLAY = 8'h01;
localparam SHIFT_CURSOR_RIGHT = 8'h06;
localparam DISPON_CURSOROFF = 8'h0C;
localparam DISPON_CURSORBLINK = 8'h0E;
localparam LINES2_MATRIX5x8_MODE8bit = 8'h38;
localparam LINES2_MATRIX5x8_MODE4bit = 8'h28;
localparam LINES1_MATRIX5x8_MODE8bit = 8'h30;
localparam LINES1_MATRIX5x8_MODE4bit = 8'h20;
localparam START_2LINE = 8'hC0;

// Direcciones de escritura de la CGRAM 
localparam CGRAM_ADDR0 = 8'h40;
localparam CGRAM_ADDR1 = 8'h48;
localparam CGRAM_ADDR2 = 8'h50;
localparam CGRAM_ADDR3 = 8'h58;
localparam CGRAM_ADDR4 = 8'h60;
localparam CGRAM_ADDR5 = 8'h68;
localparam CGRAM_ADDR6 = 8'h70;

// Banco de registros
reg [7:0] config_memory [0 : num_commands-1]; // almacenamiento de los (3) comandos que se envian para la configuración inicial

reg [7:0] data_memory [0 : (num_data_all*num_states)-1]; // data para pintar cada cara, 48 bytes x cara 

reg [7:0] cgram_addrs [0 : (num_cgram_addrs)-1]; // 6 cgram_addrs x cara 

// Contadores
reg [$clog2(num_commands):0] command_counter = 'b0; // contador para controlar el envío de comandos
reg [$clog2(num_data_all):0] data_counter = 'b0; // contador para controlar el envío de cada dato
reg [$clog2(row_char_data):0] char_counter = 'b0; // contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter = 'b0; // contador para controlar el envío de comandos


initial begin
   data <= 'b0;
   rw <= 0;
   rs <= 0;
   $readmemb("C:/Users/Maria Alejandra/Documents/ElectronicaDigital/TAMAGOCHI/QuartusLCD/caras.txt", data_memory);

   config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
   config_memory[1] <= DISPON_CURSOROFF;
   config_memory[2] <= CLEAR_DISPLAY;

   cgram_addrs[0] <= CGRAM_ADDR0;
   cgram_addrs[1] <= CGRAM_ADDR1;
   cgram_addrs[2] <= CGRAM_ADDR2;
   cgram_addrs[3] <= CGRAM_ADDR3;
   cgram_addrs[4] <= CGRAM_ADDR4;
   cgram_addrs[5] <= CGRAM_ADDR5;
end

always @(posedge clk) begin
    if (counter_div_freq == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter_div_freq <= 0;
    end else begin
        counter_div_freq <= counter_div_freq + 1;
    end
end

always @(posedge clk) begin
    if (reset == 0) begin
        previus_state <= 0;
        actual_state <= 0;
    end else if (actual_state != state) begin
        previus_state <= actual_state;
        actual_state <= state;
    end
end

always @(posedge clk_16ms)begin
    if(reset == 0)begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next;
    end
end

always @(*) begin
    case(fsm_state)
        IDLE: begin
            next <= (init_config_executed)? CREATE_CHARS : INIT_CONFIG;
        end
        INIT_CONFIG: begin 
            next <= (init_config_executed)? CREATE_CHARS : INIT_CONFIG;
        end
        CREATE_CHARS: begin
            next <= (done_cgram_write)? CLEAR_COUNTERS1 : CREATE_CHARS;
        end
        CLEAR_COUNTERS1: begin
            next <= SET_CURSOR_AND_WRITE;
        end
        SET_CURSOR_AND_WRITE: begin 
            next <= (done_lcd_write)? CHECK_ACTUAL_STATE : SET_CURSOR_AND_WRITE;
        end
        CHECK_ACTUAL_STATE: begin
            next <= (new_state)? IDLE : CHECK_ACTUAL_STATE;
        end
        default: next = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
		init_config_executed <= 'b0;
		done_cgram_write <= 1'b0;
		done_lcd_write <= 1'b0; 
		data <= 'b0;
		rs <= 'b0;
        last_state_done <= 'b0;
		$readmemb("C:/Users/Maria Alejandra/Documents/ElectronicaDigital/TAMAGOCHI/QuartusLCD/caras.txt", data_memory);
    end else begin
        case (next)
            IDLE: begin
                done_lcd_write <= 1'b0;
                done_cgram_write <= 1'b0;
                new_state <= 1'b0;
                char_counter <= 'b0;
                data_counter <= 'b0;
                cgram_addrs_counter <= 'b0;
                if (init_config_executed) begin
                    create_char_task <= SET_CGRAM_ADDR;
                end else begin
                    command_counter <= 'b0; // Reset counter before go to INIT_CONFIG
                end
            end
            INIT_CONFIG: begin
                rs <= 'b0;
                command_counter <= command_counter + 1;
					 data <= config_memory[command_counter];
                if (command_counter == num_commands - 1) begin
                    create_char_task <= SET_CGRAM_ADDR;
                    init_config_executed <= 1'b1;
                end
            end
            CREATE_CHARS: begin
                case(create_char_task)
                    SET_CGRAM_ADDR: begin 
                        rs <= 'b0; data <= cgram_addrs[cgram_addrs_counter]; 
                        create_char_task <= WRITE_CHARS; 
                    end
                    WRITE_CHARS: begin
                        rs <= 1; data <= data_memory[num_data_all*actual_state + data_counter];
                        data_counter <= data_counter + 1;
                        if(char_counter == row_char_data -1) begin
                            char_counter = 0;
                            create_char_task <= SET_CGRAM_ADDR;
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end else begin
                            char_counter <= char_counter +1;
                        end

                        if (data_counter == num_data_all-1)
                            done_cgram_write = 1'b1;
                    end
                endcase
            end
            CLEAR_COUNTERS1: begin
                data_counter <= 'b0;
                char_counter <= 'b0;
                create_char_task <= SET_CURSOR;
                cgram_addrs_counter <= 'b0;
            end
            SET_CURSOR_AND_WRITE: begin
				case(create_char_task)
					SET_CURSOR: begin
                        rs <= 0; data <= (cgram_addrs_counter > 2)? 8'h80 + (cgram_addrs_counter%3) + 8'h40 : 8'h80 + (cgram_addrs_counter%3);
                        create_char_task <= WRITE_LCD; 
                    end
					WRITE_LCD: begin
                        rs <= 1; data <=  8'h00 + cgram_addrs_counter;
                        if(cgram_addrs_counter == num_cgram_addrs-1)begin
                            cgram_addrs_counter = 'b0;
                            done_lcd_write <= 1'b1;
                            last_state_done <= actual_state;
                        end else begin
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end
                        create_char_task <= SET_CURSOR; 
                    end
                endcase
            end
            CHECK_ACTUAL_STATE: begin
                rs <= 'b0;
                data <= 'b0;
                if ((last_state_done != actual_state) && (actual_state != previus_state)) begin
                    new_state <= 1'b1;
                end
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule
