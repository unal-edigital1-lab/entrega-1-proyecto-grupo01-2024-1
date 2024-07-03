module button(
    input clk,
    input button,
    output reg signal
);

reg [1:0] button_sync;
reg [15:0] counter;
reg button_stable;
reg button_prev;

// Sincronización de la señal del botón al reloj del sistema
always @(posedge clk) begin
    button_sync <= {button_sync[0], button};
end

// Contador de estabilidad
always @(posedge clk) begin
    if (button_sync[1] == button_sync[0]) begin
        // Si el botón no ha cambiado, incrementar el contador
        counter <= counter + 1;
        if (counter == 16'hFFFF) begin
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
        signal <= ~signal;
    end
    button_prev <= button_stable;
end
endmodule
