# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/alu.v \
	alu_tb.v; \
	vsim -c -do ./dofile.do -L work work.alu_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work
