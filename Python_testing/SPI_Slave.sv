module SPI_Slave (
    input logic clk,
    input logic rst_n, 

    input logic ss_n,     // Active-low chip select 
    input logic MOSI,     // Data input from master
    output logic MISO,    // Data output to master
    output logic valid_MISO,
    output logic sready   // Indicates slave is ready
);

    // Internal signals
    logic [9:0] rx_data;  // Data received from FSM
    logic [7:0] dout;     // Data output from RAM
    logic tx_valid;       // Data valid for transmission
    logic rx_valid;       // Data valid from FSM to RAM

    // FSM Instance
    FSM2 spi_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .ss_n(ss_n),
        .MOSI(MOSI),
        .tx_valid(tx_valid),      // Comes from RAM
        .tx_data(dout),           // Data from RAM
        .rx_valid(rx_valid),      // To RAM
        .rx_data(rx_data),        // To RAM
        .sready(sready),
        .valid_MISO(valid_MISO),
        .MISO(MISO)
    );

    // RAM Instance
    ram mem_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid),      // Write or read request from FSM
        .din(rx_data),            // Data + opcode from FSM
        .dout(dout),              // Read data to FSM
        .tx_valid(tx_valid)       // Data ready signal to FSM
    );

endmodule

