interface wrapper_if(input logic clk);

  logic rst_n;
  logic start;          
  logic [9:0] data_in;  

  logic [7:0] data_out;
  logic busy;        
  logic done;

  // Driver modport 
  modport drv (
    input clk,done,
    output rst_n, start, data_in  // driver drives these
  );

  // Monitor modport (passive observation of all signals)
  modport Monitor (
    input clk, rst_n, start, data_in, data_out, busy, done
  );

endinterface : wrapper_if
