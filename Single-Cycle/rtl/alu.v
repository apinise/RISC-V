`timescale 1ns / 1ps

module alu #(
  parameter DWIDTH = 32
)(
  input   wire 	[DWIDTH-1:0]  ALU_In_A, //Operand A
  input   wire 	[DWIDTH-1:0]  ALU_In_B, //Operand B
  input   wire 	[3:0]         ALU_OP,   //ALU Opcode
  output  reg 	[DWIDTH-1:0]  ALU_Out,  //ALU Result
  output  reg                 ALU_Zero_Flag
);

`include "defines.vh"

/*
-----------------------------------------------
|ALU_Sel |   ALU_OPERATION              |
-----------------------------------------------
|  0000  |   ALU_Out = A + B;           |  ADD
-----------------------------------------------
|  0001  |   ALU_Out = A - B;           |  SUB
-----------------------------------------------
|  0010  |   ALU_Out = A << B;          |  SLL
-----------------------------------------------
|  0011  |   ALU_Out = (A < B) ? 1 : 0; |  SLT
-----------------------------------------------
|  0100  |   ALU_Out = (A < B) ? 1 : 0; |  SLTU
-----------------------------------------------
|  0101  |   ALU_Out = A ^ B;           |  XOR
-----------------------------------------------
|  0110  |   ALU_Out = A >> B;          |  SRL
-----------------------------------------------
|  0111  |   ALU_Out = A >>> B;         |  SRA
-----------------------------------------------
|  1000  |   ALU_Out = A | B;           |  OR
-----------------------------------------------
|  1001  |   ALU_Out = A & B;           |  AND
-----------------------------------------------
*/

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

wire [DWIDTH-1:0] mul_div_low;
wire [DWIDTH-1:0] mul_div_upper;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always@(*) begin
  case(ALU_OP)
    `ALU_OP_ADD:  ALU_Out = ALU_In_A + ALU_In_B; //add
    `ALU_OP_SUB:  ALU_Out = ALU_In_A - ALU_In_B; //subtract
    `ALU_OP_SLL:  ALU_Out = ALU_In_A << ALU_In_B[4:0]; //logical left shift
    `ALU_OP_SLT:  ALU_Out = ($signed(ALU_In_A) < $signed(ALU_In_B)) ? 32'd1 : 32'd0; //signed less than
    `ALU_OP_SLTU: ALU_Out = (ALU_In_A < ALU_In_B) ? 32'd1 : 32'd0; //Unsigned set on less then
    `ALU_OP_XOR:  ALU_Out = ALU_In_A ^ ALU_In_B; //xor
    `ALU_OP_SRL:  ALU_Out = ALU_In_A >> ALU_In_B; //shift logic right
    `ALU_OP_SRA:  ALU_Out = $signed(ALU_In_A) >>> ALU_In_B; //signed shift logic right
    `ALU_OP_OR:   ALU_Out = ALU_In_A | ALU_In_B; //or
    `ALU_OP_AND:  ALU_Out = ALU_In_A & ALU_In_B; //and
    default: begin
      ALU_Out = 32'b0; //default add
    end
  endcase

  ALU_Zero_Flag = (ALU_Out == 32'b0) ? 1'b1 : 1'b0; // set on zero
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
alu #(
  .DWIDTH(32)
)
alu
(
  .ALU_In_A(),
  .ALU_In_B(),
  .ALU_OP(),
  .ALU_Out(),
  .ALU_Zero_Flag()
);
*/

endmodule
