module mic #(parameter COUNT_MAX = 25000000) (
    input mic,
    input clk,
    input rst,
    output reg buzzer,
    output reg signal_awake
);

localparam LISTENING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1
localparam SPEAKING = 2'd2;   // 2

reg [2:0] state;
reg [2:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter;
reg [4:0] contmsegs;
reg clkmseg;

reg prev_mic;

initial begin
		state <= LISTENING;
		next <= LISTENING;
end

//Reset de la máquina de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= LISTENING;
    end else begin
        state <= next;
    end
end

// Máquina de Estados , general: Cambio entre estados
always @(*) begin
    case (state)
        LISTENING: begin
            if (mic && prev_mic == 0) begin
                next = WAITING;
                contmsegs <= 0;
                signal_awake <= 1;
            end
        end
        WAITING: begin
            next = SPEAKING;
            signal_awake <= 0;
        end
        SPEAKING: begin
            if (contmsegs < 2) begin
                buzzer <= 1;
            end else if (contmsegs < 4) begin
                buzzer <= 0;
            end else if (contmsegs < 6) begin
                buzzer <= 1;
            end else if (contmsegs < 8) begin
                buzzer <= 0;
            end else if (contmsegs < 10) begin
                buzzer <= 1;
            end else if (contmsegs < 12) begin
                buzzer <= 0;
            end else begin
                buzzer <= 0;
                next = LISTENING;
            end
        end
        default: begin
            buzzer = 0;
        end
    endcase
    prev_mic <= mic;
end



// Divisor de frecuencia , a reloj en s
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

// Contador de tiempo en general 
	always @(posedge clkmseg or posedge rst) begin
		if(rst)begin
			contmsegs <= 0;
		end else begin
            contmsegs <= contmsegs+1;
        end
	end


endmodule