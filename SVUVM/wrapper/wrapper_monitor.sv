class wrapper_monitor extends uvm_monitor;
  `uvm_component_utils(wrapper_monitor)

  virtual wrapper_if.Monitor m_vif; 
  wrapper_seq_item rsp_seq_item;
  uvm_analysis_port #(wrapper_seq_item) mon_ap;

  function new(string name = "wrapper_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_ap = new("mon_ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      @(posedge m_vif.clk);

      // Optionally filter out incomplete/inactive transactions
      if (m_vif.done == 1'b1) begin
        rsp_seq_item = wrapper_seq_item::type_id::create("rsp_seq_item");

        rsp_seq_item.rst_n     = m_vif.rst_n;
        rsp_seq_item.start     = m_vif.start;
        rsp_seq_item.data_in   = m_vif.data_in;
        rsp_seq_item.data_out  = m_vif.data_out;
        rsp_seq_item.busy      = m_vif.busy;
        rsp_seq_item.done      = m_vif.done;

        mon_ap.write(rsp_seq_item);
      end
    end
  endtask

endclass
