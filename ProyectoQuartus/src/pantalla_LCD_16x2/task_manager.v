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


wire Hunger_change;
wire Joy_change;
wire Energy_change;
wire state_change;

reg new_update_reg = 0;

assign new_update = (state_change | Hunger_change | Joy_change | Energy_change);


checker #(.MAX_VALUE(MAX_VALUE_STATISTICS)) Hunger_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Hunger),
    .change(Hunger_change)
);

checker #(.MAX_VALUE(MAX_VALUE_STATISTICS)) Entertainment_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Joy),
    .change(Joy_change)
);

checker #(.MAX_VALUE(MAX_VALUE_STATISTICS)) Energy_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(Energy),
    .change(Energy_change)
);


checker #(.MAX_VALUE(NUM_FACES)) state_checker (
    .clk(clk),
    .reset(reset),
    .the_signal(face),
    .change(state_change)
);

endmodule
