/*module Boton_AR #(parameter COUNT_BOT=50000)(
	input reset,
	input clk,
	input boton_in,
	output reg boton_out
);

reg [$clog2(COUNT_BOT)-1:0] counter;


always @(posedge clk) begin
	if (~reset)begin
		counter <=0;
		boton_out<=~boton_in;
	end else begin
		if (boton_in==boton_out) begin
			counter <= counter+1;			
		end else begin
			counter<=0;			
		end
		if (boton_in==0 && counter==COUNT_BOT)begin
 // 			boton_out<=~boton_out;
	 			boton_out<=1;
				counter<=0;
				
		end
		if (boton_in==1 && counter==COUNT_BOT/100+1)begin
 // 			boton_out<=~boton_out;
	 			boton_out<=0;
				counter<=0;
				
		end
	
	end
		

end	


endmodule*/

module Boton_AR #(parameter COUNT_BOT=50000)(
    input reset,
    input clk,
    input boton_in,
    output reg boton_out
);

reg [$clog2(COUNT_BOT)-1:0] counter;
reg boton_stable;

always @(posedge clk or negedge reset) begin
    if (~reset) begin
        counter <= 0;
        boton_out <= 0; // Establece un valor conocido en reset
        boton_stable <= boton_in;
    end else begin
        // Si el estado del botón no ha cambiado, incrementa el contador
        if (boton_in == boton_stable) begin
            if (counter < COUNT_BOT) begin
                counter <= counter + 1;
            end else begin
                // Solo actualiza boton_out si el contador alcanza COUNT_BOT y el estado es estable
                boton_out <= boton_stable;
            end
        end else begin
            // Si el estado del botón cambia, reinicia el contador y actualiza el estado estable
            counter <= 0;
            boton_stable <= boton_in;
        end
    end
end

endmodule