module Button(
    input clk,
    input buttonRaw,
    output reg buttonDebounced
);

reg [1:0] button_sync = 0;
reg [15:0] counter = 0;
reg button_stable = 0;
reg button_prev = 0;

initial begin
    buttonDebounced = 0;
end

localparam COUNTER_MAX = 16'h000F;

// Sincronización de la señal del botón al reloj del sistema y contador de estabilidad
always @(posedge clk) begin
    // Sincronización de la señal del botón
    button_sync <= {button_sync[0], buttonRaw};

    // Contador de estabilidad
    if (button_sync[1] == button_sync[0]) begin
        // Si el botón no ha cambiado, incrementar el contador
        counter <= counter + 1;
        if (counter == COUNTER_MAX) begin
            button_stable <= button_sync[1];
        end
    end else begin
        // Si el botón ha cambiado, reiniciar el contador
        counter <= 0;
    end

end


// Detección de flanco ascendente del botón estable
always @(posedge clk) begin
    if (button_stable && !button_prev) begin
        buttonDebounced <= ~buttonDebounced;
    end
    button_prev <= button_stable;
end
endmodule
