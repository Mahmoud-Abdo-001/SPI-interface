import ram_pkg::*;
import master_pkg::*;
import fsm_pkg::*;

class wrapper_environment extends uvm_env;
        `uvm_component_utils (wrapper_environment)

        // Wrapper agent, scoreboard and coverage collector
        wrapper_agent w_agt;
        wrapper_scoreboard w_sb;
        wrapper_coverage_collector w_cov;

        // MASTER agent, scoreboard and coverage collector
        master_agent master_agt;
        master_scoreboard master_sb;
        master_coverage_collector master_cov;

        // FSM agent, scoreboard and coverage collector
        fsm_agent fsm_agt;
        fsm_scoreboard fsm_sb;
        fsm_coverage_collector fsm_cov;

        // RAM agent, scoreboard and coverage collector
        ram_agent ram_agt;
        ram_scoreboard ram_sb;
        ram_coverage_collector ram_cov;

    
        // construction
        function new (string name = "wrapper_environment", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            //wrapper
            w_agt = wrapper_agent::type_id::create("w_agt",this);            
            w_sb  = wrapper_scoreboard::type_id::create("w_sb", this);
            w_cov = wrapper_coverage_collector::type_id::create("w_cov", this);
            
            // master 
            master_agt =    master_agent::type_id::create("master_agt",this);            
            master_sb  =    master_scoreboard::type_id::create("master_sb", this);
            master_cov =    master_coverage_collector::type_id::create("master_cov", this);

            // slave fsm 
            fsm_agt =   fsm_agent::type_id::create("fsm_agt",this);            
            fsm_sb  =   fsm_scoreboard::type_id::create("fsm_sb", this);
            fsm_cov =   fsm_coverage_collector::type_id::create("fsm_cov", this);

            // slave ram 
            ram_agt =   ram_agent::type_id::create("ram_agt",this);            
            ram_sb  =   ram_scoreboard::type_id::create("ram_sb", this);
            ram_cov =   ram_coverage_collector::type_id::create("ram_cov", this);
    

        endfunction

        // connection between agent and scoreboard and between agent and coverage collector
        function void connect_phase (uvm_phase phase);
            //wrapper
            w_agt.agt_ap.connect(w_sb.sb_export);
            w_agt.agt_ap.connect(w_cov.cov_export);

            // master
            master_agt.master_agt_ap.connect(master_sb.sb_export);
            master_agt.master_agt_ap.connect(master_cov.cov_export);

            // slave fsm
            fsm_agt.agt_ap.connect(fsm_sb.sb_export);
            fsm_agt.agt_ap.connect(fsm_cov.cov_export);
            
            //slave ram
            ram_agt.ram_agt_ap.connect(ram_sb.sb_export);
            ram_agt.ram_agt_ap.connect(ram_cov.cov_export);
            
        endfunction
    endclass