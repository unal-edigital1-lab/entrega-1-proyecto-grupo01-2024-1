module bttnReset #(parameter COUNT_MAX = 25000000, FiveSegs = 10)(
    // Declaración de entradas y salidas
    input botonReset,
    input clk,
    input rst,
    output reg btnRst
);

localparam PRESSING = 2'd0; // 0
localparam WAITING = 2'd1;   // 1

reg [3:0] state;
reg [3:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter;
reg [3:0] contmsegs;
reg clkmseg;

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

// Máquina de Estados , general: Cambio entre estados
always @(posedge clk or posedge rst) begin
    case(state)
        PRESSING: begin
            btnRst <= 0;
            if (botonReset) begin
                next <= WAITING;
                counter <= 0;
                contmsegs <= 0;
            end else begin
                next <= PRESSING;
            end
        end
        WAITING: begin
            if (!botonReset) begin
                next <= PRESSING;
            end else begin
                if (contmsegs < FiveSegs) begin
                    next <= WAITING;
                end else begin
                    btnRst <= 1;
                    contmsegs <= 0;
                    next <= PRESSING;
                end
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



endmodule