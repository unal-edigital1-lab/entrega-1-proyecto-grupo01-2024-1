module bttnTest #(parameter COUNT_MAX = 25000000,FiveSegs = 10);
    // Declaración de entradas y salidas
    input botonTest;
    input clk;
    input rst;
    output reg btnTest;

    reg [$clog2(COUNT_MAX)-1:0] counter;
    reg [3:0] contmsegs;
    reg clkmseg;

    always @(posedge clkmseg or posedge rst) begin
        if(rst)begin
            btnTest <= 0;
        end else begin
            if (botonTest) begin
                contmsegs <= 0;
                while (botonTest && (contmsegs <= FiveSegs)) begin
                        if (contmsegs == FiveSegs) begin
                            btnTest <= 1;
                        end else 
                            btnTest <= 0;
                    end
                end
            end else begin
                btnTest <= 0;
            end

        end
        


    // Divisor de frecuencia , a reloj en medio segundo 
		always @(posedge clk or posedge rst) begin
		if(rst)begin
			clkmseg <=0;
			counter <=0;
		end else begin
		if (counter == COUNT_MAX-1) begin
			clkmseg <= ~clkmseg;
			counter <= 0;
			end else begin
				counter = counter +1;
			end
		end
	end

// Contador de tiempo en general cada medio segundo
	always @(posedge clkmseg or posedge rst) begin
		if(rst)begin
			contmsegs <= 0;
		end else begin
            contmsegs <= contmsegs+1;
        end
	end
    

endmodule