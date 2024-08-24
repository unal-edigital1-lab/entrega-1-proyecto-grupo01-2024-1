module lcd1602_cust_char #(parameter num_commands = 3, // Número de comandos de configuración
                                    lcd_row_size = 2, // Número de filas de la lcd que ocupa el custom character
                                    lcd_column_size = 3, // Número de columnas de la lcd que ocupa el custom character
                                    quantity_custom_char = 9, // Cantidad de custom characters
                                    char_row_size = 8, // Número de filas de un bloque (caracter) de la lcd
                                    initial_LCD_addrs = 8'h82, // Dirección inicial de la LCD
                                    path_file = "caras.txt",
                                    COUNT_MAX = 800000)(
    input clk,            
    input reset,
    input [$clog2(quantity_custom_char)-1:0] num_cust_char,          
    output reg rs,        
    output reg rw,
    output enable,    
    output reg [7:0] data
);

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

// Maquina de estados
reg [3:0] fsm_state = IDLE;
reg [3:0] next;

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


// flags para cambiar de estado
reg init_config_executed= 1'b0;
reg done_cgram_write = 1'b0;
reg done_lcd_write = 1'b0;
reg [1:0] create_char_task = SET_CGRAM_ADDR;
reg new_paint = 1'b0;
reg [$clog2(quantity_custom_char) - 1 : 0] last_value_done = 'b0;
reg [$clog2(quantity_custom_char) - 1 : 0] previus_value = 'b0;
reg [$clog2(quantity_custom_char) - 1 : 0] actual_value = 'b0;

// Divisor de frecuencia
reg clk_16ms = 'b0;
reg [$clog2(COUNT_MAX)-1:0] counter_div_freq = 'b0; // Contador para el divisor de frecuencia


localparam num_cgram_addrs = lcd_row_size*lcd_column_size; // Número de direcciones de la CGRAM que se van a utilizar
localparam one_custom_char_size = lcd_row_size*lcd_column_size*char_row_size; // tamaño del custom character,  cara


// Banco de registros
reg [7:0] config_memory [0 : num_commands-1]; // almacenamiento de los (3) comandos que se envian para la configuración inicial

reg [7:0] data_memory [0 : (one_custom_char_size*quantity_custom_char)-1]; // data para pintar cada cara, 48 bytes x cara 

reg [7:0] cgram_addrs [0 : (num_cgram_addrs)-1]; // 6 cgram_addrs x cara 

// Contadores
reg [$clog2(num_commands):0] command_counter = 'b0; // contador para controlar el envío de comandos
reg [$clog2(one_custom_char_size):0] data_counter = 'b0; // contador para controlar el envío de cada dato
reg [$clog2(char_row_size):0] char_counter = 'b0; // contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter = 'b0; // contador para controlar el envío de comandos

integer i;

initial begin
   data <= 'b0;
   rw <= 0;
   rs <= 0;
   $readmemb({"C:/Users/Maria Alejandra/Documents/ElectronicaDigital/TAMAGOCHI/QUARTUS/QuartusLCD/TXT/", path_file}, data_memory);

   config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
   config_memory[1] <= DISPON_CURSOROFF;
   config_memory[2] <= CLEAR_DISPLAY;

   // Direcciones de escritura de la CGRAM 
   cgram_addrs[0] = 8'h40;
    $display("cgram_addrs[%d] = %h", 0, cgram_addrs[0]);
   for (i = 1; i < num_cgram_addrs; i = i + 1)begin
        cgram_addrs[i] = cgram_addrs[i-1] + 8'h08;
        $display("cgram_addrs[%d] = %h", i, cgram_addrs[i]);
   end
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
        previus_value <= 0;
        actual_value <= 0;
    end else if (actual_value != num_cust_char) begin
        previus_value <= actual_value;
        actual_value <= num_cust_char;
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
            next <= (new_paint)? IDLE : CHECK_ACTUAL_STATE;
        end
        default: next = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
		init_config_executed <= 'b0;
		data <= 'b0;
		rs <= 'b0;
        last_value_done <= 'b0; // reset record
		
    end else begin
        case (next)
            IDLE: begin
                done_lcd_write <= 1'b0; // reset flag to change state
                done_cgram_write <= 1'b0; // reset flag to change state
                new_paint <= 1'b0; // reset flag to change state
                char_counter <= 'b0; // reset counter
                data_counter <= 'b0; // reset counter
                cgram_addrs_counter <= 'b0; // reset counter
                if (init_config_executed) begin
                    create_char_task <= SET_CGRAM_ADDR; // assigns task before go to CREATE_CHARS
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
                        rs <= 'b0; data <= cgram_addrs[cgram_addrs_counter];  // se envía la dirección de la CGRAM a escribir
                        create_char_task <= WRITE_CHARS; 
                    end
                    WRITE_CHARS: begin
                        rs <= 1; // se escribe un byte en la CGRAM
                        data <= data_memory[one_custom_char_size*num_cust_char + data_counter];
                        data_counter <= data_counter + 1; // se pasa al siguiente byte
                        
                        if(char_counter == char_row_size -1) begin // si se completo la escritura de un caracter (un bloque 8x5)
                            char_counter = 0;
                            cgram_addrs_counter <= cgram_addrs_counter + 1; // se pasa a la siguiente dirección de la CGRAM
                            create_char_task <= SET_CGRAM_ADDR;
                        end else begin
                            char_counter <= char_counter +1;
                        end

                        if (data_counter == one_custom_char_size-1)
                            done_cgram_write = 1'b1; // se terminó de escribir en la CGRAM el custom character
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
                        rs <= 0; data <= (cgram_addrs_counter > (lcd_column_size - 1 ))? initial_LCD_addrs + (cgram_addrs_counter%lcd_column_size) + 8'h40 : initial_LCD_addrs + (cgram_addrs_counter%lcd_column_size);
                        create_char_task <= WRITE_LCD; 
                    end
					WRITE_LCD: begin
                        rs <= 1; data <=  8'h00 + cgram_addrs_counter;
                        if(cgram_addrs_counter == num_cgram_addrs-1)begin
                            cgram_addrs_counter <= 'b0;
                            done_lcd_write <= 1'b1; // se terminó de pintar en la lcd el custom character
                            last_value_done <= actual_value;  
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
                if ((last_value_done != actual_value) && (actual_value != previus_value)) begin
                    new_paint <= 1'b1;
                end
            end
        endcase
    end
end

assign enable = clk_16ms;

endmodule
