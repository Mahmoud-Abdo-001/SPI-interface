class master_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(master_sequence_item)
  
    logic rst_n;
    logic sclk;

    logic start;          
    rand logic [9:0] data_in; 
    logic [7:0] data_out; 
    logic busy;
    logic done;          

    logic MOSI;
    logic ss_n;
    logic MISO;
    logic valid_MISO;
    logic sready;

  function new(string name = "master_sequence_item");
    super.new(name);
  endfunction

  //constrain
  
endclass
