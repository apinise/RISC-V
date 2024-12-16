`timescale 1ns / 1ps

module branch_comp (
  input   wire  [31:0]  Read_Reg_Data_1,
  input   wire  [31:0]  Read_Reg_Data_2,
  input   wire          Branch_Un_Ctrl,
  output  reg           Branch_Equal,
  output  reg           Branch_Lt
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always @(*) begin
  Branch_Equal = (Read_Reg_Data_1 == Read_Reg_Data_2) ? 1'b1 : 1'b0;
  
  if (Branch_Un_Ctrl) begin
    Branch_Lt = (Read_Reg_Data_1 < Read_Reg_Data_2) ? 1'b1 : 1'b0;
  end
  else begin
    Branch_Lt = ($signed(Read_Reg_Data_1) < $signed(Read_Reg_Data_2)) ? 1'b1 : 1'b0;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
branch_comp branch_comp (
  .Read_Reg_Data_1(),
  .Read_Reg_Data_2(),
  .Branch_Un_Ctrl(),
  .Branch_Equal(),
  .Branch_Lt()
);
*/

endmodule