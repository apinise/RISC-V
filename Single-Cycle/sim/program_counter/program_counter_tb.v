`timescale 1ns/1ps

module program_counter_tb (
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Testbench Signals
reg           Clk_Core;
reg           Rst_Core_N;
reg           PC_Sel;
reg   [31:0]  Program_Count_Imm;
wire  [31:0]  Program_Count_Off;
wire  [31:0]  Program_Count;

// Expected Values for Verification
reg   [31:0]  expected_pc;
reg   [31:0]  expected_pc_off;

integer	      Test_Failed;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

// Instantiate the program_counter module
program_counter DUT (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .PC_Sel(PC_Sel),
  .Program_Count_Imm(Program_Count_Imm),
  .Program_Count_Off(Program_Count_Off),
  .Program_Count(Program_Count)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Clock Generation
initial Clk_Core = 0;
always #5 Clk_Core = ~Clk_Core; // 10ns clock period

// Test Procedure
initial begin
  // Initialize inputs
  Rst_Core_N = 0;
  PC_Sel = 0;
  Program_Count_Imm = 32'd0;
  expected_pc = 32'd0;
  expected_pc_off = 32'd0;
  Test_Failed = 0;

  $dumpfile("program_counter.vcd");
  $dumpvars(0, program_counter_tb);

  // Reset the design
  #10;
  Rst_Core_N = 1;

  // Test Incrementing by 4
  PC_Sel = 0; // Increment mode
  repeat (5) begin
    expected_pc = (PC_Sel == 1) ? Program_Count_Imm : expected_pc_off;
    #1;
    expected_pc_off = expected_pc + 4;
    check_output();
    @(posedge Clk_Core);
  end

  // Test Immediate Jump
  PC_Sel = 1; // Immediate mode
  repeat (5) begin
    Program_Count_Imm = $random;
    @(posedge Clk_Core);
    expected_pc = Program_Count_Imm;
    #1;
    expected_pc_off = expected_pc + 4;
    check_output();
  end

  // Test Mixed Operation
  repeat (10) begin
    PC_Sel = $random % 2; // Randomly choose between increment and immediate
    Program_Count_Imm = $random; // Random immediate value
    @(posedge Clk_Core);
    expected_pc = (PC_Sel == 1) ? Program_Count_Imm : expected_pc_off;
    #1;
    expected_pc_off = expected_pc + 4;
    check_output();
  end

  // End simulation
  #10;

  if (Test_Failed == 1) begin
    $display("FAILED");
  end
  else begin
    $display("PASSED");
  end

  $finish;
end

// Task to Check Outputs
task check_output;
  begin
    if (Program_Count !== expected_pc) begin
      $display("ERROR at time %0t: Program_Count mismatch. Expected: %h, Got: %h", $time, expected_pc, Program_Count);
      Test_Failed = 1;
    end else begin
      $display("PASS at time %0t: Program_Count matches. Value: %h", $time, Program_Count);
    end

    if (Program_Count_Off !== expected_pc_off) begin
      $display("ERROR at time %0t: Program_Count_Off mismatch. Expected: %h, Got: %h", $time, expected_pc_off, Program_Count_Off);
      Test_Failed = 1;
    end else begin
      $display("PASS at time %0t: Program_Count_Off matches. Value: %h", $time, Program_Count_Off);
    end
  end
endtask

endmodule

