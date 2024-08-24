`include "DivisorReloj.v"

module i2c_master #(parameter DIV_FACTOR = 62)(
   input wire clk,                // System clock
   input wire reset,              // Reset signal
   input wire start,              // Signal to start transmission
   input wire stop,               // Signal to stop transmission
   input wire [6:0] slave_address, // Slave address, 7 bits
   input wire [7:0] data_in,      // Regiter address that I2C master wants to read/write, 8 bits
   inout wire SDA_BUS,            // Serial Data
   output wire SCL_BUS,           // Serial Clock
   output reg [7:0] data_out,     // Received data
   output wire avail_data_out,     // Flag to indicate that the data was fully read
   output wire avail_i2c_master    // Flag to indicate that the I2C master is available
);

// Instantiate the divisorReloj module
wire clkr; // Clock output
DivisorReloj #(.DIV_FACTOR(DIV_FACTOR)) uut_clk (
   .clk(clk),
   .reset(reset),
   .clk_out(clkr)
);

// Declare internal signals
reg sda = 1;
reg scl = 1;

reg [6:0] shift_address = 0; // slave adrress, 7 bits
reg [7:0] shift_reg_data = 0; // register address to read/write, 8 bits
reg bit_read_write = 1; // 1 to read, 0 to write

// counters
reg [1:0] counter_start = 0; // counter for start signal
reg [1:0] counter_stop = 0; // counter for stop signal
reg [4:0] counter_address = 0; // counter for address
reg [4:0] counter_reg_data = 0; // counter for register to read
reg [4:0] counter_data = 0; // counter for data
reg [1:0] counter_ack = 0; // counter for ack

// flags to change state
reg enable_scl = 1; // habilita el bus scl
reg enable_sda = 1; // habilita el bus sda
reg active_i2c = 0; // indica si la señal de inicio fue enviada, es decir, si la transmision esta activa
reg slave_configured = 0; // indica si la direccion del esclavo + el bit de lectura fue enviado
reg register_address_sent = 0; // indica si la direccion del registro que se quiere leer fue enviada
reg ack1_received = 0; // indica si el ACK del slave fue recibido
reg ack2_received = 0; // indica si el ACK del slave fue recibido
reg NACK = 0; // flag to indicate that NACK was received from slave 
reg back_to_idle = 0; // flag to return to idle state

// flags to indicate that the data was fully read
reg enable_data_out = 0;
reg OUTPUT_CHANGE = 0; // flag to register a change in the output

// Declare states
localparam IDLE = 0, START = 1, SET_SLAVE = 2, WAIT_ACK_1 = 3, SENT_REG = 4, WAIT_ACK_2 = 5, READ = 6, STOP = 7;
reg [0:2] state = 0; // state machine, 8 states

// STATE MACHINE
always @(posedge clk) begin
   if (reset == 1) begin
      state <= IDLE;
   end else if ((stop == 1) && (state != STOP) && (state != IDLE)) begin
      state <= STOP;
   end else begin
      case(state)
      IDLE:
         state <= (start) ? START : state;
      START:
         state <= (active_i2c) ? SET_SLAVE : state;
      SET_SLAVE:
         state <= (slave_configured) ? WAIT_ACK_1 : state;
      WAIT_ACK_1:
         state <= (ack1_received) ? SENT_REG : state;
      SENT_REG:
         state <= (register_address_sent) ? WAIT_ACK_2 : state;
      WAIT_ACK_2:
         state <= (ack2_received) ? READ : state;
      READ:
         state <= (stop || NACK) ? STOP : state;
      STOP:
         state <= (back_to_idle) ? IDLE : state;
      default:
         state <= IDLE;
      endcase
   end

end

assign SDA_BUS = (enable_sda) ? sda : 1'bz;
assign SCL_BUS = (enable_scl) ? scl : clkr;
assign avail_data_out = (enable_data_out) ? 1 : 0;
assign avail_i2c_master = (state == IDLE) ? 1 : 0;

// OUTPUT LOGIC
always @ (clkr or state) begin
   case(state)
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
         counter_data <= 0; // counter for data
         active_i2c <= 0; // flag to change state
         slave_configured <= 0; // flag to change state
         register_address_sent <= 0; // flag to change state
         ack1_received <= 0; // flag to change state
         ack2_received <= 0; // flag to change state
         NACK = 0; // flag to indicate that NACK was received from slave
         enable_data_out <= 0; // flag to change state
         back_to_idle <= 0; // flag to change state
      end
      START: begin 
         shift_address <= slave_address;
         shift_reg_data <= data_in;
         case (counter_start)
            0: begin sda <= 0; scl <= 1; counter_start <= 1; end 
            1: begin sda <= 0; scl <= 0; counter_start <= 2; end
            2: begin counter_start <= 0; active_i2c <= 1; enable_scl = 0; end
         endcase
      end
      SET_SLAVE: begin
         case(counter_address)
            0: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 1; end
            2: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 3; end
            4: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 5; end
            6: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 7; end
            8: begin  sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 9; end
            10: begin sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 11; end
            12: begin sda <= shift_address[6]; shift_address <= shift_address << 1; counter_address <= 13; end
            14: begin sda <= bit_read_write; shift_address <= shift_address << 1; counter_address <= 15; end
            16: begin sda = 1'bz; enable_sda <= 0; counter_address <= 0; slave_configured <= 1; end
            default:
               counter_address <= counter_address + 1;
         endcase
      end
      WAIT_ACK_1: begin
         case (counter_ack)
            0: begin counter_ack <= 1; end
            1: begin counter_ack <= 2; end
            2: begin counter_ack <= 0; sda = 0; enable_sda = 1; ack1_received <= 1; end
         endcase
      end 
      SENT_REG: begin
         case(counter_reg_data)
           0: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 1; end
           2: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 3; end
           4: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 5; end
           6: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 7; end
           8: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 9; end
           10: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 11; end
           12: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 13; end
           14: begin sda <= shift_reg_data[7]; shift_reg_data <= shift_reg_data << 1; counter_reg_data <= 15; end
           16: begin sda <= 1'bz; enable_sda <= 0; counter_reg_data <= 0; register_address_sent <= 1; end  
           default:
              counter_reg_data <= counter_reg_data + 1;
         endcase
      end
      WAIT_ACK_2: begin
         case (counter_ack)
            0: begin counter_ack <= 1; end
            1: begin counter_ack <= 2; end
            2: begin counter_ack <= 0; sda = 1'bz; enable_sda = 0; ack2_received <= 1; end
         endcase
      end
      READ: begin
         case (counter_data)
            1: begin data_out[7] <= SDA_BUS; counter_data <= 2; end // most significant bit
            3: begin data_out[6] <= SDA_BUS; counter_data <= 4; end
            5: begin data_out[5] <= SDA_BUS; counter_data <= 6; end
            7: begin data_out[4] <= SDA_BUS; counter_data <= 8; end
            9: begin data_out[3] <= SDA_BUS; counter_data <= 10; end
            11: begin data_out[2] <= SDA_BUS; counter_data <= 12; end
            13: begin data_out[1] <= SDA_BUS; counter_data <= 14; end
            15: begin data_out[0] <= SDA_BUS; counter_data <= 16; end // least significant bit, end of data
            16: begin sda = 0; enable_sda = 1; enable_data_out <= 1; counter_data <= 17; end // ACK from master
            18: begin sda = 1'bz; enable_sda = 0; data_out = 0; enable_data_out <= 0; counter_data <= 1; end // Free bus and reset counter
            default:
               counter_data <= counter_data + 1;
         endcase
      end
      STOP: begin
         counter_stop <= counter_stop + 1;
         case(counter_stop) 
            0: begin enable_sda <= 1; sda <= 1; enable_scl <= 1; scl <= 0; end
            1: begin sda <= 0; scl <= 0;  end
            2: begin sda <= 0; scl <= 1; end
            3: begin sda <= 1; scl <= 1; back_to_idle <= 1; counter_stop <= 0; end
         endcase
      end    
   endcase
end
endmodule
