# ===============================
# Makefile for SPI Cocotb Testbench using Icarus Verilog
# ===============================

# ====== Configuration ======

# Simulator & Language
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# RTL Files
COCOTB_RESULTS_FILE=results.xml
RTL_DIR := /mnt/d/DDVPs/SPI/Python_testing
VERILOG_SOURCES := $(wildcard $(RTL_DIR)/*.sv $(RTL_DIR)/*.v)

# DUT & Test Module
TOPLEVEL := SpiWrapper
MODULE := wrapper_tb

# Cocotb Time Units
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

# Output directories
BUILD_DIR := sim_build

# Icarus Verilog flags
# EXTRA_ARGS += -g2012

# ====== Default Target ======

all: run

# ====== Run Simulation ======

run:
	@echo "[INFO] Running simulation..."
	@rm -f results.xml
	$(MAKE) -f Makefile results.xml

results.xml: $(VERILOG_SOURCES)
	@echo "+timescale+$(COCOTB_HDL_TIMEUNIT)/$(COCOTB_HDL_TIMEPRECISION)" > $(BUILD_DIR)/cmds.f
	iverilog -o $(BUILD_DIR)/sim.vvp -D COCOTB_SIM=1 -s $(TOPLEVEL) $(EXTRA_ARGS) -f $(BUILD_DIR)/cmds.f $(VERILOG_SOURCES)
	MODULE=$(MODULE) TESTCASE= TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=$(TOPLEVEL_LANG) \
		vvp -M $(shell cocotb-config --lib-dir) -m libcocotbvpi_icarus $(BUILD_DIR)/sim.vvp
	test -f results.xml || (echo "ERROR: results.xml was not written!" >&2 && exit 1)
	@echo "[INFO] Simulation complete."


# ====== Clean Targets ======

clean::
	@echo "[INFO] Cleaning build files..."
	@rm -f results.xml
	@rm -rf $(BUILD_DIR)

clean_all: clean
	@rm -f *.vcd *.vvp *.xml
	@rm -rf __pycache__
	@echo "[INFO] Cleaned all temporary and result files."

# ====== Include Cocotb Makefile ======

include $(shell cocotb-config --makefiles)/Makefile.sim
