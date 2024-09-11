`include "i2c_master.v"

module GiroscopioController #(parameter SLAVE_ADDRESS = 7'h68)(
    //INPUTS
    input wire clk,
    input wire reset,
    input wire enable_giroscopio,
    inout wire SDA_BUS,
    //OUTPUTS
    output wire SCL_BUS,
    output wire mover);
    

// GiroscopioController output
reg enable_mover = 0; // flag to enable output wire mover 
assign mover = (enable_mover) ? 1 : 0;

// I2C Master inputs
reg [7:0] reg_to_read = 0; // Register that I2C master wants to read
wire start;
reg enable_start = 0;
assign start = (enable_start) ? 1 : 0;

// I2C Master outputs
wire [7:0] data_out;
wire data_out_available;
wire i2c_master_available;

// I2C Master instance
//reg [6:0] SLAVE_ADDRESS = 7'b1101000; // 0x68 default address of mpu6050 (slave)
i2c_master #(.SLAVE_ADDRESS(SLAVE_ADDRESS)) i2c_inst(
    .clk(clk),
    .reset(reset),
    .start(start),
    .data_in(reg_to_read),
    .SDA_BUS(SDA_BUS),
    .SCL_BUS(SCL_BUS),
    .data_out(data_out),
    .data_out_available(data_out_available),
    .i2c_master_available(i2c_master_available)
);

// Minima distancia para considerar un cambio en el giroscopio
localparam MIN_DIST = 10;

//0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
reg [7:0] address_Ax1 = 8'h3B; reg [7:0] address_Ax2 = 8'h3C;
//0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L) 
reg [7:0] address_Ay1 = 8'h3D; reg [7:0] address_Ay2 = 8'h3E;
// 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
reg [7:0] address_Az1 = 8'h3F; reg [7:0] address_Az2 = 8'h40;

// Variables to store values sent by giroscopio, 16 bits signed
reg signed [15:0] actual_value = 0;
reg signed [15:0] previus_value = 0;
reg [1:0] counter = 0;
reg [1:0] next_counter = 0;
localparam AX1 = 0;
localparam AX2 = 1;

// Estados de la maquina de estados
localparam IDLE = 0, SET_BYTE_TO_READ = 1, START_I2C = 2, WAIT_DATA = 3, PROCCESS = 4, STOP = 5;
reg [0:2] fsm_state = 0; // 2 bits for 4 states
reg [0:2] next_state = 0;

// flags
reg [1:0] byte_read = 0; // flag to know if the first or second byte was received
reg isFirstByte = 0;
    
// STATE MACHINE
always @(posedge clk)begin
   if(reset == 0 || enable_giroscopio == 0)begin
        fsm_state <= IDLE;
   end else begin
        fsm_state <= next_state;
   end
end

always @(*) begin
    case(fsm_state)
        IDLE:
            next_state <= (enable_giroscopio) ? SET_BYTE_TO_READ : IDLE;
        SET_BYTE_TO_READ:
            next_state <= START_I2C;
        START_I2C:
            next_state <= (enable_start) ? START_I2C: WAIT_DATA;
        WAIT_DATA:
            next_state <= (byte_read == 0) ? WAIT_DATA : ((byte_read == 2) ? PROCCESS : SET_BYTE_TO_READ);
        PROCCESS:
            next_state <= IDLE;
        default:
            next_state <= IDLE;
    endcase
end


// OUTPUT LOGIC
always @(clk) begin
    if (reset == 0) begin
        previus_value <= 0;
        actual_value <= 0;
        counter <= 0;
        next_counter <= 0;
    end else begin
        case(next_state)
        IDLE: begin
            enable_start <= 0;
            reg_to_read <= 0;
            byte_read <= 0;
            isFirstByte <= 0;
            byte_read <= 0;
            enable_mover <= 0;
        end
        SET_BYTE_TO_READ: begin
            counter = next_counter;
            case(counter)
                AX1: begin reg_to_read <= address_Ax1; isFirstByte = 0; next_counter = AX2; end
                AX2: begin reg_to_read <= address_Ax2; isFirstByte = 1; next_counter = AX1; end
            endcase   
        end
        START_I2C: begin
            enable_start = (i2c_master_available) ? 1: 0;
        end
        WAIT_DATA: begin
            if (data_out_available) begin
                // TODO: previus_value si toma el valor de actual_value y actual_value de data_out?? 
                // o como todo está sincronizando con el reloj, entonces todo termina valiendo lo mismo??
                previus_value <= actual_value;
                if (isFirstByte) begin 
                    actual_value[15:8] <= data_out[7:0]; // save the first byte of the Ax
                    byte_read <= 1;
                end else begin
                    actual_value[7:0] <= data_out[7:0];
                    byte_read <= 2;
                end
            end 
        end
        PROCCESS: begin
            /* TODO: Preguntar si se puede hacer la comparación de esta manera 
            La idea es calcular el valor absoluto de la resta para que no importe la dirección del movimiento */ 
            if ((previus_value - actual_value > MIN_DIST) || (previus_value - actual_value < -MIN_DIST))
                enable_mover <= 1;
            else
                enable_mover <= 0;
        end
        endcase
    end
end

endmodule