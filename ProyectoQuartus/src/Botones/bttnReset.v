module bttnReset #(parameter COUNT_MAX = 25000000, FiveSegs = 10)(
    // Declaración de entradas y salidas
    input botonReset,
    input clk,
    output reg btnRst
);

localparam PRESSING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1

reg [3:0] state;
reg [3:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter = 0;
reg [3:0] contmsegs = 0;
reg clkmseg = 0;

reg flag_contmsegs;

initial begin
    state <= PRESSING;
    next <= PRESSING;
end

//Reset de la máquina de estados
always @(posedge clk) begin
     state <= next;

end

always @(*) begin
	case(state)
        PRESSING: begin
            if (botonReset) begin
                next <= WAITING;
            end else begin
                next <= PRESSING;
            end
        end
        WAITING: begin
            if (!botonReset) begin
                next <= PRESSING;
            end else begin
                if (contmsegs <= FiveSegs) begin
                    next <= WAITING;
                end else begin
                    next <= PRESSING;
                end
            end
        end
    endcase
end

// Máquina de Estados , general: Cambio entre estados
always @(posedge clk) begin
    case(next)
        PRESSING: begin
            btnRst <= 0;
            if (botonReset) begin
					 flag_contmsegs <= 1'b1;
                //contmsegs <= 'b0;
			  end else begin
					flag_contmsegs <= 1'b0;
			  end
        end
        WAITING: begin
            if (botonReset) begin
                if (contmsegs == FiveSegs) begin
                    btnRst <= 1;
                end
            end
        end
    endcase
end


// Divisor de frecuencia , a reloj en s
always @(posedge clk) begin

	if (counter == COUNT_MAX-1) begin
		 clkmseg <= ~clkmseg;
		 counter <= 0;
	end else begin
			  counter = counter +1;
    end
end


// Contador de tiempo en general 
always @(posedge clkmseg) begin
if (flag_contmsegs) begin
	 contmsegs <= 0;
end else begin
    contmsegs <= contmsegs+1;
end
end

//assign contmsegs = (flag_contmsegs)? 'b0 : contmsegs;


endmodule