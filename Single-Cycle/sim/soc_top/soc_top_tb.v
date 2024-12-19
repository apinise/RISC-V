`timescale 1ns / 1ps

module soc_top_tb (
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

parameter CLK_PERIOD = 10;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

reg Clk_Core_IF, Clk_Core_MEM, Clk_Core_WB, Rst_Core_N;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

soc_top DUT (
  .Clk_Core_IF  (Clk_Core_IF),
  .Clk_Core_MEM (Clk_Core_MEM),
  .Clk_Core_WB  (Clk_Core_WB),
  .Rst_Core_N   (Rst_Core_N)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin
    // Initialize clocks
    Clk_Core_IF   = 0;
    Clk_Core_MEM  = 0;
    Clk_Core_WB   = 0;

    $dumpfile("soc_top.vcd");
    $dumpvars(0, soc_top_tb);

    // Generate clocks
    forever #(CLK_PERIOD / 2) Clk_Core_IF = ~Clk_Core_IF; // Base clock
end

// Generate clk2 with a 120-degree phase shift
initial begin
    #(CLK_PERIOD / 3); // Delay to introduce phase shift
    forever #(CLK_PERIOD / 2) Clk_Core_MEM = ~Clk_Core_MEM;
end

// Generate clk3 with a 240-degree phase shift
initial begin
    #(2 * CLK_PERIOD / 3); // Delay to introduce phase shift
    forever #(CLK_PERIOD / 2) Clk_Core_WB = ~Clk_Core_WB;
end

initial begin
    Rst_Core_N = 0;
    repeat (10) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;
    repeat (10) begin
      @(posedge Clk_Core_IF);
    end
    $finish;
end

initial begin
    DUT.instruction_mem.instr_mem[0] = 32'h3e800093;
    DUT.instruction_mem.instr_mem[1] = 32'h7d008113;
    DUT.instruction_mem.instr_mem[2] = 32'hc1810193;
    DUT.instruction_mem.instr_mem[3] = 32'h83018213;
    DUT.instruction_mem.instr_mem[4] = 32'h3e820293;
    DUT.instruction_mem.instr_mem[5] = 32'h00010317;
    DUT.instruction_mem.instr_mem[6] = 32'hfec30313;
    DUT.instruction_mem.instr_mem[7] = 32'h00430313;
end

endmodule