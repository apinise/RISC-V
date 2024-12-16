# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/branch_comp.v \
	branch_comp_tb.v; \
	vsim -c -do ./dofile.do -L work work.branch_comp_tb

simgui:
	vlog -work work \
        ../../rtl/branch_comp.v \
        branch_comp_tb.v; \
        vsim -i -do ./dofile.do -L work work.branch_comp_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
