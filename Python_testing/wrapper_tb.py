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
async def test_spi_write(dut):
    """Test 1000 randomized write operations"""
    clock = Clock(dut.clk, 20, units="ns")  # 50MHz
    cocotb.start_soon(clock.start())
    
    await reset_dut(dut)
    
    for _ in range(1000):
        addr = random.randint(0, 255)
        data = random.randint(0, 255)

        # Write address
        dut.data_in.value = (0b00 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Write data
        dut.data_in.value = (0b01 << 8) | data
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

@cocotb.test()
async def test_spi_read(dut):
    """Test 1000 randomized write+read operations with verification"""
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_dut(dut)
    
    ref_model = {}

    # Write phase
    for _ in range(1000):
        addr = random.randint(0, 255)
        data = random.randint(0, 255)
        ref_model[addr] = data

        # Write address
        dut.data_in.value = (0b00 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Write data
        dut.data_in.value = (0b01 << 8) | data
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

    # Read and check
    for _ in range(1000):
        addr = random.choice(list(ref_model.keys()))
        expected_data = ref_model[addr]

        # Read address
        dut.data_in.value = (0b10 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Request data
        dut.data_in.value = (0b11 << 8)
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        actual_data = int(dut.data_out.value)
        assert actual_data == expected_data, \
            f"[READ] Mismatch at addr 0x{addr:02X}: expected 0x{expected_data:02X}, got 0x{actual_data:02X}"

@cocotb.test()
async def test_spi_read_write(dut):
    """Test 500 write followed immediately by read"""
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())

    await reset_dut(dut)

    for _ in range(500):
        addr = random.randint(0, 255)
        data = random.randint(0, 255)

        # Write address
        dut.data_in.value = (0b00 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Write data
        dut.data_in.value = (0b01 << 8) | data
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Read address
        dut.data_in.value = (0b10 << 8) | addr
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        # Request read data
        dut.data_in.value = (0b11 << 8)
        await RisingEdge(dut.clk)
        dut.start.value = 1
        await RisingEdge(dut.clk)
        dut.start.value = 0
        while not dut.done.value:
            await RisingEdge(dut.clk)

        actual = int(dut.data_out.value)
        assert actual == data, \
            f"[READ_AFTER_WRITE] Mismatch at addr 0x{addr:02X}: wrote 0x{data:02X}, got 0x{actual:02X}"
