module if_stage (
  input  logic clk,
  input  logic rst_n,
  input  logic pc_sel,
  input  logic flush,
  input  logic stall,
  input  logic [31:0] pc_imm,
  output logic [31:0] if_id_pc,
  output logic [31:0] if_id_pc_offset,
  output logic [31:0] if_id_instruction
);

logic [31:0] pc;
logic [31:0] pc_offset;
logic [31:0] instruct;

imem_rom imem (
  //.clk           (clk),
  //.rst_n         (rst_n),
  .program_count (pc),
  .instruction   (instruct)
);

program_counter program_counter (
  .clk       (clk),
  .rst_n     (rst_n),
  .pc_sel    (pc_sel),
  .stall     (stall),
  .flush     (flush),
  .pc_imm    (pc_imm),
  .pc_offset (pc_offset),
  .pc        (pc)
);

always_ff @(posedge clk) begin
  if (!rst_n) begin
    if_id_pc          <= 32'h0;
    if_id_pc_offset   <= 32'h0;
    if_id_instruction <= 32'h0;
  end
  else if (flush) begin
    if_id_instruction <= 32'h00000013; // NOP
  end
  else if (stall) begin
    if_id_pc          <= if_id_pc;
    if_id_pc_offset   <= if_id_pc_offset;
    if_id_instruction <= if_id_instruction;
  end
  else begin
    if_id_pc          <= pc;
    if_id_pc_offset   <= pc_offset;
    if_id_instruction <= instruct;
  end
end

endmodule