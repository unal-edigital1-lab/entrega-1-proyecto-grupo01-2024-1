module mic #(parameter COUNT_MAX = 25000000) (
    input mic,
    input clk,
    input rst,
    input [3:0] state_t,
    output reg buzzer,
    output reg signal_awake
);

localparam LISTENING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1
localparam SPEAKING = 2'd2;   // 2

localparam ON = 2'd0;   // 0
localparam WAIT1 = 2'd1;   // 1
localparam OFF = 2'd2;   // 2
localparam WAIT2 = 2'd3;   // 3

reg [2: 0] next;

reg [2:0] state;
reg [2:0] next_state;

reg flag;


reg [2:0] num_veces = 4'd3;
reg [2:0] nunm_tiempo = 4'd1;

always @(posedge clk)begin
    if(state_t == 0 || state_t == 1) begin
        num_veces <= 3;
        nunm_tiempo <= 2;
    end else if(state_t==5) begin
        num_veces <= 2;
        nunm_tiempo <= 1;
    end else if(state_t==4)begin
        num_veces <= 2;
        nunm_tiempo <= 5;
    end else if (state_t == 2)begin
        num_veces <= 1;
        nunm_tiempo <= 1;
    end else begin
        num_veces <= 1;
        nunm_tiempo <= 1;
        //prev_mic <= 1;
    end
end

reg [$clog2(COUNT_MAX*10*2)-1:0] counter;
reg [$clog2(COUNT_MAX*10 * 2)-1:0] contmsegs = 0;
reg clkmseg;

reg prev_mic;

initial begin
		state <= LISTENING;
		next_state <= LISTENING;
        buzzer <= 1;
        next <= ON;
        flag <= 0;
end

//Reset de la máquina de estados
always @(posedge clk or negedge  rst) begin
    if (!rst) begin
        state <= LISTENING;
    end else begin
        state <= next_state;
    end
end

// Máquina de Estados , general: Cambio entre estados
always @(negedge clk) begin
    case (state)
        LISTENING: begin
            next_state = (mic == 1 && prev_mic == 0)? WAITING : next_state;
        end
        WAITING: begin
            next_state = SPEAKING;
        end 
        SPEAKING: begin
            next_state = (contmsegs == (COUNT_MAX*num_veces*2)-1)? LISTENING : next_state;
        end
        default: begin
            next_state = LISTENING;
            //buzzer = 0;WAITING
        end
    endcase
    prev_mic <= mic;
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        counter <= 0;
        buzzer <= 0;
        next <= ON;
        flag <= 0;
    end else begin
        case (next_state)
            LISTENING: begin
                buzzer <= 1;
                signal_awake <= 0;
                flag = 0;
            end
            WAITING: begin
                signal_awake <= 1;
                flag = 1;
                counter <= 0;
            end
            SPEAKING: begin
                case(next)
                ON: begin
                        next <= (counter == ((COUNT_MAX-1) / nunm_tiempo))? WAIT1 : ON;
                        buzzer <= 0;
                        counter <= counter + 1;
                    end
                WAIT1: begin
                    counter <= 0;
                    next <= OFF;
                end
                OFF: begin
                        next <= (counter == ((COUNT_MAX-1) / nunm_tiempo))? WAIT2 : OFF;
                        counter <= counter + 1;
                        buzzer <= 1;
                    end
                WAIT2: begin
                    counter <= 0;
                    next <= ON;
                end
            endcase 
            end
        endcase
    end
end


// Divisor de frecuencia , a reloj en 0.5s
	always @(posedge clk or negedge rst) begin
		if(!rst)begin
			clkmseg <=0;
			contmsegs <= 0;
		end else begin
        if (flag) begin
            if (contmsegs == (COUNT_MAX*num_veces*2)-1) begin
                contmsegs <= 0;
                end else begin
                    contmsegs <= contmsegs+1;           
                end
        end else begin 
            contmsegs <= 0;
            end
		end
	end
    
    //assign flag = ((next_state == WAITING) || (next_state == SPEAKING)) ? 1 : 0;

// // Contador de tiempo en general 
// 	always @(posedge clk or posedge rst) begin
// 		if(rst)begin
// 			contmsegs <= 0;
// 		end else if(flag) begin
// 		contmsegs <= 0;
// 		end else begin
//             contmsegs <= contmsegs+1;
//         end
// 	end


endmodule