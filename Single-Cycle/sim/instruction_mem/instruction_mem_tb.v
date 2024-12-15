`timescale 1ns / 1ps

module instruction_mem_tb(
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

// Testbench Parameters
localparam MEM_SIZE = 1024; // Reduce size for faster simulation in testbench

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Testbench signals
reg         Clk_Core;
reg         Rst_Core_N;
reg [31:0]  Program_Count;
wire [31:0] Instruction;

// Internal Variables
integer i;
integer Test_Failed;
reg [31:0] expected_instr [0:MEM_SIZE-1]; // Expected instruction memory

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

// Instantiate the DUT
instruction_mem #(
  .MEM_SIZE(MEM_SIZE)
) DUT (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .Program_Count(Program_Count),
  .Instruction(Instruction)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Clock generation
initial Clk_Core = 0;
always #5 Clk_Core = ~Clk_Core; // 10 ns clock period

// Test procedure
initial begin
  // Initialize reset
  
  $dumpfile("instruction_mem.vcd");
  $dumpvars(0, instruction_mem_tb);
  
  Rst_Core_N = 0;
  Program_Count = 0;
  Test_Failed = 0;
  #20 Rst_Core_N = 1; // Release reset after 20 ns

  // Initialize expected instruction memory
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    expected_instr[i] = i * 4; // Example: each instruction is 4*i
    DUT.instr_mem[i] = expected_instr[i]; // Force DUT memory initialization
  end

  // Test sequential program counter reads
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    Program_Count = i * 4; // Program counter increments by 4 (word-aligned)
    #10; // Wait for 1 clock cycle

    // Check the instruction output
    if (Instruction !== expected_instr[i]) begin
      $display("[ERROR] Time: %0t | Program_Count: %0d | Expected: %0h | Got: %0h",
               $time, Program_Count, expected_instr[i], Instruction);
      Test_Failed = 1;
    end 
    else begin
      $display("[PASS] Time: %0t | Program_Count: %0h | Instruction: %0h",
               $time, Program_Count, Instruction);
    end
  end

  // End simulation
  $display("Test completed.");
  if (Test_Failed == 1) begin
    $display("FAILED");
  end
  else begin
    $display("PASSED");
  end
  $finish;
end

endmodule