//`include "checker.v"

module task_manager #(parameter MAX_VALUE_STATISTICS = 5, NUM_FACES = 9)(
    input clk,            
    input reset,
    input [$clog2(NUM_FACES) -1:0] face,
    input [$clog2(MAX_VALUE_STATISTICS) -1:0] Hunger,
    input [$clog2(MAX_VALUE_STATISTICS) -1:0] Joy,
    input [$clog2(MAX_VALUE_STATISTICS) -1:0] Energy,
    output wire new_update
       
);


wire food_change;
wire Joy_change;
wire Energy_change;
wire face_change;

assign new_update = (reset == 0) ? 0 : (face_change | food_change | Joy_change | Energy_change);


checker #(.MAX_VALUE(MAX_VALUE_STATISTICS), .RESET_VALUE(5)) Hunger_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Hunger),
    .change(food_change)
);

checker #(.MAX_VALUE(MAX_VALUE_STATISTICS), .RESET_VALUE(5)) Entertainment_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Joy),
    .change(Joy_change)
);

checker #(.MAX_VALUE(MAX_VALUE_STATISTICS), .RESET_VALUE(5)) Energy_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Energy),
    .change(Energy_change)
);


checker #(.MAX_VALUE(NUM_FACES), .RESET_VALUE(0)) state_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(face),
    .change(face_change)
);

endmodule
