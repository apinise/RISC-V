`timescale 1ns / 1ps

module ctrl_logic (
  input   wire  [31:0]  Instruction,
  // ALU Control Signal
  output  reg   [3:0]   ALU_Opcode,
  // Register Control Signal
  output  reg           Reg_Wr_En,
  // Mux Control Signals
  output  reg           PC_Sel,
  output  reg           ALU_Input_A_Sel,
  output  reg           ALU_Input_B_Sel,
  output  reg   [1:0]   Reg_WB_Sel,
  output  reg   [1:0]   Imm_Gen_Sel,
  // Data Mem SW Control Signals
  output  reg   [2:0]   Lw_Sw_OP,
  output  reg           Store_Word_En,
  output  reg           Read_Ctrl,
  // Branch Comparator Control Signals
  input   wire          Branch_Equal,
  input   wire          Branch_Less_Than,
  output  reg           Branch_Un_Sel,
  // HALT OPCODE CNTRL
  output  reg           Clk_Enable
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

`include "defines.vh"

endmodule