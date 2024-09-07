module lcd1602_cust_char #(parameter lcd_row_size = 2, // Número de filas de la lcd que ocupa el custom character
                                    lcd_column_size = 3, // Número de columnas de la lcd que ocupa el custom character
                                    quantity_custom_char = 9, // Cantidad de custom characters
                                    char_row_size = 8, // Número de filas de un bloque (caracter) de la lcd
                                    initial_LCD_addrs = 8'h80, // Dirección inicial de la LCD
                                    path_file = "caras.txt")(
    input clk,            
    input reset,
    input [$clog2(quantity_custom_char)-1:0] num_cust_char,
    input start_painting,
    output lcd_available,
    input clk_16ms,          
    output reg rs,        
    output reg rw,    
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
reg [2:0] fsm_state = IDLE;
reg [2:0] next;

// Definición de los estados del controlador
localparam IDLE = 0;
localparam CREATE_CHARS = 1;
localparam CLEAR_COUNTERS1 = 2;
localparam SET_CURSOR_AND_WRITE = 3;


localparam SET_CGRAM_ADDR = 0;
localparam WRITE_CHARS = 1;
localparam SET_CURSOR = 2;
localparam WRITE_LCD = 3;
localparam CHANGE_LINE = 4;


// flags para cambiar de estado
reg done_cgram_write = 1'b0;
reg done_lcd_write = 1'b0;
reg [1:0] create_char_task = SET_CGRAM_ADDR;


localparam num_cgram_addrs = lcd_row_size*lcd_column_size; // Número de direcciones de la CGRAM que se van a utilizar
localparam one_custom_char_size = lcd_row_size*lcd_column_size*char_row_size; // tamaño del custom character,  cara

// Banco de registros
reg [7:0] data_memory [0 : (one_custom_char_size*quantity_custom_char)-1]; // data para pintar cada cara, 48 bytes x cara 
reg [7:0] cgram_addrs [0 : (num_cgram_addrs)-1]; // 6 cgram_addrs x cara 

// Contadoresreg [$clog2(one_custom_char_size):0] data_counter = 'b0; // contador para controlar el envío de cada dato
reg [$clog2(one_custom_char_size):0] data_counter = 'b0; // contador para controlar el envío de cada dato
reg [$clog2(char_row_size):0] char_counter = 'b0; // contador para controlar el envío de caracteres a la CGRAM
reg [$clog2(num_cgram_addrs):0] cgram_addrs_counter = 'b0; // contador para controlar el envío de comandos

integer i;

initial begin
   data <= 'b0;
   rw <= 0;
   rs <= 0;
   $readmemb({"C:/Users/Maria Alejandra/Documents/ElectronicaDigital/TAMAGOCHI/QUARTUS/QuartusLCD/TXT/", path_file}, data_memory);

   // Direcciones de escritura de la CGRAM 
   cgram_addrs[0] = 8'h40;
    $display("cgram_addrs[%d] = %h", 0, cgram_addrs[0]);
   for (i = 1; i < num_cgram_addrs; i = i + 1)begin
        cgram_addrs[i] = cgram_addrs[i-1] + 8'h08;
        $display("cgram_addrs[%d] = %h", i, cgram_addrs[i]);
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
            next <= (start_painting)? CREATE_CHARS : IDLE;
        end
        CREATE_CHARS: begin
            next <= (done_cgram_write)? CLEAR_COUNTERS1 : CREATE_CHARS;
        end
        CLEAR_COUNTERS1: begin
            next <= SET_CURSOR_AND_WRITE;
        end
        SET_CURSOR_AND_WRITE: begin 
            next <= (done_lcd_write)? IDLE : SET_CURSOR_AND_WRITE;
        end
        default: next = IDLE;
    endcase
end

always @(posedge clk_16ms) begin
    if (reset == 0) begin
		data <= 'b0;
		rs <= 'b0;
    end else begin
        case (next)
            IDLE: begin
                done_lcd_write <= 1'b0; // reset flag to change state
                done_cgram_write <= 1'b0; // reset flag to change state
                char_counter <= 'b0; // reset counter
                data_counter <= 'b0; // reset counter
                cgram_addrs_counter <= 'b0; // reset counter
                data <= 'b0; // reset data
                rs <= 'b0; // reset rs
                create_char_task <= SET_CGRAM_ADDR; // reset task
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
                        end else begin
                            cgram_addrs_counter <= cgram_addrs_counter + 1;
                        end
                        create_char_task <= SET_CURSOR; 
                    end
                endcase
            end

        endcase
    end
end

assign lcd_available = (fsm_state == IDLE)? 1'b1 : 1'b0;

endmodule
