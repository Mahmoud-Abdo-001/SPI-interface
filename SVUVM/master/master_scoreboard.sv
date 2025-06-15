class master_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(master_scoreboard)

    uvm_analysis_export #(master_sequence_item) sb_export;
    uvm_tlm_analysis_fifo #(master_sequence_item) sb_fifo;
    
    // Counters for statistics
    int total_transactions = 0;
    int write_transactions = 0;
    int read_transactions = 0;
    int error_count = 0;

    function new(string name = "master_scoreboard", uvm_component parent = null);
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
        master_sequence_item tr;
        super.run_phase(phase);
        
        forever begin
            sb_fifo.get(tr);
            total_transactions++;
            
            // Check command type and count transactions
            case (tr.data_in[9:8])
                2'b00, 2'b01: begin // Write operations
                    write_transactions++;
                    `uvm_info("SB", $sformatf("Write transaction - Addr: 0x%0h, Data: 0x%0h",
                        tr.data_in[7:0], tr.data_in[7:0]), UVM_HIGH)
                end
                2'b10, 2'b11: begin // Read operations
                    read_transactions++;
                    `uvm_info("SB", $sformatf("Read transaction - Addr: 0x%0h, Data: 0x%0h",
                        tr.data_in[7:0], tr.data_out), UVM_HIGH)
                end
            endcase
            
            // Basic protocol checks
            if (tr.busy && tr.done) begin
                error_count++;
                `uvm_error("SB", "busy and done both high simultaneously")
            end
            
            if (tr.start && tr.busy) begin
                error_count++;
                `uvm_error("SB", "start asserted during busy ")
            end
        end

    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_REPORT", "    *************************** SPI Master Scoreboard Results ", UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("    *****   Total Transactions: %0d", total_transactions), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("    *****   Write Transactions: %0d", write_transactions), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("    *****   Read Transactions: %0d", read_transactions), UVM_MEDIUM)
        `uvm_info("SB_REPORT", $sformatf("    *****   Errors Detected: %0d", error_count), UVM_MEDIUM)
        
        if (error_count == 0) begin
            `uvm_info("SB_REPORT", "    *****   SPI Master Scoreboard: ALL TESTS PASSED", UVM_MEDIUM)
        end else begin
            `uvm_error("SB_REPORT","  *****   SPI Master Scoreboard: ERRORS DETECTED")
        end
    endfunction
endclass