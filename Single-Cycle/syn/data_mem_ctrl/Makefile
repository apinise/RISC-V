# Makefile for Yosys synthesis

# Define paths
VERILOG_SRC = ../../rtl/data_mem_ctrl.v
SYNTH_SCRIPT = synth_data_mem_ctrl.ys
OUTPUT_DIR = build
SYNTH_OUTPUT = $(OUTPUT_DIR)/data_mem_ctrl_synth.v

# Default target
all:
	make output
	make syn

# Create output directory if it doesn't exist       
output:
	mkdir -p $(OUTPUT_DIR)

# Synthesis step
syn:
	yosys -s $(SYNTH_SCRIPT) 2>&1 | tee build/yosys_output.log

# Clean up build directory
clean:
	rm -rf $(OUTPUT_DIR)
