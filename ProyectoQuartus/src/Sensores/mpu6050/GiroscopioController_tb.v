`timescale 1ns / 1ps // Time scale is set to 1ns with 1ps resolution
`include "GiroscopioController.v" // Include the GiroscopioController module

module GiroscopioController_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 50 MHz clock
    parameter DIV_FACTOR = 62; // 2480 ns period, 403.2258 kHz
    parameter CLKR_PERIOD = (1/(50e6/(DIV_FACTOR*2)))*1e9; // 
    parameter TEST_TIME = CLKR_PERIOD*40;
    parameter RESET_DELAY = CLKR_PERIOD/2;
    parameter START_DELAY = CLKR_PERIOD/2;
    parameter ACK1_DELAY = 2480 + CLKR_PERIOD*8; 
    parameter ACK2_DELAY = CLKR_PERIOD*8;

    // Inputs
    reg clk;
    reg reset;
    reg enable_giroscopio;

    // Bidirectional
    wire SDA_BUS;
  
    // Outputs
    wire SCL_BUS;
    wire mover;

    // Instantiate the GiroscopioController module
    GiroscopioController uut (
        .clk(clk),
        .reset(reset),
        .SDA_BUS(SDA_BUS),
        .SCL_BUS(SCL_BUS),
        .enable_giroscopio(enable_giroscopio),
        .mover(mover)
    );
    
    reg [7:0] data_out_reg;
    reg sda_enable;
    reg sda_reg;
    assign SDA_BUS = sda_enable ? sda_reg: 1'bz;

    integer i;
    
    // Clock process
    always begin
        #CLK_PERIOD clk = ~clk;
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        enable_giroscopio = 0;
        sda_enable = 0;
        sda_reg = 0;
        data_out_reg = 8'b11110000; // Data to receive

        // Reset
        #RESET_DELAY reset = 0;
        #CLK_PERIOD reset = 1;

        // enable_giroscopio signal to start the giroscopio controller
        #START_DELAY enable_giroscopio = 1;
        
        for (i = 0; i < 4; i = i + 1) begin
            // Start byte trasmission

            // Master sends slave address

            // Slave send ACK
            #(ACK1_DELAY + 30) sda_enable = 1;
            #(CLKR_PERIOD) sda_enable = 0;

            // Master sends register address to read

            // Slave send ACK 
            #ACK2_DELAY sda_enable = 1;
            
            // Slave sends data to master
            #(CLKR_PERIOD) sda_reg = data_out_reg[7];
            #(CLKR_PERIOD) sda_reg = data_out_reg[6];
            #(CLKR_PERIOD) sda_reg = data_out_reg[5];
            #(CLKR_PERIOD) sda_reg = data_out_reg[4];
            #(CLKR_PERIOD) sda_reg = data_out_reg[3];
            #(CLKR_PERIOD) sda_reg = data_out_reg[2];
            #(CLKR_PERIOD) sda_reg = data_out_reg[1];
            #(CLKR_PERIOD) sda_reg = data_out_reg[0]; 

            #(CLKR_PERIOD) begin sda_enable = 0; sda_reg = 1'bz; end // Free the bus for master send ACK
 
            #(3680) sda_reg = 0; // Finish byte transmission

        end

    #(CLKR_PERIOD) enable_giroscopio = 0;
    $finish;
    end
    
	initial begin: TEST_CASE
     $dumpfile("GiroscopioController_tb.vcd");
     $dumpvars(-1, uut);
     //#(TEST_TIME) $finish;
    end


endmodule
