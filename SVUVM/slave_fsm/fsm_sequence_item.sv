class fsm_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(fsm_sequence_item)
  
  // Inputs to DUT
  rand bit rst_n;
  rand bit ss_n;
  rand bit MOSI;
  rand bit tx_valid;
  rand bit [7:0] tx_data;

  // Outputs from DUT (captured from monitor later)
  bit sready;
  bit MISO;
  bit valid_MISO;
  bit rx_valid;
  bit [9:0] rx_data;

  function new(string name = "fsm_sequence_item");
    super.new(name);
  endfunction
endclass
