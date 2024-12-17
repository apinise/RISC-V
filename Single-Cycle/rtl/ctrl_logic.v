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

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// R Type Encoded Instructions
wire [6:0] instruct_funct7;
wire [2:0] instruct_funct3;

// OPCODE
wire [6:0] instruct_opcode;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign instruct_opcode = Instruction[6:0];
assign instruct_funct7 = Instruction[31:25];
assign instruct_funct3 = Instruction[14:12];

always @(*) begin
  // Reset control signals
  ALU_Opcode      = 4'd0;
  Reg_Wr_En       = 1'd0;
  PC_Sel          = 1'd0;
  ALU_Input_A_Sel = 1'd0;
  ALU_Input_B_Sel = 1'd0;
  Reg_WB_Sel      = 2'd0;
  Imm_Gen_Sel     = 2'd0;
  Lw_Sw_OP        = 3'd0;
  Store_Word_En   = 1'd0;
  Read_Ctrl       = 1'd0;
  Branch_Un_Sel   = 1'd0;
  Clk_Enable      = 1'd1;
  
  case(instruct_opcode)
    `OPCODE_HALT: begin
      Clk_Enable  = 1'b0;
      Read_Ctrl   = 1'b1;
    end
    
    `OPCODE_ALU_R: begin
      Reg_Wr_En       = 1'b1;   // Emable write to register
      PC_Sel          = 1'b0;   // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;   // Use register value as ALU input
      ALU_Input_B_Sel = 1'b0;   // Use register value as ALU input
      Reg_WB_Sel      = 2'b01;  // Write back ALU data to Register
      Imm_Gen_Sel     = 2'b00;  // Imm Gen value does not matter
      Store_Word_En   = 1'b0;   // Disable storing word to data mem
      Read_Ctrl       = 1'b0;   // Do not read from mem
      
      case(instruct_funct3)
        `ADD_SUB:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? `ALU_OP_SUB : `ALU_OP_ADD;
        `SLL:      ALU_Opcode = `ALU_OP_SLL;
        `SLT:      ALU_Opcode = `ALU_OP_SLT;
        `SLTU:     ALU_Opcode = `ALU_OP_SLTU;
        `XOR:      ALU_Opcode = `ALU_OP_XOR;
        `SRL_SRA:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? `ALU_OP_SRA : `ALU_OP_SRL;
        `OR:       ALU_Opcode = `ALU_OP_OR;
        `AND:      ALU_Opcode = `ALU_OP_AND;
      endcase
    end
    
    `OPCODE_ALU_IMM_I: begin
      Reg_Wr_En       = 1'b1;   // Emable write to register
      PC_Sel          = 1'b0;   // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;   // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;   // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;  // Write back ALU data to Register
      Imm_Gen_Sel     = 2'b00;  // Generates I type immediate
      Store_Word_En   = 1'b0;   // Disable storing word to data mem
      Read_Ctrl       = 1'b0;   // Do not read from mem
      
      case(instruct_funct3)
        `ADD_SUB:  ALU_Opcode = `ALU_OP_ADD;
        `SLL:      ALU_Opcode = `ALU_OP_SLL;
        `SLT:      ALU_Opcode = `ALU_OP_SLT;
        `SLTU:     ALU_Opcode = `ALU_OP_SLTU;
        `XOR:      ALU_Opcode = `ALU_OP_XOR;
        `SRL_SRA:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? `ALU_OP_SRA : `ALU_OP_SRL;
        `OR:       ALU_Opcode = `ALU_OP_OR;
        `AND:      ALU_Opcode = `ALU_OP_AND;
      endcase
    end
    
    `OPCODE_SW: begin
      Reg_Wr_En       = 1'b0;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Value does not matter
      Imm_Gen_Sel     = 2'b01;      // Generates S type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base address
      Store_Word_En   = 1'b1;       // Enable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem
      
      case(instruct_funct3)
        `SB_STORE: Lw_Sw_OP = `SB_OP_STORE;
        `SH_STORE: Lw_Sw_OP = `SH_OP_STORE;
        `SW_STORE: Lw_Sw_OP = `SW_OP_STORE;
      endcase
    end
    
    `OPCODE_LW: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Output from data mem
      Imm_Gen_Sel     = 2'b00;      // Generates I type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base address
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b1;       // Enable read from mem
      
      case(instruct_funct3)
        `LB_LOAD:  Lw_Sw_OP = `LB_OP_LOAD;
        `LH_LOAD:  Lw_Sw_OP = `LH_OP_LOAD;
        `LW_LOAD:  Lw_Sw_OP = `LW_OP_LOAD;
        `LBU_LOAD: Lw_Sw_OP = `LBU_OP_LOAD;
        `LHU_LOAD: Lw_Sw_OP = `LHU_OP_LOAD;
      endcase
    end
    
    `OPCODE_BRANCH: begin
      Reg_Wr_En       = 1'b0;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Value does not matter
      Imm_Gen_Sel     = 2'b10;      // Generates B type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem
      
      case(instruct_funct3)
        `BEQ: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Equal == 1'b1) ? 1'b1 : 1'b0;
        end
        `BNE: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Equal == 1'b1) ? 1'b0 : 1'b1;
        end
        `BLT: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b1 : 1'b0;
        end
        `BGE: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b0 : 1'b1;
        end
        `BLTU: begin
          Branch_Un_Sel = 1'b1;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b1 : 1'b0;
        end
        `BGEU: begin
          Branch_Un_Sel = 1'b1;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b0 : 1'b1;
        end
      endcase
    end
    
    `OPCODE_JAL: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b1;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b10;      // Write Back PC4
      Imm_Gen_Sel     = 2'b11;      // Generates B type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem  
    end
    
    `OPCODE_JALR: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b1;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b10;      // Write Back PC4
      Imm_Gen_Sel     = 2'b00;      // Generates I type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem
    end
    
    `OPCODE_LUI: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;      // Write Back ALU
      Imm_Gen_Sel     = 2'b11;      // Generates J type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to reg
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem 
    end
    
    `OPCODE_AUIPC: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;      // Write Back ALU
      Imm_Gen_Sel     = 2'b11;      // Generates I type 
      ALU_Opcode      = `ALU_OP_ADD;// ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem 
    end
  endcase
  
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
ctrl_logic ctrl_logic (
  .Instruction(),
  .ALU_Opcode(),
  .Reg_Wr_En(),
  .PC_Sel(),
  .ALU_Input_A_Sel(),
  .ALU_Input_B_Sel(),
  .Reg_WB_Sel(),
  .Imm_Gen_Sel(),
  .Lw_Sw_OP(),
  .Store_Word_En(),
  .Branch_Equal(),
  .Branch_Less_Than(),
  .Branch_Un_Sel(),
  .Clk_Enable()
);
*/

endmodule