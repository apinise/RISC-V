# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/program_counter.v \
	program_counter_tb.v; \
	vsim -c -do ./dofile.do -L work work.program_counter_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
