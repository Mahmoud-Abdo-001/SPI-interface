class fsm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fsm_scoreboard)

    uvm_analysis_export #(fsm_sequence_item) sb_export;
    uvm_tlm_analysis_fifo #(fsm_sequence_item) sb_fifo;

    int total_transactions = 0;
    int write_ops = 0;
    int read_ops = 0;
    int protocol_errors = 0;

    function new(string name = "fsm_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export = new("sb_export", this);
        sb_fifo = new("sb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        fsm_sequence_item tr;
        bit is_read_cmd;
        bit prev_ss_n = 1;
        bit ss_n_fell_prev_cycle = 0;  // Tracks if SS_N fell in previous cycle
        
        super.run_phase(phase);
        
        forever begin
            sb_fifo.get(tr);
            total_transactions++;
            
            // Detect command type one cycle after SS_N falling edge
            if (ss_n_fell_prev_cycle) begin
                is_read_cmd = tr.MOSI;
                `uvm_info("SB", $sformatf("Command type detected: %s (MOSI sampled one cycle after SS_N fall)", 
                    is_read_cmd ? "READ" : "WRITE"), UVM_HIGH)
                ss_n_fell_prev_cycle = 0;  // Clear the flag
            end
            
            // Detect SS_N falling edge for next cycle's command detection
            if (tr.ss_n == 0 && prev_ss_n) begin
                ss_n_fell_prev_cycle = 1;
                `uvm_info("SB", "SS_N falling edge detected (will sample MOSI next cycle)", UVM_HIGH)
            end

            // Basic protocol checks
            if (tr.ss_n && tr.valid_MISO) begin
                `uvm_error("SB", "valid_MISO high while SS_N high")
                protocol_errors++;
            end

            if (!tr.ss_n && tr.valid_MISO && !is_read_cmd) begin
                `uvm_error("SB", "valid_MISO during write operation")
                protocol_errors++;
            end

            // Count completed operations on SS_N rising edge
            if (tr.ss_n && !prev_ss_n) begin
                if (is_read_cmd) begin
                    read_ops++;
                    `uvm_info("SB", "Read operation completed", UVM_HIGH)
                end
                else begin
                    write_ops++;
                    `uvm_info("SB", "Write operation completed", UVM_HIGH)
                end
            end

            prev_ss_n = tr.ss_n;
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_REPORT", "  *************************** SPI Slave FSM Scoreboard Results", UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("  *****   Total Transactions: %0d", total_transactions), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("  *****   Write Operations: %0d", write_ops), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("  *****   Read Operations: %0d", read_ops), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("  *****   Protocol Errors: %0d", protocol_errors), UVM_MEDIUM)
        
        if (protocol_errors == 0) begin
            `uvm_info("SB_REPORT", "  *****   FSM PROTOCOL: ALL CHECKS PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error("SB_REPORT", "   *****   FSM PROTOCOL: ERRORS DETECTED")
        end
    endfunction
endclass