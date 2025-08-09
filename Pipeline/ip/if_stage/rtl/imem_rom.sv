module imem_rom (
  //input  logic        clk,
  //input  logic        rst_n,
  /* verilator lint_off UNUSED */
  input  logic [31:0] program_count,
  /* verilator lint_off UNUSED */
  output logic [31:0] instruction
);

import imem_pkg::*;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [31:0] instr_mem [0:IMEM_SIZE-1]; // Create ROM
logic [IMEM_ADDR-1:0] rom_addr;       // Read Address

integer i;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign rom_addr = program_count[IMEM_ADDR+1:2]; // Assign the effective address range
assign instruction = instr_mem[rom_addr];       // Asynchronous read from instruct mem

initial begin
  for (i=0; i<IMEM_SIZE; i=i+1) begin
    instr_mem[i] = 32'h0 + i;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
imem_rom (
  .clk           (),
  .rst_n         (),
  .program_count (),
  .instruction   ()
);
*/

endmodule