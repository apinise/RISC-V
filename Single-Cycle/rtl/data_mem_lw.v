`timescale 1ns / 1ps

module data_mem_lw (
  input   wire  [2:0]   Lw_Sw_OP,
  input   wire  [1:0]   Byte_Loc,
  input   wire  [31:0]  Data_Mem_Read,
  output  reg   [31:0]  Data_Mem_Read_Out
);

`include "defines.vh"

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always @(*) begin
	Data_Mem_Read_Out = 32'b0;
	
  case(Lw_Sw_OP)	
    `LB_OP_LOAD: begin
			case(Byte_Loc)
				2'b00: Data_Mem_Read_Out = (Data_Mem_Read[7] == 1'b1)  ? {24'hFFFFFF, Data_Mem_Read[7:0]}  : {24'd0, Data_Mem_Read[7:0]};
				2'b01: Data_Mem_Read_Out = (Data_Mem_Read[15] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[15:8]} : {24'd0, Data_Mem_Read[15:8]};
				2'b10: Data_Mem_Read_Out = (Data_Mem_Read[23] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[23:16]} : {24'd0, Data_Mem_Read[23:16]};
				2'b11: Data_Mem_Read_Out = (Data_Mem_Read[31] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[31:24]} : {24'd0, Data_Mem_Read[31:24]};
			endcase
		end
		
    `LH_OP_LOAD: begin
			case(Byte_Loc)
				2'b00: Data_Mem_Read_Out = (Data_Mem_Read[15] == 1'b1) ? {16'hFFFF, Data_Mem_Read[15:0]}  : {16'd0, Data_Mem_Read[15:0]};
				2'b10: Data_Mem_Read_Out = (Data_Mem_Read[31] == 1'b1) ? {16'hFFFF, Data_Mem_Read[31:16]} : {16'd0, Data_Mem_Read[31:16]};
			endcase
		end
		
    `LW_OP_LOAD: Data_Mem_Read_Out = Data_Mem_Read;
		
    `LBU_OP_LOAD: begin
			case(Byte_Loc)
				2'b00: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[7:0]};
				2'b01: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[15:8]};
				2'b10: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[23:16]};
				2'b11: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[31:24]};
			endcase
		end
    
		`LHU_OP_LOAD:
			case(Byte_Loc)
				2'b00: Data_Mem_Read_Out = {16'd0, Data_Mem_Read[15:0]};
				2'b10: Data_Mem_Read_Out = {16'd0, Data_Mem_Read[31:16]};
			endcase
	endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem_lw data_mem_lw (
  .Lw_Sw_OP(),
  .Byte_Loc(),
  .Data_Mem_Read(),
  .Data_Mem_Read_Out()
);
*/

endmodule
