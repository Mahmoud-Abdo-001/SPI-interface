class wrapper_agent extends uvm_agent;
  `uvm_component_utils(wrapper_agent)

  // Components
  wrapper_config_obj w_cfg;       // Configuration object
  wrapper_driver     drv;         // Driver
  wrapper_monitor    mon;         // Monitor
  sequencer    sqr;         // Sequencer

  // Analysis port to broadcast transactions
  uvm_analysis_port #(wrapper_seq_item) agt_ap;

  function new(string name = "wrapper_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Retrieve configuration object
    if (!uvm_config_db#(wrapper_config_obj)::get(this, "", "CFG", w_cfg)) begin
      `uvm_fatal("AGENT_CFG", "Unable to get configuration object from config DB")
    end

    // Component creation
    drv    = wrapper_driver   ::type_id::create("drv", this);
    mon    = wrapper_monitor  ::type_id::create("mon", this);
    sqr    = sequencer  ::type_id::create("sqr", this);
    agt_ap = new("agt_ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Interface binding
    drv.d_vif = w_cfg.wif;
    mon.m_vif = w_cfg.wif;

    // Sequencer-driver connection
    drv.seq_item_port.connect(sqr.seq_item_export);

    // Monitor-agent analysis connection
    mon.mon_ap.connect(agt_ap);
  endfunction

endclass
