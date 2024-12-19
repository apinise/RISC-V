# Compiler and Simulator
sim:
	vlog -work work \
	../../rtl/register_file.v \
	../../rtl/alu.v \
	../../rtl/branch_comp.v \
	../../rtl/core.v \
	../../rtl/ctrl_logic.v \
	../../rtl/data_mem.v \
	../../rtl/data_mem_ctrl.v \
	../../rtl/data_mem_lw.v \
	../../rtl/data_mem_sw.v \
	../../rtl/defines.vh \
	../../rtl/imm_gen.v \
	../../rtl/instruction_mem.v \
	../../rtl/program_counter.v \
	../../rtl/lib/muxes.v \
	../../rtl/soc_top.v \
	soc_top_tb.v; \
	vsim -c -do ./dofile.do -L work work.soc_top_tb

simgui:
	vlog -work work \
	../../rtl/register_file.v \
	../../rtl/alu.v \
	../../rtl/branch_comp.v \
	../../rtl/core.v \
	../../rtl/ctrl_logic.v \
	../../rtl/data_mem.v \
	../../rtl/data_mem_ctrl.v \
	../../rtl/data_mem_lw.v \
	../../rtl/data_mem_sw.v \
	../../rtl/defines.vh \
	../../rtl/imm_gen.v \
	../../rtl/instruction_mem.v \
	../../rtl/program_counter.v \
	../../rtl/lib/muxes.v \
	../../rtl/soc_top.v \
	soc_top_tb.v; \
	vsim -i -do ./dofile.do -L work work.soc_top_tb

# Clean up generated files
clean:
	rm -rf $(OUT) *.vcd transcript work *.wlf
