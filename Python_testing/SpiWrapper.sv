///////////////////////////////////////////
// AUTHER : Mahmoud Abdo
// Module : SpiWrapper.sv
//
// Description : 
// Date : june 2025
///////////////////////////////////////////////////////
module SpiWrapper (
    input logic clk,
	input logic rst_n,

    // Interface to User/Controller
    input logic start,          // Input: Start transaction signal (pulse)
    input logic [9:0] data_in,  // Input: 10-bit data/command to send
	output logic [7:0] data_out, // Output: 8-bit data received from slave (for read ops)
    output logic busy,         // Output: Master is busy with a transaction
    output logic done          // Output: Transaction completed (pulse)
);

// buses and nets 
logic MOSI;
logic ss_n;
logic MISO;
logic valid_MISO;
logic sready;
logic sclk;

SPI_Master MASTER(
    .clk(clk),
    .rst_n(rst_n),
	.sclk(sclk),
    .start(start),         
    .data_in(data_in), 
    .data_out(data_out),
    .busy(busy),         
    .done(done),   
    // to slave 
    .MOSI(MOSI),
    .ss_n(ss_n),
    .MISO(MISO),
    .valid_MISO(valid_MISO),
    .sready(sready)
);

SPI_Slave SLAVE(
    .clk(sclk),
	.rst_n(rst_n), 
	.ss_n(ss_n),   // active low chip (slave) select 
	.MOSI(MOSI),
    .MISO(MISO), 
	.valid_MISO(valid_MISO),
    .sready(sready)
);

endmodule