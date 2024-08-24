`include "i2c_master.v"

module GiroscopioController(
    input wire clk,
    input wire reset,
    inout wire SDA_BUS,
    output wire SCL_BUS,
    input wire iniciar_giroscopio,
    input wire detener_giroscopio,
    output wire caminar);
    
    // I2C Master inputs
    reg [6:0] slave_address = 7'b1101000; // 0x68 default address of mpu6050 (slave)
    reg [7:0] reg_data_in = 0; // Register that I2C master wants to read

    wire start;
    reg enable_start = 0;
    assign start = (enable_start) ? 1 : 0;

    wire stop;
    reg enable_stop = 0;
    assign stop = (enable_stop) ? 1 : 0;

    // I2C Master outputs
    wire [7:0] data_out;
    wire avail_data_out;
    wire avail_i2c_master;

    // I2C Master instance
    i2c_master i2c_inst(
        .clk(clk),
        .reset(reset),
        .start(start),
        .stop(stop),
        .slave_address(slave_address),
        .data_in(reg_data_in),
        .SDA_BUS(SDA_BUS),
        .SCL_BUS(SCL_BUS),
        .data_out(data_out),
        .avail_data_out(avail_data_out),
        .avail_i2c_master(avail_i2c_master)
    );

    // Minima distancia para considerar un cambio en el giroscopio
    localparam MIN_DIST = 10;

    //0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
    reg [7:0] Ax1 = 8'h3B; reg [7:0] Ax2 = 8'h3C;
    //0x3D (ACCEL_YOUT_H) & 0x3E (ACCEL_YOUT_L) 
    reg [7:0] Ay1 = 8'h3D; reg [7:0] Ay2 = 8'h3E;
    // 0x3F (ACCEL_ZOUT_H) & 0x40 (ACCEL_ZOUT_L)
    reg [7:0] Az1 = 8'h3F; reg [7:0] Az2 = 8'h40;

    // Variables to store the values of the giroscopio, 16 bits signed
    reg signed [15:0] actual_value = 0;
    reg signed [15:0] previus_value = 0;

    // Giroscopio output
    reg enable_caminar = 0; // flag to enable output wire caminar 
    assign caminar = (enable_caminar) ? 1 : 0;

    // Estados de la maquina de estados
    localparam IDLE = 0, READ_BYTE_1 = 1, READ_BYTE_2 = 2, STOP = 3;
    reg [0:1] state = 0; // 2 bits for 4 states

    // flags
    reg byte1_read = 0; // flag to know if the first byte was received
    reg byte2_read = 0; // flag to know if the second byte was received
    
    // STATE MACHINE
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else if (detener_giroscopio && (state != STOP) && (state != IDLE)) 
            state <= STOP;
        else begin
            case(state)
            IDLE:
                state <= (iniciar_giroscopio) ? READ_BYTE_1 : state;
            READ_BYTE_1:
                state <= (byte1_read) ? STOP : state;
            READ_BYTE_2:
                state <= (byte2_read) ? STOP : state;
            STOP: begin
                if (detener_giroscopio) begin
                    state <= IDLE;
                end else if (avail_i2c_master)
                    if ((byte1_read == 0) && (byte2_read ==0)) begin
                        state <= READ_BYTE_1;
                    end else if (byte1_read)
                        state <= READ_BYTE_2;
                else begin
                    state <= STOP;
                end
            end
            default:
                state <= IDLE;
            endcase
        end
    end


    // OUTPUT LOGIC
    always @(state or clk) begin
        case(state)
        IDLE: begin
            enable_start <= 0;
            enable_stop <= 0;
            reg_data_in <= 0;
            byte1_read <= 0;
            byte2_read <= 0;
            enable_caminar <= 0;
            previus_value <= 0;
            actual_value <= 0;
        end
        READ_BYTE_1: begin
            enable_start <= 1;
            enable_stop <= 0;
            reg_data_in <= Ax1;
            if (avail_data_out) begin
                // TODO: previus_value si toma el valor de actual_value y actual_value de data_out?? 
                // o como todo está sincronizando con el reloj, entonces todo termina valiendo lo mismo??
                previus_value <= actual_value;
                actual_value[15:8] <= data_out[7:0]; // save the first byte of the Ax
                byte1_read <= 1;
            end 
        end
        READ_BYTE_2: begin
            enable_start <= 1;
            enable_stop <= 0;
            reg_data_in <= Ax2;
            if (avail_data_out) begin
                actual_value[7:0] <= data_out[7:0]; // save the second byte of the Ax
                byte2_read <= 1;
            end
            /* TODO: Preguntar si se puede hacer la comparación de esta manera 
            La idea es calcular el valor absoluto de la resta para que no importe la dirección del movimiento */ 
            if ((previus_value - actual_value > MIN_DIST) || (previus_value - actual_value < -MIN_DIST))
                enable_caminar <= 1;
            else
                enable_caminar <= 0;
        end
        STOP: begin
            enable_stop <= 1;
            enable_start <= 0;
            if (avail_i2c_master && byte1_read && byte2_read) begin
                byte1_read <= 0;
                byte2_read <= 0;
            end
        end
        endcase
    end

endmodule