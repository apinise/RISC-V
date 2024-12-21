`timescale 1ns / 1ps

module imm_gen (
  input   wire  [31:0]  Instruction,
  input   wire  [1:0]   Imm_Sel,
  output  reg   [31:0]  Imm_Gen_Out
);

`include "defines.vh"

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

reg [11:0] imm_i_type;
reg [11:0] imm_s_type;
reg [12:0] imm_b_type;
reg [20:0] imm_j_type;

reg [2:0] instruct_funct3;
reg [6:0] instruct_funct7;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always @(*) begin
  Imm_Gen_Out     = 32'b0;
  instruct_funct3 = Instruction[14:12];
  instruct_funct7 = Instruction[6:0];
  
  case (Imm_Sel)
    `I_TYPE: begin
      if ((instruct_funct3 == `FUNCT3_SLL || instruct_funct3 == `FUNCT3_SRL_SRA) && instruct_funct7 == `OPCODE_ALU_R) begin
        Imm_Gen_Out = {{26{1'b0}}, Instruction[24:20]};
      end
      else begin
        Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{21{1'b1}}, Instruction[30:20]} : {{21{1'b0}}, Instruction[30:20]};
      end
    end
    
    `S_TYPE: Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{21{1'b1}}, Instruction[30:25], Instruction[11:7]} : {{21{1'b0}}, Instruction[30:25], Instruction[11:7]};
    
    `B_TYPE: Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{20{1'b1}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0} : {{20{1'b0}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
    
    `J_TYPE: begin
      if (Instruction[6:0] == 7'b1101111) begin
        Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{12{1'b1}},Instruction[19:12],Instruction[20],Instruction[30:21],1'b0} : {{12{1'b0}},Instruction[19:12],Instruction[20],Instruction[30:21],1'b0};
      end
      else begin
        Imm_Gen_Out = {Instruction[31:12], {12{1'b0}}};
      end
    end
  endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
imm_gen imm_gen (
  .Instruction(),
  .Imm_Sel(),
  .Imm_Gen_Out()
);
*/

endmodule