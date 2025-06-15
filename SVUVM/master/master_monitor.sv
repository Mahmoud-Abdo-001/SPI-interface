class master_monitor extends uvm_monitor;
  `uvm_component_utils(master_monitor)

  virtual master_if m_vif; // Correct interface with modport
  master_sequence_item rsp_seq_item;
  uvm_analysis_port #(master_sequence_item) mon_ap;

  function new(string name = "master_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_ap = new("mon_ap", this);

    if(!uvm_config_db#(virtual master_if)::get(this, "", "masterV", m_vif))
        `uvm_fatal("NOVIF", "master_if not found")
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      @(posedge m_vif.clk);  // synchronous sampling
      
      rsp_seq_item = master_sequence_item::type_id::create("rsp_seq_item");

      // Capture values from monitored interface
      rsp_seq_item.rst_n      = m_vif.rst_n;
      rsp_seq_item.start      = m_vif.start;
      rsp_seq_item.data_in    = m_vif.data_in;

      rsp_seq_item.MISO       = m_vif.MISO;
      rsp_seq_item.valid_MISO = m_vif.valid_MISO;
      rsp_seq_item.sready     = m_vif.sready;

      // These may be reflected internally depending on your DUT design
      // If your DUT drives them on this interface, include them:
      rsp_seq_item.MOSI       = m_vif.MOSI;
      rsp_seq_item.ss_n       = m_vif.ss_n;
      rsp_seq_item.data_out   = m_vif.data_out;
      rsp_seq_item.busy       = m_vif.busy;
      rsp_seq_item.done       = m_vif.done;

      mon_ap.write(rsp_seq_item);
    end
  endtask

endclass
