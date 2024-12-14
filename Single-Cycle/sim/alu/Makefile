# Compiler and Simulator
IVERILOG = iverilog
VVP = vvp

# Files
SRC = ../../rtl/alu.sv alu_tb.sv
OUT = alu_tb_out

# Default target
all: run

# Compile the testbench
compile:
	$(IVERILOG) -o $(OUT) $(SRC)

# Run the simulation
run: compile
	$(VVP) $(OUT)

# Clean up generated files
clean:
	rm -f $(OUT) *.vcd

