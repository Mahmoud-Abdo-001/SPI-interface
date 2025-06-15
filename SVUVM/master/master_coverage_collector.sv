class master_coverage_collector extends uvm_component;
    `uvm_component_utils(master_coverage_collector)
    
    uvm_analysis_export #(master_sequence_item) cov_export;
    uvm_tlm_analysis_fifo #(master_sequence_item) cov_fifo;
    master_sequence_item master_item_cov;

    // Simple covergroup without timing measurements
    covergroup SPI_Master_CG;
        data_in_cp : coverpoint master_item_cov.data_in {
            bins zero     = {8'h00};
            bins max      = {8'hFF};
            bins others   = default;
        }

        data_out_cp : coverpoint master_item_cov.data_out {
            bins zero     = {8'h00};
            bins max      = {8'hFF};
            bins others   = default;
        }
        // Command type coverage
        cp_cmd_type: coverpoint master_item_cov.data_in[9:8] {
            bins write_addr = {2'b00};
            bins write_data = {2'b01};
            bins read_addr  = {2'b10};
            bins read_data  = {2'b11};
        }

        // Basic state coverage
        cp_busy: coverpoint master_item_cov.busy;
        cp_done: coverpoint master_item_cov.done;
        cp_ss_n: coverpoint master_item_cov.ss_n;

        // SPI Protocol coverage
        cp_sready: coverpoint master_item_cov.sready;
        cp_valid_MISO: coverpoint master_item_cov.valid_MISO;
    endgroup

    function new(string name = "master_coverage_collector", uvm_component parent = null);
        super.new(name, parent);
        SPI_Master_CG = new;
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
            cov_fifo.get(master_item_cov);
            SPI_Master_CG.sample();
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV_REPORT", "   *************************** SPI Master Coverage Summary", UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("   *****   Command Types: %0.2f%%", 
            SPI_Master_CG.cp_cmd_type.get_coverage()), UVM_LOW)
        `uvm_info("COV_REPORT", $sformatf("   *****   Busy Signal: %0.2f%%", 
            SPI_Master_CG.cp_busy.get_coverage()), UVM_LOW)
    endfunction
endclass