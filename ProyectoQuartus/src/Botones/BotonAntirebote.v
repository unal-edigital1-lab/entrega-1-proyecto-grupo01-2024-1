module BotonAntirebote #(parameter MIN_TIME = 5000)(
    input wire clk, // Clock input in ms
    input wire btn_in, // Button input
    output wire btn_out // Debounced button output
);

    reg btn_state = 1'b0; // Current state of the button
    reg btn_prev = 1'b0; // Previous state of the button
    reg [$clog2(MIN_TIME*2)-1:0] counter = 0; // Counter for debouncing
	 

    always @(posedge clk) begin
        if (btn_in != btn_prev) begin
            btn_prev <= btn_in;
            btn_state <= 0;
        end 
        
        if (btn_in == 1) begin // previus state is also 1
            counter <= counter + 1; 
            if (counter >= (MIN_TIME - 1)) begin
                btn_state <= 1;
                counter <= 0;
            end
        end 
    end

    assign btn_out = btn_state;
endmodule