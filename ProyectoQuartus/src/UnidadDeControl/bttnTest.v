module bttnTest #(parameter COUNT_MAX = 25000000,FiveSegs = 10)(
    // Declaración de entradas y salidas
    input botonTest,
    input clk,
    input rst,
    output reg btnTest,
    output reg [3:0] contBtnPress
);

localparam PRESSING = 3'd0; // 0
localparam WAITING = 3'd1;   // 1
localparam COUNTING = 3'd2;   // 2

reg [3:0] state;
reg [3:0] next;

reg [$clog2(COUNT_MAX)-1:0] counter;
reg [3:0] contmsegs;
reg clkmseg;

reg prevBotonTest;

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
            btnTest <= 0;
            contBtnPress <= 0;
            if (botonTest) begin
                next <= WAITING;
                counter <= 0;
                contmsegs <= 0;
            end else begin
                next <= PRESSING;
            end
        end
        WAITING: begin
            if (!botonTest) begin
                next <= PRESSING;
            end else begin
                if (contmsegs < FiveSegs) begin
                    next <= WAITING;
                end else begin
                    btnTest <= 1;
                    contmsegs <= 0;
                    prevBotonTest <= botonTest;
                    next <= COUNTING;
                end
            end
        end
        COUNTING: begin
            btnTest <= 0;
            if (contmsegs < FiveSegs) begin
                next = COUNTING;
            end else begin
                next <= PRESSING;
            end

            prevBotonTest <= botonTest;
            if (botonTest && !prevBotonTest) begin
                contBtnPress <= contBtnPress + 1;
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