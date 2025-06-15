interface fsm_if(input logic clk);
    logic rst_n;
    logic ss_n;
   
    logic MOSI;
    logic tx_valid;
    logic [7:0] tx_data;


    // output
    logic sready;
    logic MISO;
    logic valid_MISO;
    logic rx_valid;
    logic [9:0] rx_data;

    modport DUT (
    input clk,rst_n,MOSI,ss_n,tx_data,tx_valid,
    output MISO,valid_MISO,rx_valid,rx_data,sready
    );

endinterface //fsm_if
