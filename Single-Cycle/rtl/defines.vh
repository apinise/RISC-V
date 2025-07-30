// ALU Sel Definitions
`define ALU_OP_ADD  4'b0000
`define ALU_OP_SUB  4'b0001
`define ALU_OP_SLL  4'b0010
`define ALU_OP_SLT  4'b0011
`define ALU_OP_SLTU 4'b0100
`define ALU_OP_XOR  4'b0101
`define ALU_OP_SRL  4'b0110
`define ALU_OP_SRA  4'b0111
`define ALU_OP_OR   4'b1000
`define ALU_OP_AND  4'b1001

// Immediate Gen Types
`define I_TYPE  2'b00
`define S_TYPE  2'b01
`define B_TYPE  2'b10
`define J_TYPE  2'b11

// Instruct Function 3
`define FUNCT3_SLL      3'b001
`define FUNCT3_SRL_SRA  3'b101

// LW SW OPCODES 
`define LB_OP_LOAD 	3'b000 //load byte signed
`define LH_OP_LOAD 	3'b001 //load half word signed
`define LW_OP_LOAD 	3'b010 //load word
`define LBU_OP_LOAD 3'b011 //load byte unsigned
`define LHU_OP_LOAD 3'b100 //load half word unsigned
`define SB_OP_STORE 3'b101 //store byte opcode
`define SH_OP_STORE 3'b110 //store half word opcode
`define SW_OP_STORE 3'b111 //store word opcode

// INSTRUCT 7 OPCODES
`define OPCODE_ALU_R      7'b0110011
`define OPCODE_ALU_IMM_I  7'b0010011
`define OPCODE_LW         7'b0000011
`define OPCODE_SW         7'b0100011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_JALR       7'b1100111
`define OPCODE_JAL        7'b1101111
`define OPCODE_LUI        7'b0110111
`define OPCODE_AUIPC      7'b0010111
`define OPCODE_HALT       7'b1111111
`define OPCODE_ECTRL      7'b1110011

// Branch FUNCT3
`define BEQ  3'b000
`define BNE  3'b001
`define BLT  3'b100
`define BGE  3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// Load Word Funct3
`define LB_LOAD  3'b000
`define LH_LOAD  3'b001
`define LW_LOAD  3'b010
`define LBU_LOAD 3'b100
`define LHU_LOAD 3'b101
    
// Store Word Funct3
`define SB_STORE 3'b000
`define SH_STORE 3'b001
`define SW_STORE 3'b010

// R Type Instruction ALU OPCODES
`define ADD_SUB 3'b000
`define SLL     3'b001
`define SLT     3'b010
`define SLTU    3'b011
`define XOR     3'b100
`define SRL_SRA 3'b101
`define OR      3'b110
`define AND     3'b111