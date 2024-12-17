`timescale 1ns/1ps

module data_mem_ctrl_tb (
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

`include "../../rtl/defines.vh"

parameter SEED = 5;
  
localparam MEM_SIZE = 256;
localparam ADDR_SIZE = $clog2(MEM_SIZE);
localparam NUM_TESTS = 100;


////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Clock signal
reg Clk_Core;

// Inputs for data_mem_ctrl
reg  [1:0]   Mem_Addr_LSB;
reg  [2:0]   Lw_Sw_OP;
reg  [31:0]  Register_In_B;
reg          Store_Word_Ctrl;

// Interconnection signals
wire [3:0]   Write_Ctrl;
wire [31:0]  Data_Mem_Read_Out;
wire [31:0]  Data_Mem_Write_Out;

// Inputs for data_mem
reg          Read_Ctrl;
reg  [31:0]  Mem_Data_Address;

// Outputs from data_mem
wire [31:0]  Mem_Data_Read;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

// Instantiate the data_mem_ctrl DUT
data_mem_ctrl DUT (
  .Mem_Addr_LSB(Mem_Addr_LSB),
  .Lw_Sw_OP(Lw_Sw_OP),
  .Register_In_B(Register_In_B),
  .Data_Mem_Read(Mem_Data_Read),
  .Store_Word_Ctrl(Store_Word_Ctrl),
  .Data_Mem_Write_Ctrl(Write_Ctrl),
  .Data_Mem_Read_Out(Data_Mem_Read_Out),
  .Data_Mem_Write_Out(Data_Mem_Write_Out)
);

// Instantiate the data_mem module
data_mem #(
  .MEM_SIZE(256),
  .NUM_COL(4),
  .COL_WIDTH(8)
) memory (
  .Clk_Core(Clk_Core),
  .Read_Ctrl(Read_Ctrl),
  .Write_Ctrl(Write_Ctrl),
  .Mem_Data_Address(Mem_Data_Address),
  .Mem_Data_Write(Data_Mem_Write_Out),
  .Mem_Data_Read(Mem_Data_Read)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Clock generation
initial Clk_Core = 0;
always #5 Clk_Core = ~Clk_Core; // 10ns clock period

// Testbench logic
initial begin
  // Initialize inputs
  
  $dumpfile("data_mem_ctrl.vcd");
  $dumpvars(0, data_mem_ctrl_tb);
  
  Mem_Addr_LSB = 2'b00;
  Lw_Sw_OP = 3'b000; // Set to a valid operation, e.g., `LB_OP_LOAD`
  Register_In_B = 32'hDEADBEEF;
  Store_Word_Ctrl = 0;
  Read_Ctrl = 0;
  Mem_Data_Address = 0;

  // Wait for the clock to stabilize
  @(posedge Clk_Core);

  // Test Write Operation
  Mem_Data_Address = 32'h04; // Aligned address
  Register_In_B = 32'hAABBCCDD;
  Lw_Sw_OP = `SW_OP_STORE; // Store word operation
  Store_Word_Ctrl = 1; // Enable store
  @(posedge Clk_Core);

  // Wait and test read operation
  Store_Word_Ctrl = 0; // Disable store
  Read_Ctrl = 1; // Enable read
  Lw_Sw_OP  = `LW_OP_LOAD;
  @(posedge Clk_Core);

  // Validate read data
  if (Data_Mem_Read_Out != 32'hAABBCCDD) begin
    $display("Test failed: Expected 0xAABBCCDD, got %h", Data_Mem_Read_Out);
  end else begin
    $display("Test passed: Data read correctly.");
  end

  @(posedge Clk_Core);
  // Additional tests for different alignment, operations, etc.

  // Test aligned address
  Mem_Data_Address = 32'h08; // Word-aligned
  Lw_Sw_OP = `SW_OP_STORE; // Store word
  Register_In_B = 32'hCAFEBABE;
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Test misaligned address
  Mem_Data_Address = 32'h06; // Half-word aligned
  Lw_Sw_OP = `SH_OP_STORE; // Store half-word
  Register_In_B = 32'h0000F00D; // Test specific bytes
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Test byte access
  Mem_Data_Address = 32'h03; // Byte-aligned
  Lw_Sw_OP = `LB_OP_LOAD; // Store byte
  Register_In_B = 32'h000000AA; // Test specific byte
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Store byte
  Mem_Data_Address = 32'h0A;
  Register_In_B = 32'h12345678;
  Lw_Sw_OP = `LB_OP_LOAD;
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Load byte
  Lw_Sw_OP = `LB_OP_LOAD;
  @(posedge Clk_Core);
  $display("Read Byte: %h", Data_Mem_Read_Out);

  // Store half-word
  Mem_Data_Address = 32'h10;
  Register_In_B = 32'hDEADBEEF;
  Lw_Sw_OP = `SH_OP_STORE;
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Load half-word
  Lw_Sw_OP = `LH_OP_LOAD;
  @(posedge Clk_Core);
  $display("Read Half-Word: %h", Data_Mem_Read_Out);

  // Store word
  Mem_Data_Address = 32'h14;
  Register_In_B = 32'hCAFEBABE;
  Lw_Sw_OP = `SW_OP_STORE;
  Store_Word_Ctrl = 1;
  @(posedge Clk_Core);
  Store_Word_Ctrl = 0;

  // Load word
  Lw_Sw_OP = `LW_OP_LOAD;
  Read_Ctrl = 1;
  @(posedge Clk_Core);
  Read_Ctrl = 0;
  $display("Read Word: %h", Data_Mem_Read_Out);

  // End simulation
  $finish;
end

endmodule

