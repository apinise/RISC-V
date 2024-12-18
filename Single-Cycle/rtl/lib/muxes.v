`timescale 1ns / 1ps

module mux2to1 #(
  parameter DWIDTH =32
)(
  input   wire  [DWIDTH-1:0]  Mux_In_A,
  input   wire  [DWIDTH-1:0]  Mux_In_B,
  input   wire                Input_Sel,
  output  reg   [DWIDTH-1:0]  Mux_Out
);

always @(*) begin
  Mux_Out = {DWIDTH{1'b0}};
  case(Input_Sel)
    1'b0: Mux_Out = Mux_In_A;
    1'b1: Mux_Out = Mux_In_B;
  endcase
end

/*
mux2to1 #(
  .DWIDTH()
)
mux2to1 (
  .Mux_In_A(),
  .Mux_In_B(),
  .Input_Sel(),
  .Mux_Out()
);
*/

endmodule

module mux3to1 #(
  parameter DWIDTH = 32
)(
  input  wire [DWIDTH-1:0]  Mux_In_A,
  input  wire [DWIDTH-1:0]  Mux_In_B,
  input  wire [DWIDTH-1:0]  Mux_In_C,
  input  wire [1:0]         Input_Sel,
  output reg  [DWIDTH-1:0]  Mux_Out
);

always @(*) begin
  Mux_Out = {DWIDTH{1'b0}};
  case(Input_Sel)
    2'b00: Mux_Out = Mux_In_A;
    2'b01: Mux_Out = Mux_In_B;
    2'b10: Mux_Out = Mux_In_C;
  endcase
end

/*
mux3to1 #(
  .DWIDTH()
)
mux3to1 (
  .Mux_In_A(),
  .Mux_In_B(),
  .Mux_In_C(),
  .Input_Sel(),
  .Mux_Out()
);
*/

endmodule