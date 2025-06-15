///////////////////////////////////////////////////////////////////////////////
// module : SPIMSVA.sv  SPI MASTER SVA
// Auther : Mahmoud Abdo
//
// Description : Assertion-based verification For the SPI MASTER 
//
///////////////////////////////////////////////////////////////////////////////
module SPIMSVA(
    input  logic clk,
    input  logic rst_n,
    input  logic sclk,
    // Interface to User/Controller
    input  logic start,
    input  logic [9:0] data_in,
    input  logic [7:0] data_out,
    input  logic busy,
    input  logic done,
    
    // Interface to SPI Slave
    input  logic MOSI,
    input  logic ss_n,
    input  logic MISO,
    input  logic valid_MISO,
    input  logic sready
);


    // ------------------ Reset Behavior ------------------
    property p_reset_behavior;
        @(posedge clk) !rst_n |-> !busy && !done && !data_out && ss_n;
    endproperty
    assert property (p_reset_behavior)
        else $error("Reset should deassert busy/done");
	cove_p_reset_behavior : cover property(p_reset_behavior);

    // ---------------- Start -> Busy and SS Sequence ------------
    property p_start_initiates_busy_ss;
        @(posedge clk)
        disable iff (!rst_n)
        (start && !busy) |=> ##2 busy and ##3 !ss_n ;  // asserts busy after 2 clk cycles and selects slave after 3
		//If start is true at time t, then busy must be true at time t+2.
    endproperty
    assert property (p_start_initiates_busy_ss)
        else $error("Start should lead to busy and then SS");
	cove_p_start_initiates_busy_ss : cover property(p_start_initiates_busy_ss);
		

    // ------------------ Busy -> Done Sequence ------------------
    property p_busy_ends_with_done;
        @(posedge clk)
        disable iff (!rst_n)
        busy ##1 !busy |-> done;
    endproperty
    assert property (p_busy_ends_with_done)
        else $error("Transaction must end with done");
	cove_p_busy_ends_with_done: cover property(p_busy_ends_with_done);
		

    // ------------------ No start when busy ------------------
    property p_no_start_while_busy;
        @(posedge clk)
        disable iff (!rst_n)
        busy |-> !start;
    endproperty
    assert property (p_no_start_while_busy)
        else $error("Start signal should not be asserted while busy");
	cove_p_no_start_while_busy: cover property(p_no_start_while_busy);

		
    // ------------------ SReady Only High When !Busy ------------------
    property p_busy_high_low_sready;
        @(posedge clk)
        disable iff (!rst_n)
        $rose(busy) |=>##2 $fell(sready);   // takes 3 cycles to handel ss_n and initinalize MOSI then slave will not be ready
    endproperty
    assert property (p_busy_high_low_sready)
        else $error("sready must not be high during busy");
	cove_p_busy_high_low_sready: cover property(p_busy_high_low_sready);


    // ------------------ SS Active Low During Busy ------------------
    property p_ss_active_low_when_busy;
        @(posedge clk)
        disable iff (!rst_n)
        $rose(busy) |=>##1 !ss_n;
    endproperty
    assert property (p_ss_active_low_when_busy)
        else $error("ss_n must be low during busy");
	cove_p_ss_active_low_when_busy: cover property(p_ss_active_low_when_busy);

    // ------------------ MOSI assertion ------------------
	genvar i;
	generate
	for (i = 0; i < 10; i++) begin : gen_mosi_assert
		property p_mosi_assert;
		@(posedge sclk)
		disable iff (!rst_n)
		$fell(ss_n) |=> ##i (MOSI == data_in[9 - i]);
		endproperty
		assert property (p_mosi_assert)
				else $error("MOSI captrued wrong data");
	end
	endgenerate


    // ------------------ NOT valid MISO ------------------
    property p_uvalid_MISO;
        @(negedge clk)
        disable iff (!rst_n)
        !valid_MISO |-> !MISO;
    endproperty
    assert property (p_uvalid_MISO)
        else $error("When valid_MISO is low, MISO must be low");
	cove_p_uvalid_MISO: cover property(p_uvalid_MISO);

		
		
	// ------------------ Assert MISO reciption
	// Captured MISO bit-by-bit using cap_miso
	// This section ensures each bit is correct
	// ---------------------------------------------
	logic [7:0] cap_miso;
	int miso_bit_count;
	
	//
	property p_miso_data_match;
		@(posedge clk)
		disable iff (!rst_n)
		$rose(done) |-> (cap_miso == data_out);
	endproperty
	
	always_ff @(posedge sclk or negedge rst_n) begin
		if (!rst_n) begin
			cap_miso <= 8'b0;
			miso_bit_count <= 0;
		end else if (valid_MISO) begin
			cap_miso[7 - miso_bit_count] <= MISO;
			miso_bit_count <= miso_bit_count + 1;
		end
	
		if (miso_bit_count == 8)begin
			miso_bit_count <= 0;
			
			assert property (p_miso_data_match)
				else $error("MISO received data (0x%0h) doesn't match data_out (0x%0h)", cap_miso, data_out);

		end
	end
	
	cove_p_miso_data_match: cover property(p_miso_data_match);
	
endmodule
