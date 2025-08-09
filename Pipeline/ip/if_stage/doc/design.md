# Instruction Fetch (IF) Stage Design

## Block Diagram

The above figure shows the IF Stage block diagram. The IF stage contains the program counter (PC) and the instruction memory. There is the IF/ID register pipeline register layer interfacing the IF stage with the ID stage and registering the intra-module signals.

### Program Counter

The program counter computes the current and next cycle PC. For the RV32I core the next PC will nominally be `PC+4` unless a branch/jump occurs, or a pipeline hazard presents itself. A multiplexer exists at the input of the program counter for the next PC value to register. The mux is controlled with the `pc_sel` control line, where `1'b0` takes the standard `PC+4` offset, and `1'b1` will go to the `pc_imm` value.

In the case of a pipeline hazard, the PC will either latch to it's current value when the stall signal is `1'b1` or continue it's standard operation.

### Instruction Memory (ROM)

The instruction memory is currently implemented as a ROM with read-only access and no latency. The depth of ROM can be configured through the `imem_pkg.sv` SystemVerilog package. The ROM will take the current PC and use it to address the fetched instruction, which is returned combinationally in the same clock cycle. The ROM itself is blind to stall/flush as the memory uses purely the PC to index the fetched instruction. 

### IF Stage Hazard (Stall + Flush)

The IF stage is aware of two hazard control signals, namely `stall` and `flush`. 

When a `stall` occurs, the PC is latched to its current value, rather than being incremented. Consequently the instruction also remains the same at the IF/ID register layer.

When a `flush` occurs, the PC will latch its current value, and prepare to jump to the immediate offset as a result of the jump/branch instruction. This is done by the control logic setting the `flush, pc_sel, pc_imm` control and data signals. During the `flush` the IF/ID register will output a NOP instruction `0x0000_0013` or `ADDI 0x, 0x, 0`. This will insert a buble through the pipeline and the following clock cycle will have the new PC and instruction.