// DIV_FACTOR = 25000 is the divisor for the clock frequency
// The default output clock frequency is 50 MHz / 25k = 2 kHz so a 1 ms period clk is generated
module DivisorReloj #(parameter DIV_FACTOR = 25000)(
    input wire clk, // Clock input
    input wire reset, // Reset input
    output wire clk_out // Clock output
);

reg [$clog2(DIV_FACTOR)-1:0] clk_counter = 0;
reg clkr = 0;

always @(posedge clk or posedge reset) begin
    if (reset == 0) begin
        clk_counter <= 0;
        clkr <= 0;
    end else begin
        if (clk_counter == DIV_FACTOR - 1) begin
            clkr <= ~clkr;
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end
end

assign clk_out = clkr;

endmodule