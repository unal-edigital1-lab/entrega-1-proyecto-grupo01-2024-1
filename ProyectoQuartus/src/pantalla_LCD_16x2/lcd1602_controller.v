`include "lcd1602_cust_char.v"

module LCD1602_CONTROLLER #(parameter MAX_VALUE = 5, num_config_commands = 4, NUM_FACES = 9, COUNT_MAX = 800000)(
    input clk,   
    input reset,
    input [$clog2(NUM_FACES)-1:0] face,   
    input [$clog2(MAX_VALUE):0] feed_value,
    input [$clog2(MAX_VALUE):0] joy_value,
    input [$clog2(MAX_VALUE):0] energy_value,
    output rs,  
    output rw,
    output enable,
    output [7:0] data
);

reg [10: 0] counter = 0;

reg rs_reg = 0;
reg [7:0] data_reg = 0;

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


// Divisor de frecuencia
reg clk_16ms = 0;
reg [$clog2(COUNT_MAX)-1:0] counter_clk = 0;


//FSM
reg [2:0] fsm_state = 0;
reg [2:0] next = 0;

// Definir los estados del controlador
localparam IDLE = 0;
localparam INIT_CONFIG = 1;
localparam INITIAL_PAINT_CARA = 2;
localparam INITIAL_PAINT_TEXT = 3;
localparam INITIAL_PAINT_VALUES = 4;
localparam PAINT_VALUES = 5;
localparam PAINT_CARA = 6;
localparam WAIT = 7;

reg [1:0] set_task = 0;

localparam SENT_CARITA = 0;
localparam START_PAINT = 1;
localparam PAINTING = 2;

localparam FEED_VALUE_PAINT = 0;
localparam JOY_VALUE_PAINT = 1;
localparam ENERGY_VALUE_PAINT = 2;



//flags 
reg init_config_executed = 0;
reg initial_paint_text_done = 0;
reg initial_paint_values_done = 0;
reg initial_paint_cara_done = 0;
reg carita_executed = 0;
reg values_executed = 0;
reg painting_caras = 0;

localparam FEED_VALUE = 0;
localparam JOY_VALUE = 1;
localparam ENERGY_VALUE = 2;
localparam FEED_TEXT = 3;
localparam JOY_TEXT = 4;
localparam ENERGY_TEXT = 5;


//Banco de registros para las cadenas de texto
reg [7:0] string_feed[0: 3];
reg [7:0] string_joy[0: 2];
reg [7:0] string_energy[0: 5];
reg [7:0] string_numbers[0: 5];
reg [8:0] initial_lcd_address [0:5];


// Contadores
reg [$clog2(num_config_commands):0] config_command_counter  = 0;// Contador para controlar el envío de comandos
reg [$clog2(16):0] counter_data = 0; // Contador para controlar el envío de datos


// Banco de registros
reg [7:0] config_memory [0: num_config_commands-1]; 


initial begin
    string_feed[0] = "F";
    string_feed[1] = "O";
    string_feed[2] = "O";
    string_feed[3] = "D";

    string_joy[0] = "J";
    string_joy[1] = "O";
    string_joy[2] = "Y";

    string_energy[0] = "E";
    string_energy[1] = "N";
    string_energy[2] = "E";
    string_energy[3] = "R";
    string_energy[4] = "G";
    string_energy[5] = "Y";

    string_numbers[0] = "0";
    string_numbers[1] = "1";
    string_numbers[2] = "2";
    string_numbers[3] = "3";
    string_numbers[4] = "4";
    string_numbers[5] = "5";

    initial_lcd_address[FEED_TEXT] = 8'h84;
    initial_lcd_address[JOY_TEXT] = 8'h8B;
    initial_lcd_address[ENERGY_TEXT] = 8'hC4;
    initial_lcd_address[FEED_VALUE] = 8'h89;
    initial_lcd_address[JOY_VALUE] = 8'h8F;
    initial_lcd_address[ENERGY_VALUE] = 8'hCB;

	config_memory[0] <= LINES2_MATRIX5x8_MODE8bit;
	config_memory[1] <= SHIFT_CURSOR_RIGHT;
	config_memory[2] <= DISPON_CURSOROFF;
	config_memory[3] <= CLEAR_DISPLAY;

    $display(string_energy[0], string_energy[1], string_energy[2], string_energy[3], string_energy[4], string_energy[5]);
    $display(string_feed[0], string_feed[1], string_feed[2], string_feed[3]);
    $display(string_joy[0], string_joy[1], string_joy[2]);
end

// Inputs de lcd1602_cust_char para las caras
reg start_painting_cara = 1'b0;
reg [$clog2(NUM_FACES) - 1: 0] num_cust_char = 0;
// Outputs de lcd1602_cust_char para las caras
wire rs_wire;
wire rw_wire;
wire [7:0] data_wire;
wire lcd_available_cara;

// Instancia de lcd1602_cust_char
lcd1602_cust_char #(
    .quantity_custom_char(NUM_FACES)
) lcd_caras (
    .clk(clk),
    .reset(reset),
    .num_cust_char(num_cust_char),
    .start_painting(start_painting_cara),
    .lcd_available(lcd_available_cara),
    .rs(rs_wire),
    .rw(rw_wire),
    .clk_16ms(clk_16ms),
    .data(data_wire)
);


//DIVISOR DE FRECUENCIA
always @(posedge clk) begin
    if (counter_clk == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        counter_clk <= 0;
    end else begin
        counter_clk <= counter_clk + 1;
    end
end

// MAQUINA DE ESTADOS
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
            next <= (init_config_executed) ? INITIAL_PAINT_TEXT : INIT_CONFIG;
        end
        INIT_CONFIG: begin 
            next <= (init_config_executed)? INITIAL_PAINT_CARA : INIT_CONFIG;
        end
        INITIAL_PAINT_CARA: begin
            next <= (initial_paint_cara_done)? INITIAL_PAINT_TEXT : INITIAL_PAINT_CARA;
        end
        INITIAL_PAINT_TEXT: begin
            next <= (initial_paint_text_done)? INITIAL_PAINT_VALUES : INITIAL_PAINT_TEXT;
        end
        INITIAL_PAINT_VALUES: begin
            next <= (initial_paint_values_done)? PAINT_VALUES : INITIAL_PAINT_VALUES;
        end
        PAINT_VALUES: begin
            next <= (values_executed)? PAINT_CARA : PAINT_VALUES;
        end
        PAINT_CARA: begin
            next <= (carita_executed)? PAINT_VALUES : PAINT_CARA;
        end
        default: next = IDLE;
    endcase
end

// Asignar el estado inicial
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        config_command_counter <= 'b0;
        counter_data <= 'b0;
		data_reg <= 'b0;
        rs_reg <= 'b0;
        painting_caras <= 0;
    end else begin
        case (next)
            IDLE: begin
                init_config_executed <= 0;
                initial_paint_text_done <= 0;
                initial_paint_values_done <= 0;
                initial_paint_cara_done <= 0;
                carita_executed <= 0;
                values_executed <= 0;
                set_task <= 0;
                config_command_counter <= 'b0;
                counter_data <= 'b0;
                data_reg <= 'b0;
                rs_reg <= 'b0;
                painting_caras <= 0;
            end
            INIT_CONFIG: begin
                if (config_command_counter < num_config_commands) begin
                    data_reg <= config_memory[config_command_counter];
                    rs_reg <= 0;
                    config_command_counter <= config_command_counter + 1;
                end else begin
                    config_command_counter <= 0;
                    init_config_executed <= 1;
                end
            end
            INITIAL_PAINT_CARA:begin
                painting_caras <= 1;
                case(set_task)
                    SENT_CARITA: begin
                        num_cust_char <= 0;
                        set_task <= START_PAINT;
                    end
                    START_PAINT: begin
                        set_task <= (lcd_available_cara)? START_PAINT : PAINTING;
                        start_painting_cara <= (lcd_available_cara)? 1 : 0;
                    end
                    PAINTING: begin
                       if (lcd_available_cara) begin
                           initial_paint_cara_done <= 1;
                           set_task <= 0;
                        end
                    end
                endcase
            end
            INITIAL_PAINT_TEXT:begin  
                painting_caras <= 0; 
                case(counter_data)
                    0: begin rs_reg <= 0; data_reg <= initial_lcd_address[FEED_TEXT]; counter_data <= 1; end
                    1: begin rs_reg <= 1; data_reg <= string_feed[0]; counter_data <= 2; end
                    2: begin rs_reg <= 1; data_reg <= string_feed[1]; counter_data <= 3; end
                    3: begin rs_reg <= 1; data_reg <= string_feed[2]; counter_data <= 4; end
                    4: begin rs_reg <= 1; data_reg <= string_feed[3]; counter_data <= 5; end
                    5: begin rs_reg <= 0; data_reg <= initial_lcd_address[JOY_TEXT]; counter_data <= 6; end
                    6: begin rs_reg <= 1; data_reg <= string_joy[0]; counter_data <= 7; end
                    7: begin rs_reg <= 1; data_reg <= string_joy[1]; counter_data <= 8; end
                    8: begin rs_reg <= 1; data_reg <= string_joy[2]; counter_data <= 9; end
                    9: begin rs_reg <= 0; data_reg <= initial_lcd_address[ENERGY_TEXT]; counter_data <= 10; end
                    10: begin rs_reg <= 1; data_reg <= string_energy[0]; counter_data <= 11; end
                    11: begin rs_reg <= 1; data_reg <= string_energy[1]; counter_data <= 12; end
                    12: begin rs_reg <= 1; data_reg <= string_energy[2]; counter_data <= 13; end
                    13: begin rs_reg <= 1; data_reg <= string_energy[3]; counter_data <= 14; end
                    14: begin rs_reg <= 1; data_reg <= string_energy[4]; counter_data <= 15; end
                    15: begin rs_reg <= 1; data_reg <= string_energy[5]; counter_data <= 16; end
                    16: begin counter_data <= 0; initial_paint_text_done <= 1; end
                    default: counter_data <= 0;
                endcase
            end
            INITIAL_PAINT_VALUES: begin
                painting_caras <= 0;
                case(set_task)
                    FEED_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[FEED_VALUE]; counter_data <= 1; end
                            1: begin rs_reg <= 1; data_reg <= string_numbers[5]; counter_data <= 0; set_task <= JOY_VALUE_PAINT; end
                            default: counter_data <= 0;
                        endcase 
                    end
                    JOY_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[JOY_VALUE]; counter_data <= 1; end
                            1: begin rs_reg <= 1; data_reg <= string_numbers[5]; counter_data <= 0; set_task <= ENERGY_VALUE_PAINT; end
                            default: counter_data <= 0;
                        endcase
                    end
                    ENERGY_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[ENERGY_VALUE]; counter_data <= 1; end
                            1: begin rs_reg <= 1; data_reg <= string_numbers[5]; counter_data <= 0; set_task <= 0; initial_paint_values_done <= 1; end
                            default: counter_data <= 0;
                        endcase
                    end
                endcase
            end
            PAINT_CARA:begin
                counter <= counter + 1;
                painting_caras <= 1;
                values_executed <= 0;
                case(set_task)
                    SENT_CARITA: begin
                        num_cust_char <= face;
                        set_task <= START_PAINT;
                    end
                    START_PAINT: begin
                        set_task <= (lcd_available_cara)? START_PAINT : PAINTING;
                        start_painting_cara <= (lcd_available_cara)? 1 : 0;
                    end
                    PAINTING: begin
                       if (lcd_available_cara) begin
                           carita_executed <= 1;
                           set_task <= 0;
                        end
                    end
                endcase
            end
            PAINT_VALUES: begin
                counter <= counter + 1;
                painting_caras <= 0;
                carita_executed <= 0;
                case(set_task)
                    FEED_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[FEED_VALUE]; counter_data <= 1; end
                            1: begin rs_reg <= 1; data_reg <= string_numbers[feed_value]; counter_data <= 0; set_task <= JOY_VALUE_PAINT; end
                            default: counter_data <= 0;
                        endcase 
                    end
                    JOY_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[JOY_VALUE]; counter_data <= 1; end
                            1: begin rs_reg <= 1; data_reg <= string_numbers[joy_value]; counter_data <= 0; set_task <= ENERGY_VALUE_PAINT; end
                            default: counter_data <= 0;
                        endcase
                    end
                    ENERGY_VALUE_PAINT: begin
                        case(counter_data)
                            0: begin rs_reg <= 0; data_reg <= initial_lcd_address[ENERGY_VALUE]; counter_data <= 1; end
                            1: begin counter <= 0; rs_reg <= 1; data_reg <= string_numbers[energy_value]; counter_data <= 0; set_task <= 0; values_executed <= 0; values_executed <= 1; end
                            default: counter_data <= 0;
                        endcase
                    end
                endcase
            end
        endcase
    end
end

assign enable = clk_16ms;
assign enable = clk_16ms;
assign rs = (painting_caras)?  rs_wire : rs_reg;
assign rw = 0;
assign data = (painting_caras)?  data_wire: data_reg;

endmodule
