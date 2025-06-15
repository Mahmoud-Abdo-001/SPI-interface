class master_agent extends uvm_agent;
    `uvm_component_utils(master_agent)
    
    master_monitor      monitor;
    uvm_analysis_port #(master_sequence_item) master_agt_ap;
    
    // Proper constructor with name argument
    function new(string name, uvm_component parent  = null);
        super.new(name, parent);
        master_agt_ap = new("master_agt_ap",this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        monitor = master_monitor::type_id::create("monitor", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        monitor.mon_ap.connect(this.master_agt_ap); // Expose monitor's analysis port
    endfunction
endclass