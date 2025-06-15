interface master_if(input logic clk);

    logic rst_n;
    logic sclk;

    logic start;          
    logic [9:0] data_in; 
    logic [7:0] data_out; 
    logic busy;
    logic done;          

    logic MOSI;
    logic ss_n;
    logic MISO;
    logic valid_MISO;
    logic sready;

    modport DUT (
    input clk,rst_n,start,data_in,MISO,valid_MISO,sready,
    output sclk,data_out,busy,done,MOSI,ss_n
    );

endinterface