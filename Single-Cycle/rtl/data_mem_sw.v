`timescale 1ns / 1ps

module data_mem_sw (
  input   wire  [2:0]   Lw_Sw_OP,
  input   wire  [3:0]   Write_Ctrl,
  input   wire  [31:0]  Register_In_B,
  output  reg   [31:0]  Data_Mem_Write
);

`include "define.vh"

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
	Data_Mem_Write = 32'b0;
	
  case(Lw_Sw_OP)
		`SB_OP_STORE: begin
			case(Write_Ctrl)
				4'b0001: Data_Mem_Write = {24'd0, Register_In_B[7:0]};			  // Store lower byte of reg into lower byte of mem
				4'b0010: Data_Mem_Write = {16'd0, Register_In_B[7:0], 8'd0};	// Store lower byte of reg into middle lower byte of mem
				4'b0100: Data_Mem_Write = {8'd0, Register_In_B[7:0], 16'd0};	// Store lower byte of reg into middle upper byte of mem
				4'b1000: Data_Mem_Write = {Register_In_B[7:0], 24'd0};			  // Store lower byte of reg into upper byte of mem
			endcase
		end
		
    `SH_OP_STORE: begin
			case(Write_Ctrl)
				4'b0011: Data_Mem_Write = {16'd0, Register_In_B[15:0]};	// Store lower 2 bytes of reg into lower 2 bytes of mem
				4'b1100: Data_Mem_Write = {Register_In_B[15:0], 16'd0};	// Store lower 2 bytes of reg into upper 2 bytes of mem
			endcase
		end
		
    `SW_OP_STORE: Data_Mem_Write = Register_In_B;	// Store reg into mem
	endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem_sw data_mem_sw (
  .Lw_Sw_OP(),
  .Write_Ctrl(),
  .Register_In_B(),
  .Data_Mem_Write()
);
*/

endmodule