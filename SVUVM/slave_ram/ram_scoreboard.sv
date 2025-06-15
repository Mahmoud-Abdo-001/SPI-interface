 class ram_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(ram_scoreboard)

        uvm_analysis_export #(ram_sequence_item) sb_export;
        uvm_tlm_analysis_fifo #(ram_sequence_item) sb_fifo;
        ram_sequence_item seq_item_sb;


        int MATCH_count,MISMATCH_count;
        int write_add,write_data,read_add,read_data;

        // internal signals
        logic [7:0] ref_mem [byte]; // assciative array to verify RAM 
        bit [7:0] r_addr, w_addr;
        
        // reference signals
        logic [7:0] dout_ref;
        logic tx_valid_ref;
        bit prev_tx_valid = 0; // class member variable to hold  tx valid previous state 

        function new(string name = "ram_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction


        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
            // Initialize reference memory
            foreach(ref_mem[i]) ref_mem[i] = 8'h00;
        endfunction

        // connect
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        // run

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            sb_fifo.get(seq_item_sb);
            ref_model(seq_item_sb);

            // Compare only on tx valid rising edge
            if(seq_item_sb.tx_valid && !prev_tx_valid) begin
                if (seq_item_sb.dout !== dout_ref) begin
                    MISMATCH_count++;
                    `uvm_error("RAM_SB_MISMATCH", 
                        $sformatf("Data mismatch! Addr: 0x%0h, Expected: 0x%0h, Actual: 0x%0h",r_addr, dout_ref, seq_item_sb.dout))
                end
                else begin
                    MATCH_count++;
                    `uvm_info("RAM_SB_MATCH", 
                        $sformatf("Data match at addr 0x%0h: 0x%0h", r_addr, dout_ref), UVM_HIGH)
                end
            end
            prev_tx_valid = seq_item_sb.tx_valid;
        end
    endtask

task ref_model(ram_sequence_item seq_item_chk);
        if(!seq_item_chk.rst_n) begin
            // Reset handling
            dout_ref = 8'h00;
            tx_valid_ref = 1'b0;
            r_addr = 8'h00;
            w_addr = 8'h00;
            write_add = 0;
            write_data = 0;
            read_add = 0;
            read_data = 0;
            // Clear reference memory on reset
            foreach(ref_mem[i]) ref_mem[i] = 8'h00;
        end
        else if (seq_item_chk.rx_valid) begin
            case (seq_item_chk.din[9:8])
                2'b00: begin // Write address
                    w_addr = seq_item_chk.din[7:0];
                    tx_valid_ref = 1'b0;
                    write_add++;
                end
                2'b01: begin // Write data
                    ref_mem[w_addr] = seq_item_chk.din[7:0];
                    tx_valid_ref = 1'b0;
                    write_data++;
                end
                2'b10: begin // Read address
                    r_addr = seq_item_chk.din[7:0];
                    tx_valid_ref = 1'b0;
                    read_add++;
                end
                2'b11: begin // Read data
                    dout_ref = ref_mem[r_addr];
                    tx_valid_ref = 1'b1;
                    read_data++;
                end
                default: begin
                    tx_valid_ref = 1'b0;
                    `uvm_warning("RAM_SB", $sformatf("Invalid opcode: %b", seq_item_chk.din[9:8]))
                end
            endcase
        end
    endtask
        
        // report
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase","   ***************************  SLAVE RAM RESULTS ", UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total write address transactions: %0d", write_add), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total write data transactions: %0d", write_data), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total read address transactions: %0d", read_add), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total read data transactions: %0d", read_data), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total successful ram transactions: %0d", MATCH_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("   *****   total failed ram transactions: %0d", MISMATCH_count), UVM_MEDIUM);
        endfunction
    endclass
