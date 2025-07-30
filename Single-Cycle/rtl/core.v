`timescale 1ns / 1ps

module core (
  // Global clock and reset
  input   wire        Clk_Core_IF,
  input   wire        Clk_Core_WB,
  input   wire        Rst_Core_N,
  // Instruction memory interface
  input   wire [31:0] Instruction,    // Instruction from mem
  output  wire [31:0] Program_Count,  // Program count for mem address
  // Data memory interface
  input   wire [31:0] Mem_Data_Read,  // 32-bit data read from data mem
  output  wire [31:0] Mem_Data_Write, // 32-bit data read from data mem
  output  wire [31:0] Mem_Data_Addr,  // Data mem read/write addr
  output  wire        Mem_Read_Ctrl,  // Data mem read ctrl
  output  wire [3:0]  Mem_Write_Ctrl  // Data mem write ctrl
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// REGISTER FILE NETS
// Nets for register read data
wire [31:0] reg_read_data_1;
wire [31:0] reg_read_data_2;
// Nets for register read addr
wire [4:0]  reg_read_addr_1;
wire [4:0]  reg_read_addr_2;
// Nets for register write
wire [31:0] reg_write_data;
wire [4:0]  reg_write_addr;
// Nets for register write enable
wire        reg_wr_en;

// ALU NETS
// Nets for alu input data from muxs
wire [31:0]  alu_input_a;
wire [31:0]  alu_input_b;
// Nets for general purpose alu signals
wire [31:0]  alu_output;
wire [3:0]   alu_opcode;
wire         alu_zero_flag;

// PROGRAM COUNTER NETS
// Nets for program counter signals
wire [31:0] program_count;
wire [31:0] program_count_offset;
wire [31:0] program_count_imm;

// IMMEDIATE GEN NETS
wire [31:0] immediate_gen_output;

// DATA MEM CTRL INTERFACE NETS
wire [1:0]  data_mem_addr_lsb;
wire [31:0] data_mem_read_out;

// BRANCH COMPARATOR NETS
wire branch_equal_comp;
wire branch_less_than_comp;

// CTRL LOGIC NETS
// Nets for mux control signals
wire        mux_pc_sel;
wire        mux_alu_a_sel;
wire        mux_alu_b_sel;
wire [1:0]  mux_wb_sel;
// Misc ctrl signals
wire [1:0]  imm_gen_sel;
// Data mem control signals
wire [2:0]  lw_sw_opcode;
wire        data_mem_sw_enable;
// Branch control signals
wire        branch_unsigned_sel;
wire        pc_halt;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

// Control Logic
ctrl_logic ctrl_logic (
  .Instruction      (Instruction),        // Instruct from mem
  .ALU_Opcode       (alu_opcode),         // ALU Opcode to alu
  .Reg_Wr_En        (reg_wr_en),          // Reg write enable to reg
  .PC_Sel           (mux_pc_sel),         // PC Mux selection
  .ALU_Input_A_Sel  (mux_alu_a_sel),      // ALU input a selection
  .ALU_Input_B_Sel  (mux_alu_b_sel),      // ALU input b selection
  .Reg_WB_Sel       (mux_wb_sel),         // Reg write back mux selection
  .Imm_Gen_Sel      (imm_gen_sel),        // Immediate generator type selection
  .Lw_Sw_OP         (lw_sw_opcode),       // Opcode for lw sw data mem ctrl
  .Store_Word_En    (data_mem_sw_enable), // Enable sw for data mem
  .Read_Ctrl        (Mem_Read_Ctrl),
  .Branch_Equal     (branch_equal_comp),
  .Branch_Less_Than (branch_less_than_comp),
  .Branch_Un_Sel    (branch_unsigned_sel),
  .Halt             (pc_halt)
);

// Program Counter
program_counter program_counter (
  .Clk_Core         (Clk_Core_IF),
  .Rst_Core_N       (Rst_Core_N),
  .PC_Sel           (mux_pc_sel),           // Program counter load selection
  .Program_Count_Imm(program_count_imm),    // ALU value to load to pc
  .Program_Count_Off(program_count_offset), // PC+4 value to load to pc
  .Program_Count    (Program_Count),        // Current pc to instruct mem, and alu input a mux
  .Halt             (pc_halt)
);

// ALU
alu alu (
  .ALU_In_A     (alu_input_a),  // ALU input a from mux
  .ALU_In_B     (alu_input_b),  // ALU input b from mux
  .ALU_OP       (alu_opcode),   // ALU opcode from ctrl logic
  .ALU_Out      (alu_output),   // ALU output to write back mux, data mem, pc mux
  .ALU_Zero_Flag(alu_zero_flag) // ALU zero flag
);

// Register File
register_file register_file (
  .Clk_Core         (Clk_Core_WB),
  .Rst_Core_N       (Rst_Core_N),
  .Read_Addr_Port_1 (reg_read_addr_1),  // Reg read addr 1 from instruction
  .Read_Data_Port_1 (reg_read_data_1),  // Reg read data 1 to alu input a mux
  .Read_Addr_Port_2 (reg_read_addr_2),  // Reg read addr 2 from instruction
  .Read_Data_Port_2 (reg_read_data_2),  // Reg read data 2 to alu input b mux
  .Write_Addr_Port_1(reg_write_addr),   // Reg write addr from instruction
  .Write_Data_Port_1(reg_write_data),   // Reg write data from writeback mux
  .Wr_En            (reg_wr_en)         // Reg write ctrl from ctrl logic
);

// Immediate Generator
imm_gen imm_gen (
  .Instruction(Instruction),
  .Imm_Sel    (imm_gen_sel),
  .Imm_Gen_Out(immediate_gen_output)
);

// Data Mem Interface Control
data_mem_ctrl data_mem_ctrl (
  .Mem_Addr_LSB       (data_mem_addr_lsb),  // 2-bit lsb of ALU address result
  .Lw_Sw_OP           (lw_sw_opcode),       // LW SW opcode
  .Register_In_B      (reg_read_data_2),    // Data to write into data mem from reg
  .Data_Mem_Read      (Mem_Data_Read),      // Data read from mem
  .Store_Word_Ctrl    (data_mem_sw_enable), // Enable writing to mem
  .Data_Mem_Write_Ctrl(Mem_Write_Ctrl),     // Generate mem byte write enable
  .Data_Mem_Read_Out  (data_mem_read_out),  // Sign extended read data to writeback
  .Data_Mem_Write_Out (Mem_Data_Write)      // Data to write to mem after 
);

// Branch Comparator
branch_comp branch_comp (
  .Read_Reg_Data_1(reg_read_data_1),
  .Read_Reg_Data_2(reg_read_data_2),
  .Branch_Un_Ctrl (branch_unsigned_sel),
  .Branch_Equal   (branch_equal_comp),
  .Branch_Lt      (branch_less_than_comp)
);

// Multiplexers for alu inputs
mux2to1 alu_in_a_mux (
  .Mux_In_A (reg_read_data_1),  // Reg data
  .Mux_In_B (program_count),    // Current PC
  .Input_Sel(mux_alu_a_sel),
  .Mux_Out  (alu_input_a)
);

mux2to1 alu_in_b_mux (
  .Mux_In_A (reg_read_data_2),      // Reg data
  .Mux_In_B (immediate_gen_output), // Immediate gen value
  .Input_Sel(mux_alu_b_sel),
  .Mux_Out  (alu_input_b)
);

// Multiplexer for data write back
mux3to1 write_back_mux (
  .Mux_In_A (data_mem_read_out),    // Data mem value
  .Mux_In_B (alu_output),           // ALU output value
  .Mux_In_C (program_count_offset), // PC+4 value
  .Input_Sel(mux_wb_sel),           // Writeback selection from ctrl logic
  .Mux_Out  (reg_write_data)        // Writeback data to reg data port
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Register assignments
assign reg_read_addr_1  = Instruction[19:15];
assign reg_read_addr_2  = Instruction[24:20];
assign reg_write_addr   = Instruction[11:7];

// Program counter assignments
assign program_count      = Program_Count;
assign program_count_imm  = alu_output;

// Data Mem Ctrl Interface assignments
assign data_mem_addr_lsb  = alu_output[1:0];
assign Mem_Data_Addr      = alu_output;

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
core #(
  .DWIDTH()
)
core (
  .Clk_Core_IF(),
  .Clk_Core_WB(),
  .Rst_Core_N(),
  .Instruction(),
  .Program_Count(),
  .Mem_Data_Read(),
  .Mem_Data_Write(),
  .Mem_Data_Addr(),
  .Mem_Read_Ctrl(),
  .Mem_Write_Ctrl()
);
*/

endmodule