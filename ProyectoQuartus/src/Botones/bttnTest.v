module bttnTest #(parameter COUNT_MAX = 25000000,FiveSegs = 9)(
    // Declaración de entradas y salidas
    input botonTest,
    input clk,
    input rst,
    output reg btnTest,
    output reg [3:0] contBtnPress
);

localparam PRESSING = 3'd0; // 0
localparam WAITING = 3'd1;   // 1
localparam WAITING2 = 3'd2;   // 2
localparam WAITING3 = 3'd3;   // 3
localparam COUNTING = 3'd4;   // 4

reg [3:0] state;
reg [3:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter;
reg [$clog2(COUNT_MAX*FiveSegs)-1:0] contmsegs;
reg clkmseg;

reg [3:0] pulse_counter = 0;

reg flag_contmsegs = 0;

reg prevBotonTest = 0;

initial begin
    state <= PRESSING;
    next <= PRESSING;
end

//Reset de la máquina de estados
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= PRESSING;
    end else begin
        state <= next;
    end
end

always @(posedge clk) begin
	case(state)
        PRESSING: begin
            if (!botonTest) begin
                next <= WAITING;
            end else begin
                next <= PRESSING;
            end
        end
        WAITING: begin
            if (botonTest) begin
                next <= PRESSING;
            end else begin
                if (contmsegs <= COUNT_MAX * FiveSegs - 1) begin
                    next <= WAITING;
                end else begin
                    next <= WAITING2;
                end
            end
        end
        WAITING2: begin
            next <= COUNTING;
        end
        COUNTING: begin
            if (contmsegs <= COUNT_MAX * FiveSegs - 1) begin
                next <= COUNTING;
            end else begin
                next <= WAITING3;
            end
        end
        WAITING3: begin
            next <= PRESSING;
        end
    endcase
end

// Máquina de Estados , general: Cambio entre estados
always @(posedge clk) begin
    case(next)
        PRESSING: begin
            btnTest <= 0;
            flag_contmsegs <= 1'b0;
        end
        WAITING: begin
            flag_contmsegs <= 1'b1;
            if (!botonTest) begin
                if (contmsegs == COUNT_MAX * FiveSegs - 1) begin
                    btnTest <= 1;
                end
            end
        end
        WAITING2: begin
            flag_contmsegs <= 1'b0;
				pulse_counter <= 0;
        end
        COUNTING: begin
			contBtnPress <= 0;
            flag_contmsegs <= 1'b1;
            if (!botonTest && prevBotonTest) begin
                pulse_counter <= pulse_counter + 1;
        end
        end
        WAITING3: begin
            contBtnPress <= pulse_counter;
        end
    endcase
    prevBotonTest <= botonTest;
end




// Divisor de frecuencia , a reloj en 0.5s
always @(posedge clk) begin
    if (flag_contmsegs) begin
        if (contmsegs == COUNT_MAX*FiveSegs*2 -1) begin
            contmsegs <= 0;
            end else begin
                contmsegs <= contmsegs+1;           
            end
    end else begin 
        contmsegs <= 0;
        end
end



endmodule