`include "DivisorReloj.v"

module i2c_master #(parameter DIV_FACTOR = 16, SLAVE_ADDRESS = 7'h68)(
   input wire clk,                // System clock
   input wire reset,              // Reset signal
   input wire start,              // Signal to start transmission
   input wire [7:0] data_in,      // Regiter address that I2C master wants to read/write, 8 bits
   inout wire SDA_BUS,            // Serial Data
   output wire SCL_BUS,           // Serial Clock
   output reg [7:0] data_out,     // Received data
   output wire data_out_available,     // Flag to indicate that the data was fully read
   output wire i2c_master_available    // Flag to indicate that the I2C master is available
);

// Instantiate the divisorReloj module
wire clk_scl;
DivisorReloj #(4) clk_giroscopio (
   .clk_in(clk_4x),
   .reset(reset),
   .clk_out(clk_scl)
);

wire clk_4x;
DivisorReloj #(DIV_FACTOR) uut_clk (
   .clk_in(clk),
   .reset(reset),
   .clk_out(clk_4x)
);

// Declare internal signals
reg enable_scl = 1; // habilita el bus scl
reg enable_sda = 1; // habilita el bus sda
reg sda = 1;
reg scl = 1;
wire highZ = 1'bz;

reg [6:0] shift_address = 0; // slave adrress, 7 bits
reg [7:0] shift_reg_data = 0; // register address to read/write, 8 bits
reg bit_read_write = 1; // 1 to read, 0 to write

// counters
reg [1:0] counter_start = 0; // counter for start signal
reg [1:0] counter_stop = 0; // counter for stop signal
reg [7:0] counter_address = 0; // counter for address
reg [7:0] counter_reg_data = 0; // counter for register to read
reg [8:0] counter_read_data = 0; // counter for data
reg [3:0] counter_ack = 0; // counter for ack

// flags to change fsm_state
reg active_i2c = 0; // indica si la señal de inicio fue enviada, es decir, si la transmision esta activa
reg slave_configured = 0; // indica si la direccion del esclavo + el bit de lectura fue enviado
reg register_address_sent = 0; // indica si la direccion del registro que se quiere leer fue enviada
reg ack1_received = 0; // indica si el ACK del slave fue recibido
reg ack2_received = 0; // indica si el ACK del slave fue recibido
reg back_to_idle = 0; // flag to return to idle fsm_state
reg stop = 0;

// flags to indicate that the data was fully read
reg enable_data_out = 0;

// Declare states
localparam IDLE = 0, START = 1, SET_SLAVE = 2, WAIT_ACK_1 = 3, SENT_REG = 4, WAIT_ACK_2 = 5, READ = 6, STOP = 7;
reg [0:2] fsm_state = 0; // fsm_state machine, 8 states
reg [0:2] next = 0;


// STATE MACHINE
always @(posedge clk_4x)begin
   if(reset == 0)begin
        fsm_state <= IDLE;
   end else begin
        fsm_state <= next;
   end
end

always @(*) begin
   case(fsm_state)
      IDLE:
        next <= (start) ? START : next;
      START:
        next <= (active_i2c) ? SET_SLAVE : next;
      SET_SLAVE:
        next <= (slave_configured) ? WAIT_ACK_1 : next;
      WAIT_ACK_1:
        next <= (ack1_received) ? SENT_REG : next;
      SENT_REG:
        next <= (register_address_sent) ? WAIT_ACK_2 : next;
      WAIT_ACK_2:
        next <= (ack2_received) ? READ : next;
      READ:
         next <= (stop) ? STOP : next;
      STOP:
        next <= (back_to_idle) ? IDLE : next;
      default:
        next <= IDLE;
   endcase
end

// OUTPUT LOGIC
always @ (posedge clk_4x) begin
   case(next)
      IDLE: begin
         sda <= 1;
         scl <= 1;
         enable_scl <= 1; // flag
         enable_sda <= 1; // flag
         shift_address <= 0; // slave adrress, 7 bits
         shift_reg_data <= 0; // register address to read/write, 8 bits
         data_out <= 0; // reset data_out
         counter_start <= 0; // counter for start signal
         counter_stop <= 0; // counter for stop signal
         counter_address <= 0; // counter for address
         counter_reg_data <= 0; // counter for register to read (1) or write (0)
         counter_ack <= 0; // counter for ack
         counter_read_data <= 0; // counter for data
         active_i2c <= 0; // flag to change fsm_state
         slave_configured <= 0; // flag to change fsm_state
         register_address_sent <= 0; // flag to change fsm_state
         ack1_received <= 0; // flag to change fsm_state
         ack2_received <= 0; // flag to change fsm_state
         enable_data_out <= 0; // flag to change fsm_state
         back_to_idle <= 0; // flag to change fsm_state
      end
      START: begin 
         shift_address <= SLAVE_ADDRESS;
         shift_reg_data <= data_in;
         case (counter_start)
            0: begin sda <= 0; scl <= 1; counter_start <= 1; end 
            1: begin sda <= 0; scl <= 0; counter_start <= 2; end
            2: begin counter_start <= 0; active_i2c <= 1; sda <= SLAVE_ADDRESS[6];  end
         endcase
      end
      SET_SLAVE: begin
         case(counter_address)
            0: begin   shift_address <= shift_address << 1; counter_address <= 1; enable_scl = 0; end
            6: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 7; end
            14: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 15; end
            22: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 23; end
            30: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 31; end
            38: begin sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 39; end
            46: begin sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 47; end
            54: begin sda <= bit_read_write; shift_address <= shift_address << 1; counter_address <= 55; end
            62: begin sda = 1'bz; enable_sda <= 0; counter_address <= 0; slave_configured <= 1; end
            default:
               counter_address <= counter_address + 1;
         endcase
      end
      WAIT_ACK_1: begin
         case (counter_ack)
            0: begin counter_ack <= 1; end
            7: begin  sda = 0; enable_sda = 1; counter_ack <= 0; sda <= shift_reg_data[7]; ack1_received <= 1; end 
            default:
            counter_ack <= counter_ack+1;
         endcase
      end 
      SENT_REG: begin  
         case(counter_reg_data)
             0: begin  shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 1; enable_scl = 0; end
             7: begin  sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 8; end
             15: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 16; end
             23: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 24; end
             31: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 32; end
             39: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 40; end
             47: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 48; end
             55: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 56; end
             63: begin sda <= 1'bz; enable_sda <= 0; counter_reg_data <= 0; register_address_sent <= 1; end  
             default:
                 counter_reg_data <= counter_reg_data + 1;
         endcase
      end
      WAIT_ACK_2: begin
         case (counter_ack)
            0: begin counter_ack <= 1; end
            7: begin counter_ack <= 0; sda = 1'bz; enable_sda = 0; ack2_received <= 1; end
            default:
               counter_ack <= counter_ack + 1;
         endcase
      end
      READ: begin
         case (counter_read_data)
             3: begin data_out[7] <= SDA_BUS; counter_read_data <= 4; end // most significant bit
             11: begin data_out[6] <= SDA_BUS; counter_read_data <= 12; end
             19: begin data_out[5] <= SDA_BUS; counter_read_data <= 20; end
             27: begin data_out[4] <= SDA_BUS; counter_read_data <= 28; end
             35: begin data_out[3] <= SDA_BUS; counter_read_data <= 36; end
             43: begin data_out[2] <= SDA_BUS; counter_read_data <= 44; end
             51: begin data_out[1] <= SDA_BUS; counter_read_data <= 52; end
             59: begin data_out[0] <= SDA_BUS; counter_read_data <= 60; end // least significant bit, end of data
             63: begin sda = 0; enable_sda = 1; enable_data_out <= 1; counter_read_data <= 64; end // ACK from master
             71: begin stop = 1;  enable_data_out <= 0; counter_read_data <= 0; data_out = 0; end // Free bus and reset counter
             default:
                 counter_read_data <= counter_read_data + 1;
         endcase
      end
      STOP: begin
         counter_stop <= counter_stop + 1;
         case(counter_stop) 
            0: begin enable_sda <= 1; sda <= 0; enable_scl <= 1; scl <= 0; end
            2: begin sda <= 0; scl <= 1; end
            3: begin sda <= 1; scl <= 1; back_to_idle <= 1; counter_stop <= 0; end
         endcase
      end    
   endcase
end


//assign highZ = (sda) ? 1'bz : 1'b0;
//assign SDA_BUS = (enable_sda) ? highZ : 1'bz;
assign SDA_BUS = (enable_sda) ? sda : 1'bz;
assign SCL_BUS = (enable_scl) ? scl : clk_scl;
assign data_out_available = (enable_data_out) ? 1 : 0;
assign i2c_master_available = (fsm_state == IDLE) ? 1 : 0;


endmodule
