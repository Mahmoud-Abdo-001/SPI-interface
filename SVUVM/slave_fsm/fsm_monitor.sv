class fsm_monitor extends uvm_monitor;
    `uvm_component_utils(fsm_monitor)

    virtual fsm_if fsm_vif;
    fsm_sequence_item rsp_seq_item;
    uvm_analysis_port #(fsm_sequence_item) mon_ap;

    function new(string name = "fsm_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        if(!uvm_config_db#(virtual fsm_if)::get(this, "", "fsmV", fsm_vif))
            `uvm_fatal("NOVIF", "fsm_if not found")
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge fsm_vif.clk iff fsm_vif.rst_n); // Sync to clock and active reset
                
                rsp_seq_item = fsm_sequence_item::type_id::create("rsp_seq_item");
                
                // Capture current state
                rsp_seq_item.rst_n      = fsm_vif.rst_n;
                rsp_seq_item.ss_n       = fsm_vif.ss_n;
                rsp_seq_item.rx_valid   = fsm_vif.rx_valid;
                rsp_seq_item.rx_data    = fsm_vif.rx_data;
                rsp_seq_item.tx_data    = fsm_vif.tx_data;
                rsp_seq_item.tx_valid   = fsm_vif.tx_valid;
                rsp_seq_item.sready     = fsm_vif.sready;
                rsp_seq_item.valid_MISO = fsm_vif.valid_MISO;
                rsp_seq_item.MISO       = fsm_vif.MISO;
                rsp_seq_item.MOSI       = fsm_vif.MOSI;
                
                
                mon_ap.write(rsp_seq_item);
                
                // `uvm_info("FSM_MON", $sformatf("Sampled FSM state - SS_N: %b, RX_VALID: %b, TX_VALID: %b",
                //     fsm_vif.ss_n, fsm_vif.rx_valid, fsm_vif.tx_valid), UVM_HIGH)
            end
    endtask

endclass