///////////////////////////////////////////////////////////////////////////////
// module : SPISSVA.sv  SPI SLAVE FSM SVA
// Author : Mahmoud Abdo
//
// Description : Assertion-based verification for the SPI SLAVE FSM
//
///////////////////////////////////////////////////////////////////////////////
module SPIS_FSM_SVA(
    input  logic        clk, 
    input  logic        rst_n,
    input  logic        ss_n,
    input  logic        MOSI,
    input  logic        tx_valid,
    input  logic [7:0]  tx_data,
    input  logic        sready,
    input  logic        rx_valid,
    input  logic [9:0]  rx_data,
    input  logic        valid_MISO,
    input  logic        MISO
);

    //=============================
    // 1. Reset Behavior
    //=============================
    sequence reset_seq;
        !rx_valid && (rx_data == 0) && sready && !valid_MISO && (MISO == 0);
    endsequence

    property p_reset_behavior;
        @(posedge clk) !rst_n |=> reset_seq;
    endproperty

    assert property(p_reset_behavior)
        else $error("Reset failed: Expected !rx_valid, rx_data == 0, sready == 1, !valid_MISO, and MISO == 0");

    //=============================
    // 2. sready deasserts after ss_n falls
    //=============================
    property p_ss_fall_then_sready_fall;
        @(posedge clk) disable iff (!rst_n)
            $fell(ss_n) |=> ##1 $fell(sready);
    endproperty

    assert property(p_ss_fall_then_sready_fall)
        else $error("sready must deassert 1 cycle after ss_n goes low");

    cove_p_ss_fall_then_sready_fall : cover property(p_ss_fall_then_sready_fall);

    //=============================
    // 3. tx_valid triggers valid_MISO 1 cycle later
    //=============================
    property p_tx_valid_then_validMISO;
        @(posedge clk) disable iff (!rst_n)
            $rose(tx_valid) |=> $rose(valid_MISO);
    endproperty

    assert property(p_tx_valid_then_validMISO)
        else $error("valid_MISO must assert 1 cycle after tx_valid goes high");

    cove_p_tx_valid_then_validMISO : cover property(p_tx_valid_then_validMISO);

	//=============================
	// 4. MISO Bitwise Output Match
	//=============================
	// Capture tx_data on tx_valid rising edge
	// tx_data is only valid for one cycle and resets internally afterward
	reg [7:0] tx_data_reg;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			tx_data_reg <= '0;
		else if ($rose(tx_valid)) begin
			tx_data_reg <= tx_data;
			// $display("Captured TX data: %0h", tx_data);
		end
	end
	
	// Sequence: Compare each bit of tx_data_reg with MISO when valid_MISO is high
	sequence miso_bitwise_match;
		@(posedge clk)
		$rose(valid_MISO) ##0
		(MISO == tx_data[7]) ##1
		(MISO == tx_data[6]) ##1
		(MISO == tx_data[5]) ##1
		(MISO == tx_data[4]) ##1
		(MISO == tx_data[3]) ##1
		(MISO == tx_data[2]) ##1
		(MISO == tx_data[1]) ##1
		(MISO == tx_data[0]);
	endsequence
	
	// Property: After tx_valid rises, all MISO bits must match tx_data_reg
	property p_miso_match;
		@(posedge clk) disable iff (!rst_n)
			tx_valid |=> miso_bitwise_match;
	endproperty
	
	// Assertion and coverage
	// assert property (p_miso_match)
	// 	else $error("MISO mismatch after tx_valid at time %0t", $time);
	
	// cov_p_miso_match:cover property (p_miso_match);


	
	//=============================
    // 5. Captured MOSI Match 
	//    Sampled MOSI corresponds to rx_data[9:0]
    //=============================
	logic [9:0] cap_mosi;
	logic [3:0] bit_cnt;
	logic       capturing;
	
	// Capture logic
	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cap_mosi  <= '0;
			bit_cnt   <= 0;
			capturing <= 0;
		end else begin
			if ($fell(ss_n)) begin
				capturing <= 1;
				bit_cnt   <= 0;
			end else if (capturing) begin
				cap_mosi[9 - bit_cnt] <= MOSI;
				bit_cnt <= bit_cnt + 1;
				if (bit_cnt == 9) begin
					capturing <= 0;
					// $display("caputrede mosi : %0b " , cap_mosi ); //for debugging
				end
			end
		end
	end
	
	// Property to check captured value against expected tx_data_reg
	property p_mosi_match;
		@(posedge clk)
		disable iff (!rst_n)
		$rose(rx_valid) |-> (cap_mosi === rx_data);
	endproperty
	
	assert property (p_mosi_match)
		else $error("MOSI mismatch: Expected %b, got %b", rx_data , cap_mosi);
	cove_p_mosi_match : cover property(p_mosi_match);

    //=============================
    // 6. rx_valid asserted after 10 [12 clk cycels] bits on MOSI
    //=============================
    property p_rx_valid_after_8bits;
        @(posedge clk) disable iff (!rst_n)
            $fell(ss_n) |=>##11 rx_valid;//it takes 12 clk cycles after !ss_n to collect 10MOSI BITS to activate rx_valid
    endproperty

    assert property(p_rx_valid_after_8bits)
        else $error("rx_valid should assert after receiving 8 bits from MOSI");
	cove_p_rx_valid_after_8bits:cover property (p_rx_valid_after_8bits);	

endmodule
