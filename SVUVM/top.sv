module top ();
    import uvm_pkg::*;
    import wrapper_pkg::*;
    `include "uvm_macros.svh"

    bit clk;

    wrapper_if wif(clk);  // wrapper interface
    master_if mif(clk); //  master if
    fsm_if fsmif (clk); //slave fsm if
    ram_if ramif(clk);  // slave ram if

    // DUT Instantiation
    SpiWrapper DUT (
        .clk(wif.clk),
        .rst_n(wif.rst_n),
        .data_in(wif.data_in),
        .data_out(wif.data_out),
        .start(wif.start),
        .busy(wif.busy),
        .done(wif.done)
    );

    // master SVA 
    bind DUT.MASTER SPIMSVA assert_inst (
        .clk       (mif.clk),
        .rst_n     (mif.rst_n),
        .sclk      (mif.sclk),
        .start     (mif.start),
        .data_in   (mif.data_in),
        .data_out  (mif.data_out),
        .busy      (mif.busy),
        .done      (mif.done),
        .MOSI      (mif.MOSI),
        .ss_n      (mif.ss_n),
        .MISO      (mif.MISO),
        .valid_MISO(mif.valid_MISO),
        .sready    (mif.sready)
    );

    //slave fsm SVA
    bind DUT.SLAVE.spi_fsm SPIS_FSM_SVA slave_fsm_sva(
        .clk        (fsmif.clk), 
        .rst_n      (fsmif.rst_n),
        .ss_n       (fsmif.ss_n),
        .MOSI       (fsmif.MOSI),
        .tx_valid   (fsmif.tx_valid),
        .tx_data    (fsmif.tx_data),
        .sready     (fsmif.sready),
        .rx_valid   (fsmif.rx_valid),
        .rx_data    (fsmif.rx_data),
        .valid_MISO (fsmif.valid_MISO),
        .MISO       (fsmif.MISO)
    );

    // slave ram SVA 
    bind DUT.SLAVE.mem_inst ram_sva ram_assert(
        .clk(ramif.clk),
        .rst_n(ramif.rst_n),
        .rx_valid(ramif.rx_valid),
        .din(ramif.din),
        .dout(ramif.dout),
        .tx_valid(ramif.tx_valid)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    // UVM Interface Configuration
    initial begin
        uvm_config_db #(virtual wrapper_if)::set(null, "uvm_test_top", "wrapperV", wif);
        uvm_config_db #(virtual master_if)::set(null, "*", "masterV", mif);
        uvm_config_db #(virtual fsm_if)::set(null, "*", "fsmV", fsmif);
        uvm_config_db #(virtual ram_if)::set(null, "*", "ramV", ramif);
        run_test("wrapper_test");
    end

    //=================================
    // master interface connections 
    //=================================
    assign mif.clk          = wif.clk;
    assign mif.rst_n        = wif.rst_n;
    assign mif.sclk         = DUT.sclk;
    assign mif.start        = wif.start;
    assign mif.data_in      = wif.data_in;
    assign mif.data_out     = wif.data_out;
    assign mif.busy         = wif.busy;
    assign mif.done         = wif.done;

    assign mif.MOSI         = DUT.MOSI;
    assign mif.ss_n         = DUT.ss_n;
    assign mif.MISO         = DUT.MISO;
    assign mif.valid_MISO   = DUT.valid_MISO;
    assign mif.sready       = DUT.sready;

    //=================================
    // slave FSM interface connections 
    //=================================
    assign fsmif.clk        = wif.clk;
    assign fsmif.rst_n      = wif.rst_n;
    assign fsmif.ss_n       = DUT.ss_n;
    assign fsmif.MOSI       = DUT.MOSI;
    assign fsmif.tx_valid   = DUT.SLAVE.tx_valid;
    assign fsmif.tx_data    = DUT.SLAVE.dout;

    assign fsmif.sready     = DUT.sready;
    assign fsmif.rx_valid   = DUT.SLAVE.rx_valid;
    assign fsmif.rx_data    = DUT.SLAVE.rx_data;
    assign fsmif.valid_MISO = DUT.valid_MISO;
    assign fsmif.MISO       = DUT.MISO;

    //=================================
    // slave ram interface connections 
    //=================================
    assign ramif.rst_n      = DUT.rst_n;
    assign ramif.rx_valid   = DUT.SLAVE.rx_valid;
    assign ramif.din        = DUT.SLAVE.rx_data;
    assign ramif.tx_valid   = DUT.SLAVE.tx_valid;
    assign ramif.dout       = DUT.SLAVE.dout;

endmodule