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
`define I_TYPE = 2'b00;
`define S_TYPE = 2'b01;
`define B_TYPE = 2'b10;
`define J_TYPE = 2'b11;

// Instruct Function 3
`define SLL      = 3'b001;
`define SRL_SRA  = 3'b101;