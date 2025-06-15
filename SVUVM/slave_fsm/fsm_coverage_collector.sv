class fsm_coverage_collector extends uvm_component;
    `uvm_component_utils(fsm_coverage_collector)
    
    uvm_analysis_export #(fsm_sequence_item) cov_export;
    uvm_tlm_analysis_fifo #(fsm_sequence_item) cov_fifo;
    fsm_sequence_item fsm_item_cov;

    // Covergroup for FSM coverage
    covergroup FSM_CG;
        // Command Type Coverage (inferred from first MOSI bit when ss_n falls)
        cp_cmd_type: coverpoint fsm_item_cov.MOSI {
            bins write_cmd = {0};
            bins read_cmd  = {1};
        }

        // Signal Transitions
        cp_ss_n: coverpoint fsm_item_cov.ss_n {
            bins high = {1};
            bins low  = {0};
        }

        cp_rx_valid: coverpoint fsm_item_cov.rx_valid {
            bins active = {1};
            bins idle   = {0};
        }

        cp_tx_valid: coverpoint fsm_item_cov.tx_valid {
            bins active = {1};
            bins idle   = {0};
        }

        cp_valid_MISO: coverpoint fsm_item_cov.valid_MISO {
            bins active = {1};
            bins idle   = {0};
        }

        // Data Coverage
        cp_rx_data: coverpoint fsm_item_cov.rx_data {
            bins zero     = {0};
            bins max      = {10'h3FF};
            bins typical  = {[1:10'h3FE]};
        }

        cp_tx_data: coverpoint fsm_item_cov.tx_data {
            bins zero     = {0};
            bins max      = {8'hFF};
            bins typical  = {[1:8'hFE]};
        }

        // Cross Coverage
        cmd_x_ss_n: cross cp_cmd_type, cp_ss_n;
        cmd_x_rx_valid: cross cp_cmd_type, cp_rx_valid;
        cmd_x_valid_MISO: cross cp_cmd_type, cp_valid_MISO;
    endgroup

    // Track previous values for edge detection
    bit prev_ss_n = 1;
    bit prev_MOSI = 0;
    bit prev_rx_valid = 0;
    bit prev_tx_valid = 0;

    function new(string name = "fsm_coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        FSM_CG = new;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(fsm_item_cov);
            
            // Sample coverage
            FSM_CG.sample();
            
            // Detect edges
            if (prev_ss_n && !fsm_item_cov.ss_n) begin
                `uvm_info("COV", "SS_N falling edge detected", UVM_HIGH)
            end
            if (!prev_ss_n && fsm_item_cov.ss_n) begin
                `uvm_info("COV", "SS_N rising edge detected", UVM_HIGH)
            end
            
            // Update previous values
            prev_ss_n = fsm_item_cov.ss_n;
            prev_MOSI = fsm_item_cov.MOSI;
            prev_rx_valid = fsm_item_cov.rx_valid;
            prev_tx_valid = fsm_item_cov.tx_valid;
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV_REPORT", "  *************************** FSM Coverage Summary", UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Command Types: %0.2f%%", 
            FSM_CG.cp_cmd_type.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   RX Data: %0.2f%%", 
            FSM_CG.cp_rx_data.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******  TX Data: %0.2f%%", 
            FSM_CG.cp_tx_data.get_coverage()), UVM_MEDIUM)
    endfunction
endclass