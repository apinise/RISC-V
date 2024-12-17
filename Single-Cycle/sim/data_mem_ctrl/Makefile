# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/data_mem.v \
	../../rtl/data_mem_lw.v \
	../../rtl/data_mem_sw.v \
	../../rtl/data_mem_ctrl.v \
	data_mem_ctrl_tb.v; \
	vsim -c -do ./dofile.do -L work work.data_mem_ctrl_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
