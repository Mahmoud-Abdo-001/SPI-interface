package master_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "master_sequence_item.sv"   //ram seqience item

    `include "master_monitor.sv"
    `include "master_agent.sv"
    `include "master_scoreboard.sv"
    `include "master_coverage_collector.sv"

endpackage