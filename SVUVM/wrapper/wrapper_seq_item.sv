class wrapper_seq_item extends uvm_sequence_item;
  `uvm_object_utils(wrapper_seq_item)

  //====================//
  //  Data Members      //
  //====================//
  rand logic start;
  rand logic [9:0] data_in;

  logic rst_n;
  logic [7:0] data_out;
  logic busy;
  logic done;

  //====================//
  // Constructor        //
  //====================//
  function new(string name = "wrapper_seq_item");
    super.new(name);
  endfunction

  //====================//
  // Print Utility      //
  //====================//
function void do_print(uvm_printer printer);
  super.do_print(printer);
  printer.print_field("start"   , start   , $bits(start)   , UVM_DEC);
  printer.print_field("data_in" , data_in , $bits(data_in) , UVM_HEX);
  printer.print_field("data_out", data_out, $bits(data_out), UVM_HEX);
  printer.print_field("busy"    , busy    , $bits(busy)    , UVM_DEC);
  printer.print_field("done"    , done    , $bits(done)    , UVM_DEC);
endfunction


endclass
