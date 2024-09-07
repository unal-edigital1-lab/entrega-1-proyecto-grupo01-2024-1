//`include "lcd1602_controller.v"
//`include "DivisorReloj.v"

module test_lcd1602 #(parameter COUNT_MAX = 800000) (
    input clk,
    input reset,
    output wire rs,
    output wire rw,
    output wire enable,
    output wire [7:0] data
);
    reg [$clog2(9)-1:0] face = 0;
    reg [$clog2(5)-1:0] feed_value = 5;
    reg [$clog2(5)-1:0] joy_value = 5;
    reg [$clog2(5)-1:0] energy_value = 5;

    // Instantiate the LCD1602_TEXT module
    LCD1602_CONTROLLER #(
        .MAX_VALUE(5),
        .NUM_FACES(9),
        .COUNT_MAX(COUNT_MAX)
    ) inst_lcd1602_controller (
        .clk(clk),
        .reset(reset),
        .face(face),
        .food_value(feed_value),
        .joy_value(joy_value),
        .energy_value(energy_value),
        .rs(rs),
        .rw(rw),
        .enable(enable),
        .data(data)
    );

    // Instancia de divisor Reloj
    wire clk_16ms;
    DivisorReloj #(
        .DIV_FACTOR(COUNT_MAX)
    ) inst_clk_16ms (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_16ms)
    );
    
    wire clk_paint;
    DivisorReloj #(
        .DIV_FACTOR(80)
    ) inst_clk_paint (
        .clk_in(clk_16ms),
        .reset(reset),
        .clk_out(clk_paint)
    );
    
    reg [4:0] counter = 0;

    always @(posedge clk_paint)begin
        case(counter)
            0: begin counter <= counter + 1; end
            1: begin face <= 0; counter <= counter + 1; end
            2: begin face <= 1; counter <= counter + 1; end
            3: begin face <= 2; counter <= counter + 1; end
            4: begin face <= 3; counter <= counter + 1; end
            5: begin face <= 4; counter <= counter + 1; end
            6: begin face <= 5; counter <= counter + 1; end
            7: begin face <= 6; counter <= counter + 1; end
            8: begin face <= 7; counter <= counter + 1; end
            9: begin face <= 8; counter <= counter + 1; end
				/*
            10: begin feed_value <= 0; counter <= counter + 1; end
            11: begin feed_value <= 1; counter <= counter + 1; end
            12: begin feed_value <= 2; counter <= counter + 1; end
            13: begin feed_value <= 3; counter <= counter + 1; end
            14: begin feed_value <= 4; counter <= counter + 1; end
            15: begin feed_value <= 5; counter <= counter + 1; end
            16: begin joy_value <= 0; counter <= counter + 1; end
            17: begin joy_value <= 1; counter <= counter + 1; end
            18: begin joy_value <= 2; counter <= counter + 1; end
            19: begin joy_value <= 3; counter <= counter + 1; end
            20: begin joy_value <= 4; counter <= counter + 1; end
            21: begin joy_value <= 5; counter <= counter + 1; end
            22: begin energy_value <= 0; counter <= counter + 1; end
            23: begin energy_value <= 1; counter <= counter + 1; end
            24: begin energy_value <= 2; counter <= counter + 1; end
            25: begin energy_value <= 3; counter <= counter + 1; end
            26: begin energy_value <= 4; counter <= counter + 1; end
            27: begin energy_value <= 5; counter <= counter + 1; end
            28: begin counter <= 0; end
				*/
            default: counter <= 0;
        endcase
    end


endmodule