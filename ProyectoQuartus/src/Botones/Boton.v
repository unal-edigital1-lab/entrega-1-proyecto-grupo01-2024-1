module Boton #(parameter MIN_TIME = 5000)(
    input wire clk, // Clock input in ms
    input wire reset, // Reset input
    input wire btn_in, // Button input
    output wire btn_out // Debounced button output
);

    reg btn_state; // Current state of the button
    reg btn_prev; // Previous state of the button
    reg [$clog2(MIN_TIME*2)-1:0] counter; // Counter for debouncing

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            btn_state <= 1'b0;
            btn_prev <= 1'b0;
            counter <= 0;
        end else begin 
            if (btn_in != btn_prev) begin
                btn_prev <= btn_in;
                btn_state <= 0;
                if (btn_in == 1) begin
                    counter <= 1;
                end
            end else if (btn_in == 1) begin // previus state is also 1
                counter <= counter + 1; 
                if (counter >= (MIN_TIME - 1)) begin
                    btn_state <= 1;
                    counter <= 0;
                end
            end 
        end
    end

    assign btn_out = btn_state;
endmodule