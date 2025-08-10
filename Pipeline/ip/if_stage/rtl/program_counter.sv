module program_counter (
  input  logic  clk,
  input  logic  rst_n,
  input  logic  pc_sel,
  input  logic  stall,
  input  logic  flush,
  input  logic  [31:0] pc_imm,
  output logic  [31:0] pc_offset,
  output logic  [31:0] pc
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [31:0] pc_four;
logic [31:0] pc_reg;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Calculate constant +4 offset of PC
assign pc_four = pc_reg + 32'd4;

// PC Register
always_ff @(posedge clk) begin
  if (!rst_n) begin
    pc_reg <= 32'd0;
  end
  else if (stall) begin
    pc_reg <= pc_reg;
  end
  else begin
    pc_reg <= pc_sel ? pc_imm : pc_four;
  end
end

assign pc_offset = pc_four;
assign pc = pc_reg;

endmodule