class ram_agent extends uvm_agent;
    `uvm_component_utils(ram_agent)
    
    ram_monitor      monitor;
    uvm_analysis_port #(ram_sequence_item) ram_agt_ap;
    
    // Proper constructor with name argument
    function new(string name, uvm_component parent  = null);
        super.new(name, parent);
        ram_agt_ap = new("ram_agt_ap",this);
    endfunction
    
    function void build_phase(uvm_phase phase);
        monitor = ram_monitor::type_id::create("monitor", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        monitor.ap.connect(this.ram_agt_ap); // Expose monitor's analysis port
    endfunction
endclass