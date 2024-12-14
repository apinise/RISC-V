# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/register_file.v \
	register_file_tb.v; \
	vsim -c -do ./dofile.do -L work work.register_file_tb

simgui:
	vlog -work work \
        ../../rtl/register_file.v \
        register_file_tb.v; \
        vsim -i -do ./dofile.do -L work work.register_file_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
