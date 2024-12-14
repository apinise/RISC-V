//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/14/2024 09:54:34 PM
// Design Name: 
// Module Name: program_counter.v
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

module program_counter (
	input	wire		Clk_Core,
	input	wire		Rst_Core_N,
	input	wire		PC_Sel,
	input	wire [31:0]	Program_Count_Imm,
	output  wire [31:0]	Progeam_Count_Off,
	output  wire [31:0]	Program_Count
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

wire [31:0] program_count_four;
wire [31:0] program_count_new;
reg  [31:0] program_count_reg;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Calculate constant +4 offset of PC
assign program_count_four = program_count_reg + 32'd4;

// Multiplexer for selecting pc source
assign program_count_new = (PC_Sel == 1'b1) ? Program_Count_Imm : program_count_four;

// PC Register
always @(posedge Clk_Core or negedge Rst_Core_N) begin
	if (~Rst_Core_N) begin
		program_count_reg <= 32'd0;
	end
	else begin
		program_count_reg <= program_count_new;
	end
end

assign Program_Count_Off = program_count_four;
assign Program_Count = program_count_reg;

endmodule
