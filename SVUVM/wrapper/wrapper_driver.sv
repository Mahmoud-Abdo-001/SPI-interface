class wrapper_driver extends uvm_driver #(wrapper_seq_item);
  `uvm_component_utils(wrapper_driver)

  virtual wrapper_if.drv d_vif;
  wrapper_seq_item stim_seq_item;

  function new(string name = "wrapper_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Reset phase
    @(posedge d_vif.clk);
    d_vif.rst_n   <= 1'b0;
    d_vif.start   <= 1'b0;
    d_vif.data_in <= '0;
    repeat (5) @(posedge d_vif.clk);
    d_vif.rst_n <= 1'b1;

    forever begin
      seq_item_port.get_next_item(stim_seq_item);

      // Wait until `done` is deasserted before starting a new transaction
      wait (d_vif.done == 1'b0);

      // Apply input
      @(posedge d_vif.clk);
      d_vif.data_in <= stim_seq_item.data_in;
      d_vif.start   <= 1'b1;

      // Pulse `start` for one cycle
      @(posedge d_vif.clk);
      d_vif.start <= 1'b0;

      // Wait until done is asserted
      wait (d_vif.done == 1'b1);

      // Optional: wait 1 cycle after done for safety
      @(posedge d_vif.clk);

      seq_item_port.item_done();
    end
  endtask
endclass
