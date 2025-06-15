interface ram_if(input logic clk);
    logic rst_n;
    logic rx_valid;
    logic [9:0] din ;
    logic tx_valid;
    logic [7:0] dout;

    modport DUT (
    input clk,rst_n,din,rx_valid,
    output dout,tx_valid
    );
    
endinterface //ram_if
