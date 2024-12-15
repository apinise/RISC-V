# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/instruction_mem.v \
	instruction_mem_tb.v; \
	vsim -c -do ./dofile.do -L work work.instruction_mem_tb

simgui:
	vlog -work work \
        ../../rtl/instruction_mem.v \
        instruction_mem_tb.v; \
        vsim -i -do ./dofile.do -L work work.instruction_mem_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
