// class fsm_agent extends uvm_agent;
//         `uvm_component_utils(fsm_agent)

//         fsm_monitor mon; // monitor
        
//         uvm_analysis_port #(fsm_sequence_item) agt_ap; 

//         function new (string name = "fsm_agent", uvm_component parent = null);
//             super.new(name, parent);
//         endfunction

//         function void build_phase(uvm_phase phase);
//             super.build_phase(phase);
//             // creation
//             mon = fsm_monitor::type_id::create("mon", this);
//             agt_ap = new("agt_ap", this); // connection point

//         endfunction

//         function void connect_phase(uvm_phase phase);
//             super.connect_phase(phase);
//             mon.mon_ap.connect(agt_ap); // connect monitor share point with agent share point 
//         endfunction
//     endclass





class fsm_agent extends uvm_agent;
    `uvm_component_utils(fsm_agent)

    fsm_monitor mon; // Monitor instance
    uvm_analysis_port #(fsm_sequence_item) agt_ap; // Agent analysis port

    function new(string name = "fsm_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create components
        mon = fsm_monitor::type_id::create("mon", this);
        agt_ap = new("agt_ap", this);
        
        `uvm_info("BUILD", "FSM Agent components created", UVM_DEBUG)

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect monitor to agent analysis port
        mon.mon_ap.connect(agt_ap);
        
        `uvm_info("CONNECT", "FSM Agent connections completed", UVM_DEBUG)
    endfunction

    // Optional but useful for debugging
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info("TOPOLOGY", $sformatf("FSM Agent hierarchy:\n%s", this.sprint()), UVM_DEBUG)
    endfunction
endclass