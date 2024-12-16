# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/imm_gen.v \
	imm_gen_tb.v; \
	vsim -c -do ./dofile.do -L work work.imm_gen_tb

simgui:
	vlog -work work \
        ../../rtl/imm_gen.v \
        imm_gen_tb.v; \
        vsim -i -do ./dofile.do -L work work.imm_gen_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
