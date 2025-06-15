class ram_coverage_collector extends uvm_component;
    `uvm_component_utils(ram_coverage_collector)
    
    uvm_analysis_export #(ram_sequence_item) cov_export;
    uvm_tlm_analysis_fifo #(ram_sequence_item) cov_fifo;
    ram_sequence_item ram_item_cov;

    // Covergroup with improved coverage points
    covergroup RAM_CG with function sample(bit rx_valid, bit tx_valid, bit [9:0] din);
        // Command type coverage
        cp_cmd: coverpoint din[9:8] iff (rx_valid) {
            bins write_addr = {2'b00};
            bins write_data = {2'b01};
            bins read_addr  = {2'b10};
            bins read_data  = {2'b11};
            illegal_bins invalid = default;
        }

        // Address coverage (for both read and write)
        cp_addr: coverpoint din[7:0] iff (rx_valid && (din[9:8] inside {2'b00, 2'b10})) {
            bins low_addr    = {[0:31]};
            bins mid_addr    = {[32:223]};
            bins high_addr   = {[224:255]};
            bins power_of_2 = {1,2,4,8,16,32,64,128};
        }

        // Data coverage (for write operations)
        cp_wr_data: coverpoint din[7:0] iff (rx_valid && din[9:8] == 2'b01) {
            bins zero     = {0};
            bins all_ones = {8'hFF};
            bins walking_one_0  = {8'b00000001};
            bins walking_one_1  = {8'b00000010};
            bins walking_one_2  = {8'b00000100};
            bins walking_one_3  = {8'b00001000};
            bins walking_one_4  = {8'b00010000};
            bins walking_one_5  = {8'b00100000};
            bins walking_one_6  = {8'b01000000};
            bins walking_one_7  = {8'b10000000};
            bins walking_zero_0 = {8'b11111110};
            bins walking_zero_1 = {8'b11111101};
            bins walking_zero_2 = {8'b11111011};
            bins walking_zero_3 = {8'b11110111};
            bins walking_zero_4 = {8'b11101111};
            bins walking_zero_5 = {8'b11011111};
            bins walking_zero_6 = {8'b10111111};
            bins walking_zero_7 = {8'b01111111};
            bins others = default;
        }

        // Read data coverage
        cp_rd_data: coverpoint ram_item_cov.dout iff (tx_valid) {
            bins zero     = {0};
            bins all_ones = {8'hFF};
            bins others   = default;
        }

        // Valid signal transitions
        cp_rx_valid_trans: coverpoint rx_valid {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
        }

        cp_tx_valid_trans: coverpoint tx_valid {
            bins rise = (0 => 1);
            bins fall = (1 => 0);
        }

        // Cross coverage
        // cmd_x_addr: cross cp_cmd, cp_addr;
        // cmd_x_wr_data: cross cp_cmd, cp_wr_data;
        
        // Protocol sequence coverage
        wr_sequence: coverpoint (din[9:8]) {
            bins write_seq = (2'b00 => 2'b01);
        }
        
        rd_sequence: coverpoint (din[9:8]) {
            bins read_seq = (2'b10 => 2'b11);
        }
    endgroup

    function new(string name = "ram_coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        RAM_CG = new;
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
            cov_fifo.get(ram_item_cov);
            // Sample coverage with proper signals
            RAM_CG.sample(
                ram_item_cov.rx_valid,
                ram_item_cov.tx_valid,
                ram_item_cov.din
            );
            
            `uvm_info("COV", $sformatf("Sampled coverage - RX: %b, TX: %b, DIN: 0x%03h", 
                ram_item_cov.rx_valid, ram_item_cov.tx_valid, ram_item_cov.din), UVM_HIGH)
        end
    endtask


    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV_REPORT", "  *************************** RAM Coverage Summary", UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Command Types: %0.2f%%", 
            RAM_CG.cp_cmd.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Address Ranges: %0.2f%%", 
            RAM_CG.cp_addr.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Write Data Patterns: %0.2f%%", 
            RAM_CG.cp_wr_data.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Read Data Patterns: %0.2f%%", 
            RAM_CG.cp_rd_data.get_coverage()), UVM_MEDIUM)
        // `uvm_info("COV_REPORT", $sformatf("  ******   Command/Address Cross: %0.2f%%", 
        //     RAM_CG.cmd_x_addr.get_coverage()), UVM_MEDIUM)
    endfunction
endclass