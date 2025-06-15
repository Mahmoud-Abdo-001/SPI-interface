class ram_monitor extends uvm_monitor;
    `uvm_component_utils(ram_monitor)
    
    virtual ram_if vif;
    ram_sequence_item tr;
    uvm_analysis_port #(ram_sequence_item) ap;
    
    // Proper constructor with name argument
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        ap = new("ap", this);
        if(!uvm_config_db#(virtual ram_if)::get(this, "", "ramV", vif))
            `uvm_fatal("NOVIF", "ram_if not found")
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            tr = ram_sequence_item::type_id::create("tr");
            // Capture RAM interface signals
            tr.rx_valid = vif.rx_valid;
            tr.din      = vif.din;
            tr.tx_valid = vif.tx_valid;
            tr.dout     = vif.dout;
            tr.rst_n    = vif.rst_n;
            
            ap.write(tr); // Send to scoreboard/coverage
        end
    endtask
endclass