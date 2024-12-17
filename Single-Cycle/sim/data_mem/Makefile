# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/data_mem.v \
	data_mem_tb.v; \
	vsim -c -do ./dofile.do -L work work.data_mem_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
