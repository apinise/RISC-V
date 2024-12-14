`timescale 1ns / 1ps

module register_file_tb(
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter SEED = 5;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

reg           Clk_Core;
reg           Rst_Core_N;
reg   [4:0]   Read_Addr_Port_1;
wire  [31:0]  Read_Data_Port_1;
reg   [4:0]   Read_Addr_Port_2;
wire  [31:0]  Read_Data_Port_2;
reg   [4:0]   Write_Addr_Port_1;
reg   [31:0]  Write_Data_Port_1;
reg           Wr_En;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

register_file DUT (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .Read_Addr_Port_1(Read_Addr_Port_1),
  .Read_Data_Port_1(Read_Data_Port_1),
  .Read_Addr_Port_2(Read_Addr_Port_2),
  .Read_Data_Port_2(Read_Data_Port_2),
  .Write_Addr_Port_1(Write_Addr_Port_1),
  .Write_Data_Port_1(Write_Data_Port_1),
  .Wr_En(Wr_En)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Clock Generation
initial Clk_Core = 0;
always #5 Clk_Core = ~Clk_Core; // 10ns clock period

// Testbench Variables
integer i;
reg [31:0] write_data [0:31];

// Reset Sequence
initial begin

  $dumpfile("register_file.vcd");
  $dumpvars(0, register_file_tb);
  
  $random(SEED);  

  Rst_Core_N = 0;
  Wr_En = 0;
  Write_Addr_Port_1 = 0;
  Write_Data_Port_1 = 0;
  Read_Addr_Port_1 = 0;
  Read_Addr_Port_2 = 0;

  #20; // Wait for some time
  Rst_Core_N = 1;
end

// Test Procedure
initial begin
    @(posedge Rst_Core_N); // Wait for reset release

    // Attempt to write to address 0 and verify it does not change
    @(posedge Clk_Core);
    Write_Addr_Port_1 = 0;
    Write_Data_Port_1 = 32'hDEADBEEF;
    Wr_En = 1;
    @(posedge Clk_Core);
    Wr_En = 0;

    // Read back address 0 to verify it remains 0
    @(posedge Clk_Core);
    Read_Addr_Port_1 = 0;
    Read_Addr_Port_2 = 0;
    @(negedge Clk_Core);
    if (Read_Data_Port_1 !== 32'd0) begin
        $display("ERROR: Address 0 was modified on Read Port 1. Expected: 0, Got: %0h", Read_Data_Port_1);
    end else begin
        $display("PASS: Address 0 remains unmodified on Read Port 1.");
    end

    if (Read_Data_Port_2 !== 32'd0) begin
        $display("ERROR: Address 0 was modified on Read Port 2. Expected: 0, Got: %0h", Read_Data_Port_2);
    end else begin
        $display("PASS: Address 0 remains unmodified on Read Port 2.");
    end

    // Perform random writes to the register file
    for (i = 1; i < 32; i = i + 1) begin
        @(posedge Clk_Core);
        Write_Addr_Port_1 = i;
        Write_Data_Port_1 = $random;
        write_data[i] = Write_Data_Port_1; // Store written data for verification
        Wr_En = 1;
    end

    @(posedge Clk_Core);
    Wr_En = 0;

    // Verify the data by reading back through both ports
    for (i = 1; i < 32; i = i + 1) begin
        @(posedge Clk_Core);
        Read_Addr_Port_1 = i;
        Read_Addr_Port_2 = i;
        @(negedge Clk_Core);
        if (Read_Data_Port_1 !== write_data[i]) begin
            $display("ERROR: Mismatch at address %0d on Read Port 1. Expected: %0h, Got: %0h", i, write_data[i], Read_Data_Port_1);
        end else begin
            $display("PASS: Address %0d on Read Port 1. Data: %0h", i, Read_Data_Port_1);
        end

        if (Read_Data_Port_2 !== write_data[i]) begin
            $display("ERROR: Mismatch at address %0d on Read Port 2. Expected: %0h, Got: %0h", i, write_data[i], Read_Data_Port_2);
        end else begin
            $display("PASS: Address %0d on Read Port 2. Data: %0h", i, Read_Data_Port_2);
        end
    end

    // Finish simulation
    $display("Testbench completed.");
    $finish;
end

endmodule