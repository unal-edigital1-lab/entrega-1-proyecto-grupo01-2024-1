//`include "i2c_master.v"

module test #(parameter SLAVE_ADDRESS = 7'h68)(
    //INPUTS
    input wire clk,
    input wire reset,
    input wire enable_giroscopio,
    inout wire SDA_BUS,
    //OUTPUTS
    output wire SCL_BUS);
    

    // I2C Master outputs
    wire [7:0] data_out;
    wire data_out_available;
    wire i2c_master_available;
    reg start = 1;
    //0x3B (ACCEL_XOUT_H) & 0x3C (ACCEL_XOUT_L)
    localparam address_Ax1 = 8'h3B; localparam address_Ax2 = 8'h3C;
    reg [7:0] reg_data_in = address_Ax1; // Register that I2C master wants to read

    // I2C Master instance
    //reg [6:0] SLAVE_ADDRESS = 7'b1101000; // 0x68 default address of mpu6050 (slave)
    i2c_master #(.SLAVE_ADDRESS(SLAVE_ADDRESS)) i2c_inst(
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(reg_data_in),
        .SDA_BUS(SDA_BUS),
        .SCL_BUS(SCL_BUS),
        .data_out(data_out),
        .data_out_available(data_out_available),
        .i2c_master_available(i2c_master_available)
    );


endmodule