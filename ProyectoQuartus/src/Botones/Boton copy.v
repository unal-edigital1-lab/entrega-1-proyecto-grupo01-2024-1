`include "BotonAntirebote.v"
module Boton #(parameter TIME_PRESSED = 25000000, TIME_ANTIREBOTE = 5000, COUNT_OUTPUT_SIGNAL = 10)(
    input wire clk, // Clock input in ms
    input wire reset,
    input wire boton_in, // Button input
    output reg boton_out // Debounced button output
);

    // Instantiate the boton module
    wire btn_procesado; // Processed button output
    BotonAntirebote #(.MIN_TIME(TIME_ANTIREBOTE)) instBotonAntirebote(
        .clk(clk),
        .btn_in(boton_in),
        .btn_out(btn_procesado)
    );
    
    initial begin
        boton_out = 0;
    end
 
    reg btn_prev = 0;
    reg [$clog2(TIME_PRESSED)-1:0] count = 0;
    reg [$clog2(COUNT_OUTPUT_SIGNAL)-1:0] count_out = 0;
    reg change_detected = 0;
    reg btn_out_sent = 0;
    reg back_to_idle = 0;

    // Estados de la maquina de estados
    localparam IDLE = 0;
    localparam WAITING = 1;
    localparam PRESSED = 2;
    localparam SET_OUTPUT = 4;

    // Variables de la maquina de estados
    reg [1:0] fsm_state = 0;
    reg [1:0] next = 0;

    // Maquina de estados
    always @(posedge clk) begin
        if(reset == 0)begin
            fsm_state <= IDLE;
        end else begin
            fsm_state <= next;
        end
    end

    always @(*) begin
        case(fsm_state)
            IDLE: begin
                next = WAITING;
            end
            WAITING: begin
                next = (change_detected) ? PRESSED : WAITING;
            end
            PRESSED: begin
                next =  (btn_out_sent) ? SET_OUTPUT : PRESSED;
            end
            SET_OUTPUT: begin
                next = (back_to_idle) ? IDLE : SET_OUTPUT;
            end
            default: begin
                next = IDLE;
            end
        endcase
    end



    always @(posedge clk) begin
        if (reset == 0) begin
            btn_prev <= 0;
            change_detected <= 0;
        end else begin
            case(next)
                IDLE: begin
                    back_to_idle <= 0;
                    change_detected <= 0;
                    count_out <= 0;
                    count <= 0;
                end
                WAITING: begin
                if (btn_procesado != btn_prev) begin
                        btn_prev <= btn_procesado;
                        change_detected <= 1;
                end
                end
                PRESSED: begin
                    if(count == TIME_PRESSED) begin
                        count <= 0;
                        back_to_idle <= 1;
                    end else begin
                        count <= count + 1;
                    end
                end
                SET_OUTPUT: begin
                    if (count_out == COUNT_OUTPUT_SIGNAL) begin
                        count_out <= 0;
                        btn_out_sent <= 1;
                        boton_out <= 0;
                    end else begin
                        boton_out <= 1;
                        count_out <= count_out + 1;
                    end
                  
                end
            endcase
        end
    end

endmodule