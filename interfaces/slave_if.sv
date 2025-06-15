interface slave_if(input logic clk);

    logic rst_n;

    logic ss_n;     // Active-low chip select 
    logic MOSI;     // Data input from master
    logic MISO;    // Data output to master
    logic valid_MISO;
    logic sready ;  // Indicates slave is ready


    // modport DUT (
    // input clk,rst_n,ss_n,MOSI,
    // output sready,valid_MISO,MISO
    // );

endinterface //s_if