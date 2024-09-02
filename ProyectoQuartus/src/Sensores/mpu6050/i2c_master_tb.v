`timescale 1ns / 1ps // Time scale is set to 1ns with 1ps resolution
`include "i2c_master.v" // Include the i2c_master module

module i2c_master_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 50 MHz clock
    parameter DIV_FACTOR = 62; // 2480 ns period, 403.2258 kHz
    parameter CLKR_PERIOD = (1/(50e6/(DIV_FACTOR*2)))*1e9; // 
    parameter TEST_TIME = CLKR_PERIOD*40;
    parameter ACK1_DELAY = 4880 + CLKR_PERIOD*8;
    parameter ACK2_DELAY = CLKR_PERIOD*9;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] data_in;
    reg [6:0] slave_address;
    reg start;
    reg stop;

    // Bidirectional
    wire SDA_BUS;
  
    // Outputs
    wire SCL_BUS;
    wire [7:0] data_out;
    wire avail_data_out;
    wire avail_i2c_master;

    // Instantiate the i2c_master
    i2c_master #(DIV_FACTOR) uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .slave_address(slave_address),
        .start(start),
        .stop(stop),
        .SDA_BUS(SDA_BUS),
        .SCL_BUS(SCL_BUS),
        .data_out(data_out),
        .avail_data_out(avail_data_out),
        .avail_i2c_master(avail_i2c_master)
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
        stop = 0;
        sda_enable = 0;
        sda_reg = 0;
        data_in = 7'b0110001;  // Data to send
        data_out_reg = 8'b11110000; // Data to receive
        slave_address <= 7'b1101000; // 0x68 default address of mpu6050 (slave)

        // Reset
        #(CLK_PERIOD) reset = 0;
        #(CLK_PERIOD) reset = 1;

        // Apply start signal and data
        #(CLK_PERIOD) start = 1;
        #(CLK_PERIOD) start = 0;

        // Send Acknowledge 1 for slave address
        #ACK1_DELAY sda_enable = 1;
        #(CLKR_PERIOD) sda_enable = 0;

        // Send Acknowledge 2 for register address to read
        #ACK2_DELAY sda_enable = 1;
        //#(CLKR_PERIOD) sda_enable = 0;

        // Simulate slave sending data
        #(CLKR_PERIOD) sda_reg = data_out_reg[7];
        #(CLKR_PERIOD) sda_reg = data_out_reg[6];
        #(CLKR_PERIOD) sda_reg = data_out_reg[5];
        #(CLKR_PERIOD) sda_reg = data_out_reg[4];
        #(CLKR_PERIOD) sda_reg = data_out_reg[3];
        #(CLKR_PERIOD) sda_reg = data_out_reg[2];
        #(CLKR_PERIOD) sda_reg = data_out_reg[1];
        #(CLKR_PERIOD) sda_reg = data_out_reg[0];
        #(CLKR_PERIOD) begin sda_enable = 0; sda_reg = 1'bz; end
        #(CLK_PERIOD) sda_enable = 1;

        #(CLKR_PERIOD) sda_reg = data_out_reg[7];
        #(CLKR_PERIOD) sda_reg = data_out_reg[6];
        #(CLKR_PERIOD) sda_reg = data_out_reg[5];
        #(CLKR_PERIOD) sda_reg = data_out_reg[4];
        #(CLKR_PERIOD) sda_reg = data_out_reg[3];
        #(CLKR_PERIOD) sda_reg = data_out_reg[2];
        #(CLKR_PERIOD) sda_reg = data_out_reg[1];
        #(CLKR_PERIOD) sda_reg = data_out_reg[0];
        #(CLKR_PERIOD) begin sda_enable = 0; sda_reg = 1'bz; end
        #(CLK_PERIOD) sda_enable = 1;

        // Apply stop signal
        #(CLKR_PERIOD) begin stop = 1; sda_enable = 0; end
        #19 stop = 0;
        
    end
    
	initial begin: TEST_CASE
     $dumpfile("i2c_master_tb.vcd");
     $dumpvars(-1, uut);
     #(TEST_TIME) $finish;
    end


endmodule
