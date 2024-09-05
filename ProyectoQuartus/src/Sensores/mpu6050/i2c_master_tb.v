`timescale 1ns / 1ps // Time scale is set to 1ns with 1ps resolution
`include "i2c_master.v" // Include the i2c_master module

module i2c_master_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 50 MHz clock
    parameter DIV_FACTOR = 16; // 2480 ns period, 403.2258 kHz
    parameter CLKR_PERIOD = (1/(50e6/(DIV_FACTOR*2*4)))*1e9; // 
    parameter TEST_TIME = CLKR_PERIOD*80;
    parameter ACK1_DELAY = 39340;
    parameter ACK1_WAIT = 5120;
    parameter ACK2_DELAY = 40960;
    

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg start;

    // Bidirectional
    wire SDA_BUS;
  
    // Outputs
    wire SCL_BUS;
    wire [7:0] data_out;
    wire data_out_available;
    wire i2c_master_available;

    parameter slave_address = 7'b1010101; // this is an example, real default address of mpu6050 (slave) is 0x68

    // Instantiate the i2c_master
    i2c_master #(.DIV_FACTOR(DIV_FACTOR) ,.SLAVE_ADDRESS(slave_address)) uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .SDA_BUS(SDA_BUS),
        .SCL_BUS(SCL_BUS),
        .data_out(data_out),
        .data_out_available(data_out_available),
        .i2c_master_available(i2c_master_available)
    );
    
    reg [7:0] data_out_reg;
    reg sda_enable;
    reg sda_reg;
    assign SDA_BUS = sda_enable ? sda_reg: 1'bz;
    
    // Clock process
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        start = 0;
        sda_enable = 0;
        sda_reg = 0;
        data_in = 8'b10101011;  // example of register address to read
        data_out_reg = 8'b10101011; // simulation of data sent by giroscopio
        

        // Reset
        #(CLK_PERIOD) reset = 0;
        #(CLK_PERIOD) reset = 1;


        // Apply start signal and data
        #(CLK_PERIOD) start = 1;
        #(CLKR_PERIOD) start = 0;


        // Send Acknowledge 1 for slave address
        #ACK1_DELAY sda_enable = 1;
        #(ACK1_WAIT) sda_enable = 0;

        // Send Acknowledge 2 for slave address
        #ACK2_DELAY sda_enable = 1;
        #(ACK1_WAIT)    begin sda_reg = data_out_reg[7]; end

         // Simulate slave sending data
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[6];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[5];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[4];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[3];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[2];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[1];
        #(CLKR_PERIOD*2) sda_reg = data_out_reg[0];
        #(CLKR_PERIOD*2) begin sda_enable = 0; sda_reg = 1'bz; end
        //#(CLK_PERIOD*2) sda_enable = 1;

    end
    
	initial begin: TEST_CASE
     $dumpfile("i2c_master_tb.vcd");
     $dumpvars(-1, uut);
     #(TEST_TIME) $finish;
    end


endmodule
