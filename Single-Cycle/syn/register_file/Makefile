# Makefile for Yosys synthesis

# Define paths
VERILOG_SRC = ../../rtl/register_file.v
SYNTH_SCRIPT = synth_register_file.ys
OUTPUT_DIR = build
SYNTH_OUTPUT = $(OUTPUT_DIR)/register_file_synth.v

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

