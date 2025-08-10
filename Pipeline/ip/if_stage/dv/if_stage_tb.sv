`timescale 1ns/1ps

module if_stage_tb;

  // DUT inputs
  logic clk;
  logic rst_n;
  logic pc_sel;
  logic flush;
  logic stall;
  logic [31:0] pc_imm;

  // DUT outputs
  logic [31:0] if_id_pc;
  logic [31:0] if_id_pc_offset;
  logic [31:0] if_id_instruction;

  // Instantiate DUT
  if_stage dut (
    .clk               (clk),
    .rst_n             (rst_n),
    .pc_sel            (pc_sel),
    .flush             (flush),
    .stall             (stall),
    .pc_imm            (pc_imm),
    .if_id_pc          (if_id_pc),
    .if_id_pc_offset   (if_id_pc_offset),
    .if_id_instruction (if_id_instruction)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz clock

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, if_stage_tb);
    $display("VCD dump started.");
  end

  // Test stimulus
  initial begin
    // Init inputs
    rst_n   = 0;
    pc_sel  = 0;
    flush   = 0;
    stall   = 0;
    pc_imm  = 32'h0000_0000;

    // Apply reset
    $display("Applying reset...");
    #20;
    rst_n = 1;

    // Normal operation
    repeat (5) @(posedge clk);

    // Branch (pc_sel=1)
    $display("Branch to pc + imm");
    pc_sel = 1;
    pc_imm = 32'h0000_0020;
    @(posedge clk);
    pc_sel = 0;
    repeat (2) @(posedge clk);

    // Stall
    $display("Stalling for 3 cycles");
    stall = 1;
    repeat (3) @(posedge clk);
    stall = 0;

    // Flush
    $display("Flushing (NOP inject)");
    pc_imm = 32'h00000040;
    pc_sel = 1;
    flush = 1;
    @(posedge clk);
    pc_sel = 0;
    flush = 0;

    // Run a few more cycles
    repeat (5) @(posedge clk);

    $finish;
  end

  // Monitor changes
  always @(posedge clk) begin
    $display("[%0t] PC=%h, PC_OFF=%h, INSTR=%h, stall=%b, flush=%b",
             $time, if_id_pc, if_id_pc_offset, if_id_instruction, stall, flush);
  end

endmodule
