module ram_sva (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx_valid,
    input  logic [9:0]  din,
    input  logic [7:0]  dout,
    input  logic        tx_valid
);

    //=========================================
    // Properties
    //=========================================

    // After reset, dout and tx_valid must be 0
    property reset_behavior;
        @(posedge clk)
        !rst_n |=> (dout == 8'h00 && tx_valid == 1'b0);
    endproperty

    // Read data command should produce a tx_valid = 1
    property tx_valid_on_read_data;
        @(posedge clk) disable iff (!rst_n)
        rx_valid && din[9:8] == 2'b11 |=> tx_valid == 1'b1;
    endproperty

    // Other commands must keep tx_valid low
    property tx_valid_on_other_cmds;
        @(posedge clk) disable iff (!rst_n)
        rx_valid && din[9:8] != 2'b11 |=> tx_valid == 1'b0;
    endproperty

    // dout should remain stable when rx_valid is low
    property dout_resets_if_not_receiving;
        @(posedge clk) disable iff (!rst_n)
        !rx_valid |=> dout == '0;
    endproperty

    //=========================================
    // Assertions
    //=========================================
    reset_check:         assert property (reset_behavior);
    tx_valid_read_cmd:   assert property (tx_valid_on_read_data);
    tx_valid_other_cmds: assert property (tx_valid_on_other_cmds);
    dout_stability:      assert property (dout_resets_if_not_receiving);

    //=========================================
    // Coverage
    //=========================================
    cover property (reset_behavior);
    cover property (tx_valid_on_other_cmds);
    cover property (tx_valid_on_read_data);
    cover property (dout_resets_if_not_receiving);

endmodule
