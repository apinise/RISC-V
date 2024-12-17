// ALU Sel Definitions
`define ADD  4'b0000
`define SUB  4'b0001
`define SLL  4'b0010
`define SLT  4'b0011
`define SLTU 4'b0100
`define XOR  4'b0101
`define SRL  4'b0110
`define SRA  4'b0111
`define OR   4'b1000
`define AND  4'b1001

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
