`timescale 1ns / 1ps

module soc_top (
  input wire  Clk_Core_IF,
  input wire  Clk_Core_MEM,
  input wire  Clk_Core_WB,
  input wire  Rst_Core_N
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Instruction Mem Interface Nets
wire [31:0] program_count;
wire [31:0] instruction;

// Data Mem Interface Nets
wire [31:0] data_mem_address;
wire [31:0] data_mem_read;
wire [31:0] data_mem_write;
wire [3:0]  data_mem_write_ctrl;
wire        data_mem_read_ctrl;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

core core_1 (
  .Clk_Core_IF    (Clk_Core_IF),
  .Clk_Core_WB    (Clk_Core_WB),
  .Rst_Core_N     (Rst_Core_N),
  .Instruction    (instruction),
  .Program_Count  (program_count),
  .Mem_Data_Read  (data_mem_read),
  .Mem_Data_Write (data_mem_write),
  .Mem_Data_Addr  (data_mem_address),
  .Mem_Read_Ctrl  (data_mem_read_ctrl),
  .Mem_Write_Ctrl (data_mem_write_ctrl)
);

instruction_mem instruction_mem (
  .Clk_Core       (Clk_Core_IF),
  .Rst_Core_N     (Rst_Core_N),
  .Program_Count  (program_count),
  .Instruction    (instruction)
);

data_mem #(
  .MEM_SIZE(256)
) data_mem (
  .Clk_Core         (Clk_Core_MEM),
  .Read_Ctrl        (data_mem_read_ctrl),
  .Write_Ctrl       (data_mem_write_ctrl),
  .Mem_Data_Address (data_mem_address),
  .Mem_Data_Write   (data_mem_write),
  .Mem_Data_Read    (data_mem_read)
);

endmodule