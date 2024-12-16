`timescale 1ns / 1ps

module branch_comp_tb(
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter SEED = 5;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Inputs
reg [31:0] Read_Reg_Data_1;
reg [31:0] Read_Reg_Data_2;
reg Branch_Un_Ctrl;

// Outputs
wire Branch_Equal;
wire Branch_Lt;

// Variables for expected outputs
reg expected_equal;
reg expected_lt;

// Testbench logic
integer i;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

branch_comp DUT (
  .Read_Reg_Data_1(Read_Reg_Data_1),
  .Read_Reg_Data_2(Read_Reg_Data_2),
  .Branch_Un_Ctrl(Branch_Un_Ctrl),
  .Branch_Equal(Branch_Equal),
  .Branch_Lt(Branch_Lt)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Task to calculate expected outputs
task evaluate_outputs;
  input [31:0] in1;
  input [31:0] in2;
  input un_ctrl;
  output reg expected_equal;
  output reg expected_lt;
begin
  // Calculate expected Branch_Equal
  expected_equal = (in1 == in2);

  // Calculate expected Branch_Lt
  if (un_ctrl) begin
    expected_lt = (in1 < in2);
  end else begin
    expected_lt = ($signed(in1) < $signed(in2));
  end
end
endtask

// Task to check outputs
task check_outputs;
begin
  if (Branch_Equal !== expected_equal || Branch_Lt !== expected_lt) begin
    $display("Mismatch at time %t:", $time);
    $display("Inputs: Read_Reg_Data_1=%0h, Read_Reg_Data_2=%0h, Branch_Un_Ctrl=%b", 
             Read_Reg_Data_1, Read_Reg_Data_2, Branch_Un_Ctrl);
    $display("Expected: Branch_Equal=%b, Branch_Lt=%b", expected_equal, expected_lt);
    $display("Actual:   Branch_Equal=%b, Branch_Lt=%b", Branch_Equal, Branch_Lt);
    $stop;
  end
end
endtask

initial begin

  $dumpfile("branch_comp.vcd");
  $dumpvars(0, branch_comp_tb);

  // Initialize inputs
  Read_Reg_Data_1 = 0;
  Read_Reg_Data_2 = 0;
  Branch_Un_Ctrl  = 0;

  expected_equal  = 0;
  expected_lt     = 0;

  // Edge Cases
  $display("Running edge cases...");
  #5;
  // Case 1: Equal inputs
  Read_Reg_Data_1 = 32'hAAAAAAAA;
  Read_Reg_Data_2 = 32'hAAAAAAAA;
  Branch_Un_Ctrl = 0;
  #1;
  evaluate_outputs(Read_Reg_Data_1, Read_Reg_Data_2, Branch_Un_Ctrl, expected_equal, expected_lt);
  #1;
  check_outputs();

  #5;
  // Case 2: Read_Reg_Data_1 < Read_Reg_Data_2 (unsigned)
  Read_Reg_Data_1 = 32'h12345678;
  Read_Reg_Data_2 = 32'h9ABCDEF0;
  Branch_Un_Ctrl = 1;
  #1;
  evaluate_outputs(Read_Reg_Data_1, Read_Reg_Data_2, Branch_Un_Ctrl, expected_equal, expected_lt);
  #1;
  check_outputs();

  #5;
  // Case 3: Read_Reg_Data_1 > Read_Reg_Data_2 (signed)
  Read_Reg_Data_1 = 32'h80000000; // -2147483648
  Read_Reg_Data_2 = 32'h00000001; // 1
  Branch_Un_Ctrl = 0;
  #1;
  evaluate_outputs(Read_Reg_Data_1, Read_Reg_Data_2, Branch_Un_Ctrl, expected_equal, expected_lt);
  #1;
  check_outputs();

  // Random Test Cases
  $display("Running random test cases...");
  for (i = 0; i < 1000; i = i + 1) begin
    #5; // Wait for a small delay

    // Generate random inputs
    Read_Reg_Data_1 = $random;
    Read_Reg_Data_2 = $random;
    Branch_Un_Ctrl = $random % 2;
    
    #1;
    // Evaluate expected outputs
    evaluate_outputs(Read_Reg_Data_1, Read_Reg_Data_2, Branch_Un_Ctrl, expected_equal, expected_lt);

    #1;
    // Compare outputs
    check_outputs();
  end

  $display("All test cases passed!");
  $finish;
end

endmodule