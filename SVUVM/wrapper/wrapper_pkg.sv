package wrapper_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    //====================objects
    `include "wrapper_seq_item.sv"   //ram seqience item
    `include "wrapper_config_obj.sv" 

    `include "sequencer.sv"
    `include "rand_sequence.sv"

    `include "wrapper_driver.sv"
    `include "wrapper_monitor.sv"
    `include "wrapper_agent.sv"
    `include "wrapper_scoreboard.sv"
    `include "wrapper_coverage_collector.sv"

    `include "wrapper_environment.sv"
    `include "wrapper_test.sv"

endpackage