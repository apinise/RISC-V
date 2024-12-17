`timescale 1ns/1ps

module data_mem_tb (
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter SEED = 5;
  
localparam MEM_SIZE = 256;
localparam ADDR_SIZE = $clog2(MEM_SIZE);
localparam NUM_TESTS = 100;


////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// Inputs
reg          Clk_Core;
reg          Read_Ctrl;
reg  [3:0]   Write_Ctrl;
reg  [31:0]  Mem_Data_Address;
reg  [31:0]  Mem_Data_Write;

// Outputs
wire [31:0]  Mem_Data_Read;

// Internal variables
reg [31:0] expected_data [MEM_SIZE-1:0];
integer i;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

data_mem #(
  .MEM_SIZE(MEM_SIZE)
)
DUT (
  .Clk_Core(Clk_Core),
  .Read_Ctrl(Read_Ctrl),
  .Write_Ctrl(Write_Ctrl),
  .Mem_Data_Address(Mem_Data_Address),
  .Mem_Data_Write(Mem_Data_Write),
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

  $dumpfile("data_mem.vcd");
  $dumpvars(0, data_mem_tb);
  
  $random(SEED);

  // Initialize signals
  Read_Ctrl = 0;
  Write_Ctrl = 4'b0000;
  Mem_Data_Address = 32'b0;
  Mem_Data_Write = 32'b0;

  // Initialize expected data memory array
  for (i = 0; i < MEM_SIZE; i = i + 1) begin
    expected_data[i] = 32'b0;
  end

  // Perform random write and read operations
  for (i = 0; i < NUM_TESTS; i = i + 1) begin
    @(posedge Clk_Core);

    // Randomly generate address, data, and write control
    Mem_Data_Address = $random % (MEM_SIZE * 4); // Word-aligned address
    Mem_Data_Write = $random;
    Write_Ctrl = $random & 4'b1111; // Random byte enables

    // Perform write operation
    if (|Write_Ctrl) begin
      expected_data[Mem_Data_Address[ADDR_SIZE+1:2]] = (expected_data[Mem_Data_Address[ADDR_SIZE+1:2]] & ~write_mask(Write_Ctrl)) |
                                                       (Mem_Data_Write & write_mask(Write_Ctrl));
      @(posedge Clk_Core);
    end

    // Perform read operation
    Read_Ctrl = 1;
    @(posedge Clk_Core);
    
    #1;

    if (Mem_Data_Read !== expected_data[Mem_Data_Address[ADDR_SIZE+1:2]]) begin
      $display("[ERROR] Address: %h, Expected: %h, Got: %h", Mem_Data_Address, expected_data[Mem_Data_Address[ADDR_SIZE+1:2]], Mem_Data_Read);
    end else begin
      $display("[PASS] Address: %h, Data: %h", Mem_Data_Address, Mem_Data_Read);
    end

    Read_Ctrl = 0;
  end

  // Finish simulation
  $display("Testbench completed!");
  $finish;
end

// Function to generate write mask based on Write_Ctrl
function [31:0] write_mask(input [3:0] Write_Ctrl);
  integer j;
  begin
    write_mask = 32'b0;
    for (j = 0; j < 4; j = j + 1) begin
      if (Write_Ctrl[j]) begin
        write_mask[j*8 +: 8] = 8'hFF;
      end
    end
  end
endfunction

endmodule

