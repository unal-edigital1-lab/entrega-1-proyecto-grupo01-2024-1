module mic #(parameter COUNT_MAX = 25000000) (
    input mic,
    input clk,
    input rst,
    output reg buzzer
);

localparam LISTENING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1
localparam SPEAKING = 2'd2   // 2

reg [2:0] state;
reg [2:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter;
reg [3:0] contmsegs;
reg clkmseg;

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

        end
        WAITING: begin

        end
        SPEAKING: begin
            if (contmsegs==5) begin
                buzzer <= 1;
            end else if (contmsegs==6) begin
                buzzer <= 0;
            end else if (contmsegs==7) begin
                buzzer <= 1;
            end else if (contmsegs==8) begin
                buzzer <= 0;
            end else if (contmsegs==9) begin
                buzzer <= 1;
            end else if (contmsegs==10) begin
                buzzer <= 0;
                contmsegs <= 0;
            end
        end
    endcase
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




/*always @(posedge clk or posedge rst) begin
    if (rst) begin
        buzzer <= 0;
    end else begin
        if (mic) begin
            contmsegs <= 0;
            if (contmsegs==5) begin
                buzzer <= 1;
            end else if (contmsegs==6) begin
                buzzer <= 0;
            end else if (contmsegs==7) begin
                buzzer <= 1;
            end else if (contmsegs==8) begin
                buzzer <= 0;
            end else if (contmsegs==9) begin
                buzzer <= 1;
            end else if (contmsegs==10) begin
                buzzer <= 0;
                contmsegs <= 0;
            end
        end
    end
end
*/




endmodule