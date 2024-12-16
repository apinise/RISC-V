`timescale 1ns / 1ps

module imm_gen_tb(
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter SEED = 5;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Inputs
reg [31:0] Instruction;
reg [1:0] Imm_Sel;

// Outputs
wire [31:0] Imm_Gen_Out;

// Variables for expected output
reg [31:0] expected_imm;

// Testbench logic
integer i;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

imm_gen DUT (
  .Instruction(Instruction),
  .Imm_Sel(Imm_Sel),
  .Imm_Gen_Out(Imm_Gen_Out)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Task to calculate the expected immediate value
task evaluate_output;
  input [31:0] instruction;
  input [1:0] imm_sel;
  output reg [31:0] expected_imm;
begin
  expected_imm = 32'b0; // Default to zero
  case (imm_sel)
    `I_TYPE: begin
      if (instruction[14:12] == `FUNCT3_SLL || instruction[14:12] == `FUNCT3_SRL_SRA) begin
        expected_imm = {{26{1'b0}}, instruction[24:20]};
      end
      else begin
        expected_imm = (instruction[31] == 1'b1) ? {{21{1'b1}}, instruction[30:20]} : {{21{1'b0}}, instruction[30:20]};
      end
    end
    `S_TYPE: begin
      expected_imm = (instruction[31] == 1'b1) ? {{21{1'b1}}, instruction[30:25], instruction[11:7]} : {{21{1'b0}}, instruction[30:25], instruction[11:7]};
    end
    `B_TYPE: begin
      expected_imm = (instruction[31] == 1'b1) ? {{20{1'b1}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0} : {{20{1'b0}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    end
    `J_TYPE: begin
      if (instruction[6:0] == 7'b1101111) begin
        expected_imm = (instruction[31] == 1'b1) ? {{12{1'b1}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0} : {{12{1'b0}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
      end
      else begin
        expected_imm = (instruction[31] == 1'b1) ? {{13{1'b1}}, instruction[30:12]} : {{13{1'b0}}, instruction[30:12]};
      end
    end
  endcase
end
endtask

// Task to check outputs
task check_output;
begin
  if (Imm_Gen_Out !== expected_imm) begin
    $display("Mismatch at time %t:", $time);
    $display("Inputs: Instruction=%h, Imm_Sel=%b", Instruction, Imm_Sel);
    $display("Expected: Imm_Gen_Out=%h", expected_imm);
    $display("Actual:   Imm_Gen_Out=%h", Imm_Gen_Out);
    $stop;
  end
end
endtask

initial begin

  $dumpfile("imm_gen.vcd");
  $dumpvars(0, imm_gen_tb);

  // Initialize inputs
  Instruction   = 32'b0;
  Imm_Sel       = 2'b00;
  expected_imm  = 0;

  // Edge Cases
  $display("Running edge cases...");
  #5;
  // I_TYPE: Simple immediate value
  Instruction = 32'h00002093; // ADDI x1, x0, 32
  Imm_Sel = `I_TYPE;
  #1;
  evaluate_output(Instruction, Imm_Sel, expected_imm);
  #1;
  check_output();

  #5;
  // S_TYPE: Store instruction
  Instruction = 32'h00112223; // SW x1, 4(x2)
  Imm_Sel = `S_TYPE;
  #1;
  evaluate_output(Instruction, Imm_Sel, expected_imm);
  #1;
  check_output();

  #5;
  // B_TYPE: Branch instruction
  Instruction = 32'h00A08063; // BEQ x1, x2, 16
  Imm_Sel = `B_TYPE;
  #1;
  evaluate_output(Instruction, Imm_Sel, expected_imm);
  #1;
  check_output();

  #5;
  // J_TYPE: Jump instruction
  Instruction = 32'h0010006F; // JAL x1, 4
  Imm_Sel = `J_TYPE;
  #1;
  evaluate_output(Instruction, Imm_Sel, expected_imm);
  #1;
  check_output();

  // Random Test Cases
  $display("Running random test cases...");
  for (i = 0; i < 1000; i = i + 1) begin
    #5; // Wait for a small delay

    // Generate random inputs
    Instruction = $random;
    Imm_Sel = $random % 4;

    #1;
    // Evaluate expected output
    evaluate_output(Instruction, Imm_Sel, expected_imm);

    #1;
    // Compare outputs
    check_output();
  end

  $display("All test cases passed.");
  $finish;
end

endmodule