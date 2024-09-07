module checker #(parameter MAX_VALUE = 5, COUNT_MAX = 20)(
    input wire clk,
    input wire reset,
    input [$clog2(MAX_VALUE)-1:0] the_signal,
    output wire change
);

reg [$clog2(MAX_VALUE)-1:0] previus_value = 0;
reg [$clog2(MAX_VALUE)-1:0] actual_value = 0;

reg [$clog2(COUNT_MAX)-1:0] count = 0;
reg change_detected = 0;
reg back_to_idle = 0;

// Estados de la maquina de estados
localparam IDLE = 0;
localparam WAITING = 1;
localparam CHANGED = 2;

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
            next = (change_detected) ? CHANGED : WAITING;
        end
        CHANGED: begin
            next =  (back_to_idle) ? IDLE : CHANGED;
        end
        default: begin
            next = IDLE;
        end
    endcase
end



always @(posedge clk) begin
    if (reset == 0) begin
        actual_value <= 0;
        previus_value <= 0;
        change_detected <= 0;
    end else begin
        case(next)
            IDLE: begin
                back_to_idle <= 0;
                change_detected <= 0;
            end
            WAITING: begin
               if (the_signal != actual_value) begin
                    previus_value <= actual_value;
                    actual_value <= the_signal;
                    change_detected <= 1;
               end
            end
            CHANGED: begin
                if(count == COUNT_MAX) begin
                    count <= 0;
                    back_to_idle <= 1;
                end else begin
                    count <= count + 1;
                end
            end
        endcase
    end
end

assign change = change_detected;

endmodule