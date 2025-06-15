class wrapper_coverage_collector extends uvm_component;
    `uvm_component_utils(wrapper_coverage_collector)

    uvm_analysis_export #(wrapper_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(wrapper_seq_item) cov_fifo;

    wrapper_seq_item wrapper_item_cov;
    wrapper_config_obj w_cfg;
    virtual wrapper_if wif;

    // Sampled variables
    bit [1:0] op_code;
    bit [7:0] data_val;
    bit       start_val;
    bit       done_val;
    bit       busy_val;
    bit [7:0] dout_val;

    //========================= Covergroup =========================//
    covergroup WRAPPER_CG(); 
        option.per_instance = 1;

        opcode_cp : coverpoint op_code {
            bins wr_addr  = {2'b00};
            bins wr_data  = {2'b01};
            bins rd_addr  = {2'b10};
            bins rd_data  = {2'b11};
        }

        start_cp : coverpoint start_val {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        done_cp : coverpoint done_val {
            bins done     = {1'b1};
            bins not_done = {1'b0};
        }

        busy_cp : coverpoint busy_val {
            bins busy     = {1'b1};
            bins idle     = {1'b0};
        }

        data_val_cp : coverpoint data_val {
            bins zero     = {8'h00};
            bins max      = {8'hFF};
            bins others   = default;
        }

        dout_cp : coverpoint dout_val {
            bins zero     = {8'h00};
            bins max      = {8'hFF};
            bins others   = default;
        }

        opcode_start_cross : cross opcode_cp, start_cp;
        dout_done_cross    : cross dout_cp, done_cp;

    endgroup

    //========================= Constructor =========================//
    function new(string name = "wrapper_coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        WRAPPER_CG = new;
    endfunction

    //========================= Build Phase =========================//
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo   = new("cov_fifo", this);

        // Retrieve configuration object
        if (!uvm_config_db#(wrapper_config_obj)::get(this, "", "CFG", w_cfg)) begin
        `uvm_fatal("AGENT_CFG", "Unable to get configuration object from config DB")
        end
    endfunction

    //========================= Connect Phase =========================//
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
        wif = w_cfg.wif;  //wrapper interface
    endfunction

    //========================= Run Phase =========================//
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            @(posedge wif.clk);
            // Sample directly from interface instead of just transactions
            op_code   = wif.data_in[9:8];
            data_val  = wif.data_in[7:0];
            dout_val  = wif.data_out;
            start_val = wif.start;
            done_val  = wif.done;
            busy_val  = wif.busy;
            
            // Sample coverage every cycle regardless of transactions
            WRAPPER_CG.sample();
            
            // Still check for transactions if needed for other purposes
            if (!cov_fifo.is_empty()) begin
                cov_fifo.get(wrapper_item_cov);
            end
        end
    endtask


    // coverage summery
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV_REPORT", "  *************************** WRAPPER Coverage Summary", UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Opcode Commands: %0.2f%%", 
            WRAPPER_CG.opcode_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Start Signal: %0.2f%%", 
            WRAPPER_CG.start_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Done Signal: %0.2f%%", 
            WRAPPER_CG.done_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Busy Signal: %0.2f%%", 
            WRAPPER_CG.busy_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Input Data Patterns: %0.2f%%", 
            WRAPPER_CG.data_val_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Output Data Patterns: %0.2f%%", 
            WRAPPER_CG.dout_cp.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Opcode/Start Cross: %0.2f%%", 
            WRAPPER_CG.opcode_start_cross.get_coverage()), UVM_MEDIUM)
        `uvm_info("COV_REPORT", $sformatf("  ******   Dout/Done Cross: %0.2f%%", 
            WRAPPER_CG.dout_done_cross.get_coverage()), UVM_MEDIUM)
    endfunction

endclass
