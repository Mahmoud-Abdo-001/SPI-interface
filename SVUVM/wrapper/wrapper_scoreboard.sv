class wrapper_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(wrapper_scoreboard)

  //==================== Ports & FIFOs ====================//
  uvm_analysis_export #(wrapper_seq_item) sb_export;
  uvm_tlm_analysis_fifo #(wrapper_seq_item) sb_fifo;
  wrapper_config_obj w_cfg;
  virtual wrapper_if wif;

  //==================== Variables ====================//
  wrapper_seq_item seq_item_sb;
  logic [7:0] ref_mem [byte];  // Reference memory model (associative array)
  logic [7:0] wr_add, rd_add;
  logic [7:0] dout_ref;

  int MATCH_count = 0;
  int MISMATCH_count = 0;
  int WRITE_count = 0 ;

  //==================== Constructor ====================//
  function new(string name = "wrapper_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //==================== Build Phase ====================//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sb_export = new("sb_export", this);
    sb_fifo   = new("sb_fifo", this);
  endfunction

  //==================== Connect Phase ====================//
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    sb_export.connect(sb_fifo.analysis_export);
  endfunction

  //==================== Run Phase ====================//
    task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
        sb_fifo.get(seq_item_sb);
        golden_model(seq_item_sb);

        if(seq_item_sb.data_in[9:8] == 2'b11)begin  : READ_operations
            if (seq_item_sb.done) begin
                if (ref_mem.exists(rd_add)) begin
                    if (seq_item_sb.data_out !== dout_ref) begin
                    MISMATCH_count++;
                    `uvm_error("SB", $sformatf(
                        "Comparison failed:\nDUT : 0b%0b \nREF : 0b%0b",
                        seq_item_sb.data_out, dout_ref))
                    end else begin
                    MATCH_count++;
                    end
                end else begin
                    `uvm_info("SB", $sformatf(
                    "Skipped comparison: Read address 0x%0h was not written before.", rd_add), UVM_LOW)
                end
            end
        end else if(seq_item_sb.data_in[9:8] == 2'b01)begin  : WRITE_operations
            if(seq_item_sb.done)begin
                WRITE_count++; //counts total write operations 
            end
        end
    end
    endtask


  //==================== Golden Model ====================//
  task automatic golden_model(wrapper_seq_item item);
    if (!item.rst_n) begin
      rd_add    = '0;
      wr_add    = '0;
      dout_ref  = '0;
    end else begin
      case (item.data_in[9:8])
        2'b00: wr_add = item.data_in[7:0];
        2'b01: ref_mem[wr_add] = item.data_in[7:0];
        2'b10: rd_add = item.data_in[7:0];
        2'b11: begin
            if(ref_mem.exists(rd_add))begin
                dout_ref = ref_mem[rd_add];
            end
        end 
        default: dout_ref = 'x;
      endcase
    end
  endtask

  //==================== Report Phase ====================//
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("report_phase","   ***************************  SPI WRAPPER RESULTS ", UVM_MEDIUM);
    `uvm_info("report_phase", $sformatf("   *****   Total successful write transactions : %0d", WRITE_count), UVM_MEDIUM);
    `uvm_info("report_phase", $sformatf("   *****   Total successful read transactions : %0d", MATCH_count), UVM_MEDIUM);
    `uvm_info("report_phase", $sformatf("   *****   Total failed read transactions     : %0d", MISMATCH_count), UVM_MEDIUM);

  endfunction

endclass
