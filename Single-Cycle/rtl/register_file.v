//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2023 01:57:59 PM
// Design Name: 
// Module Name: register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module register_file(
  // Global Inputs
  input  wire        Clk_Core,           // Core Clk
  input  wire        Rst_Core_N,         // Core Clk Rst
  // Read Addr and Data Port 1
  input  wire [4:0]  Read_Addr_Port_1,   // Source register 1 address
  output reg  [31:0] Read_Data_Port_1,   // Source register 1 data
  // Read Addr and Data Port 2
  input  wire [4:0]  Read_Addr_Port_2,   // Source register 2 address
  output reg  [31:0] Read_Data_Port_2,   // Source register 2 data
  // Write Addr and Data Port 1
  input  wire [4:0]  Write_Addr_Port_1,  // Destination register address
  input  wire [31:0] Write_Data_Port_1,  // Destination register data
  input  wire        Wr_En               // Destination register enable
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

reg [31:0] reg_array [31:0];
integer i;
integer j;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin
  for (i = 0; i < 32; i = i + 1) begin
    reg_array[i] = 32'd0;
  end
end

always @(posedge Clk_Core) begin
    if (Wr_En == 1'b1 && Write_Addr_Port_1 != 32'd0) begin
      reg_array[Write_Addr_Port_1] <= Write_Data_Port_1;
    end
end

assign Read_Data_Port_1 = reg_array[Read_Addr_Port_1];
assign Read_Data_Port_2 = reg_array[Read_Addr_Port_2];

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
register_file (
  .Clk_Core(),
  .Rst_Core_N(),
  .Read_Addr_Port_1(),
  .Read_Data_Port_1(),
  .Read_Addr_Port_2(),
  .Read_Data_Port_2(),
  .Write_Addr_Port_1(),
  .Write_Data_Port_1(),
  .Wr_En()
);
*/

endmodule
