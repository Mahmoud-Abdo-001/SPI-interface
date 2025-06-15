// module SpiWrapper_tb ();
//     logic clk;
//     logic rst_n;
//     logic [9:0] data_in;
//     logic [7:0] data_out;
//     logic start,busy,done;

//     SpiWrapper DUT(.*);
	
// 	bind DUT.MASTER SPIMSVA SPIMSVA_inst(
// 		.clk(MASTER.clk),
// 		.rst_n(MASTER.rst_n),
// 		.sclk(MASTER.sclk),
// 		.start(MASTER.start),     
// 		.data_in(MASTER.data_in),
// 		.data_out(MASTER.data_out),
// 		.busy(MASTER.busy),      
// 		.done(MASTER.done),
// 		.MOSI(MASTER.MOSI),
// 		.ss_n(MASTER.ss_n),
// 		.MISO(MASTER.MISO),
// 		.valid_MISO(MASTER.valid_MISO),
// 		.sready(MASTER.sready)
// 	);
	
// 	bind DUT.SLAVE.spi_fsm SPIS_FSM_SVA SPIS_FSM_SVA_inst (
// 		.clk         (spi_fsm.clk), 
// 		.rst_n       (spi_fsm.rst_n),
// 		.ss_n        (spi_fsm.ss_n),
// 		.MOSI        (spi_fsm.MOSI),
// 		.tx_valid    (spi_fsm.tx_valid),
// 		.tx_data     (spi_fsm.tx_data),
// 		.sready      (spi_fsm.sready),
// 		.rx_valid    (spi_fsm.rx_valid), 
// 		.rx_data     (spi_fsm.rx_data),
// 		.valid_MISO  (valid_MISO),       
// 		.MISO        (spi_fsm.MISO)
// 	);


// 	//================= Declarations =================//
// 	logic [7:0] myRAM [byte];         // Associative array
// 	logic [7:0] wr_add, rd_add;
// 	logic [7:0] mydout;
	
// 	//================= Clock Generation =============//
// 	initial begin
// 		clk = 0;
// 		forever #10 clk = ~clk;
// 	end
	
// 	//================= Testbench ===================//
// 	int unsigned rand_val;
	
// 	initial begin
// 		rst_n   = 0;
// 		start   = 0;
// 		data_in = 0;
// 		myRAM.delete();       // Clear memory before starting
// 		#100;
// 		@(negedge clk);
// 		rst_n = 1;
	
// 		//============ Write Phase ============//
// 		repeat (10000) begin
// 			// 1. Send write address
// 			rand_val = $random;
// 			data_in  = {2'b00, rand_val[7:0]};
// 			wr_add   = rand_val[7:0];
// 			@(posedge clk);
// 			start = 1;
// 			@(posedge clk);
// 			start = 0;
// 			wait(done);
			
	
// 			// 2. Send write data to that address
// 			rand_val = $random;
// 			data_in  = {2'b01, rand_val[7:0]};
// 			myRAM[wr_add] = rand_val[7:0];  // store in reference model
// 			@(posedge clk);
// 			start = 1;
// 			@(posedge clk);
// 			start = 0;
// 			wait(done);
// 		end
	
// 		//============ Read & Compare Phase ============//
// 		repeat (600) begin
// 			// 1. Send read address
// 			rand_val = $random;
// 			rd_add   = rand_val[7:0];
// 			data_in  = {2'b10, rd_add};
// 			@(posedge clk);
// 			start = 1;
// 			@(posedge clk);
// 			start = 0;
// 			wait(done);
	
// 			// 2. Request read data
// 			data_in = {2'b11, 8'd0};  // dummy value
// 			@(posedge clk);
// 			start = 1;
// 			@(posedge clk);
// 			start = 0;
			
// 			wait(done);
			
// 			// 3. Check if address was written before
// 			if (myRAM.exists(rd_add)) begin
// 				mydout = myRAM[rd_add];
// 				CorrectDOUT:assert (data_out == mydout)
// 					else $error("Mismatch: Expected %0h, Got %0h at time %0dns", mydout, data_out, $time);
// 			end else begin
// 				$info("Address not written: %0h at time %0dns", rd_add, $time);
// 				mydout = 8'hXX;  // or some known invalid value
// 			end
// 		end

// 		#50ns;
//         $finish;
//     end
// endmodule










import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer


async def reset_dut(dut):
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.data_in.value = 0
    await Timer(100, units="ns")
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


@cocotb.test()
async def spi_functional_test(dut):
    """Randomized functional test for SPI Wrapper"""
    # Clock generation
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    # Create RAM model
    myRAM = dict()

    # Write phase — simulate 10000 random writes
    for _ in range(1000):  # Reduce to 1000 for simulation time
        # Generate random write address
        rand_val = random.getrandbits(8)
        addr = rand_val
        dut.data_in.value = (0b00 << 8) | addr  # 10-bit write addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0

        # Wait until done is high
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Generate random write data
        rand_val = random.getrandbits(8)
        data = rand_val
        myRAM[addr] = data  # store in reference model
        dut.data_in.value = (0b01 << 8) | data  # 10-bit write data
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0

        while not dut.done.value:
            await RisingEdge(dut.clk)

    # Read and compare phase
    for _ in range(600):
        rand_val = random.getrandbits(8)
        addr = rand_val

        # Send read address (0b10 + addr)
        dut.data_in.value = (0b10 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0

        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Request data (0b11)
        dut.data_in.value = (0b11 << 8)  # 10-bit dummy read command
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0

        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Compare with expected result
        if addr in myRAM:
            expected = myRAM[addr]
            actual = int(dut.data_out.value)
            assert actual == expected, (
                f"Read mismatch @ addr {addr:02X}: expected {expected:02X}, got {actual:02X}"
            )
        else:
            cocotb.log.info(f"Address {addr:02X} was not written — skipping compare")

    cocotb.log.info("Test completed successfully.")
