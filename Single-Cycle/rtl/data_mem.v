`timescale 1ns / 1ps

module data_mem #(
  parameter MEM_SIZE  = 256,
  parameter NUM_COL   = 4,
  parameter COL_WIDTH = 8
)(
  input   wire          Clk_Core,
  input   wire          Read_Ctrl,
  input   wire  [3:0]   Write_Ctrl,
  input   wire  [31:0]  Mem_Data_Address,
  input   wire  [31:0]  Mem_Data_Write,
  output  reg   [31:0]  Mem_Data_Read
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam DWIDTH = NUM_COL * COL_WIDTH;	// Create DWIDTH Parameter
localparam ADDR_SIZE = $clog2(MEM_SIZE);	// Create Address size

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

reg   [DWIDTH-1:0]    data_mem [MEM_SIZE-1:0];
wire  [ADDR_SIZE-1:0] mem_address;

genvar  i;
integer j;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin //initialize data memory to all 0
  for(j=0; j<MEM_SIZE; j=j+1) begin
    data_mem[j] = 32'b0;
  end
end

assign mem_address = Mem_Data_Address[ADDR_SIZE+1:2];	// Assign effective address range

// Write Port Generate
generate
  for (i=0; i<NUM_COL; i=i+1) begin
    always @(posedge Clk_Core) begin
      if (mem_address < MEM_SIZE) begin
        if (Write_Ctrl[i]) begin	// Makes 4 locations per word
          data_mem[mem_address][i*COL_WIDTH +: COL_WIDTH] <= Mem_Data_Write[i*COL_WIDTH +: COL_WIDTH];
        end
      end
    end
  end
endgenerate

// Read Port
always @(posedge Clk_Core) begin
  if (Read_Ctrl && ((mem_address) < MEM_SIZE)) begin 
    Mem_Data_Read <= data_mem[mem_address];
  end 
  else begin
    Mem_Data_Read <= 32'bz;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem #(
  .MEM_SIZE()
)
data_mem(
  .Clk_Core(),
  .Read_Ctrl(),
  .Write_Ctrl(),
  .Mem_Data_Address(),
  .Mem_Data_Write(),
  .Mem_Data_Read()
);
*/

endmodule
