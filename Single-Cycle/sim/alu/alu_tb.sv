`timescale 1ns / 1ps

module alu_tb (
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter SEED = 5;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// DUT Nets
reg   [31:0]  ALU_In_A;
reg   [31:0]  ALU_In_B;
reg   [3:0]   ALU_OP;
wire  [31:0]  ALU_Out;
wire          ALU_Zero_Flag;

// Expected outputs
reg   [31:0]  Expected_ALU_Out;
reg           Expected_ALU_Zero_Flag;
reg           Test_Failed;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

alu #(
  .DWIDTH(32)
)
DUT
(
  .ALU_In_A(ALU_In_A),
  .ALU_In_B(ALU_In_B),
  .ALU_OP(ALU_OP),
  .ALU_Out(ALU_Out),
  .ALU_Zero_Flag(ALU_Zero_Flag)
);

////////////////////////////////////////////////////////////////
///////////////////////   Task Definitions   ///////////////////
////////////////////////////////////////////////////////////////

task compute_expected_output;
  input   [31:0]  a, b;
  input   [3:0]   op;
  output  [31:0]  result;
  output          zero_flag;
  
  begin
    case (op)
      4'b0000:  result = a + b;
      4'b0001:  result = a - b;
      4'b0010:  result = a << b;
      4'b0011:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
      4'b0100:  result = (a < b) ? 32'b1 : 32'b0;
      4'b0101:  result = a ^ b;
      4'b0110:  result = a >> b;
      4'b0111:  result = $signed(a) >>> b;
      4'b1000:  result a | b;
      4'b1001:  result a & b;
      default: result = 0;
    endcase
    
    zero_flag = (result == 0);
  end

endtask

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin
  $dumpfile("alu.vcd");
  $dumpvars(0, alu_tb);
  
  $random(SEED);
  
  repeat(1000) begin
    ALU_In_A = $unsigned($random);
    ALU_In_B = $unsigned($random);
    ALU_OP   = $unsigned($random);
    
    #5;
    
    // Compute expected outputs
    compute_expected_output(ALU_In_A, ALU_In_B, ALU_OP, Expected_ALU_Out, Expected_ALU_Zero_Flag);
    
    // Compare DUT output with expected output
    if (ALU_Out !== Expected_ALU_Out || ALU_Zero_Flag !== Expected_ALU_Zero_Flag) begin
      $display("Test Failed at time %0t", $time);
      $display("Inputs: ALU_In_A = %h, ALU_In_B = %h, ALU_OP = %b", ALU_In_A, ALU_In_B, ALU_OP);
      $display("DUT Output: ALU_Out = %h, ALU_Zero_Flag = %b", ALU_Out, ALU_Zero_Flag);
      $display("Expected: ALU_Out = %h, ALU_Zero_Flag = %b", Expected_ALU_Out, Expected_ALU_Zero_Flag);
      Test_Failed = 1;
    end
  end
  
  if (!Test_Failed) begin
    $display("All tests passed!");
  end else begin
    $display("Some tests failed. Check the log for details.");
  end
  
  $finish;
end

endmodule