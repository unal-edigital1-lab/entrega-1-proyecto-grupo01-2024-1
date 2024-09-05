module bttnReset #(parameter COUNT_MAX = 25000000, FiveSegs = 10)(
    // Declaración de entradas y salidas
    input btnRst_in,
    input clk,
    output reg btnRst_out
);

localparam PRESSING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1

reg [3:0] state;
reg [3:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter = 0;
reg [$clog2(COUNT_MAX*FiveSegs)-1:0] contmsegs = 0;
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

always @(posedge clk) begin
	case(state)
        PRESSING: begin
            if (!btnRst_in) begin
                next <= WAITING;
            end else begin
                next <= PRESSING;
            end
        end
        WAITING: begin
            if (btnRst_in) begin
                next <= PRESSING;
            end else begin
                if (contmsegs <= COUNT_MAX * FiveSegs * 2) begin
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
            btnRst_out <= 0;
            flag_contmsegs <= 1'b0;
        end
        WAITING: begin
            flag_contmsegs <= 1'b1;
            if (!btnRst_in) begin
                if (contmsegs == COUNT_MAX * FiveSegs - 1) begin
                    btnRst_out <= 1;
				end
            end
        end
    endcase
end


// Divisor de frecuencia , a reloj en 0.5s
always @(posedge clk) begin
    if (flag_contmsegs) begin
        if (contmsegs == COUNT_MAX*FiveSegs*2) begin
            contmsegs <= 0;
            end else begin
                contmsegs <= contmsegs+1;           
            end
    end else begin 
        contmsegs <= 0;
        end
	end

//assign contmsegs = (flag_contmsegs)? 'b0 : contmsegs;


endmodule