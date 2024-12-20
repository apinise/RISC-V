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

integer file, line_num, i, target_pc, Test_Failed;
reg [31:0] instr;
reg [31:0] init;
reg [31:0] expected;

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
end

// Run Tests
initial begin

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              ADD                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing add instructions
    file = $fopen("../../programs/add.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/add.hex");
        $finish;
    end
    
    // Load instructions into mem
    line_num = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", instr) > 0) begin
            force DUT.instruction_mem.instr_mem[line_num] = instr;
            line_num = line_num + 1;
        end
    end
    $fclose(file);
    //$display("Instruction memory initialized from ../../programs/add.hex");
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/add_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/add_reg_init.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", init) > 0) begin
            DUT.core_1.register_file.reg_array[i] = init;
            i = i + 1;
        end
    end
    $fclose(file);
    //$display("Register file initialized from ../../programs/add_reg_init.hex");
    
    $display("\n################################################################################\n");
    
    $display("RUNNING TESTS FOR ADD INSTRUCTION\n");

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/add_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/add_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            $display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("\nADD INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("\nADD INSTRUCTION TESTING PASSED");
    end
    
    Test_Failed = 0;
    
    $display("\n################################################################################\n");

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SUB                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing sub instructions
    file = $fopen("../../programs/sub.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sub.hex");
        $finish;
    end
    
    // Load instructions into mem
    line_num = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", instr) > 0) begin
            force DUT.instruction_mem.instr_mem[line_num] = instr;
            line_num = line_num + 1;
        end
    end
    $fclose(file);
    //$display("Instruction memory initialized from ../../programs/sub.hex");
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/sub_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sub_reg_init.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", init) > 0) begin
            DUT.core_1.register_file.reg_array[i] = init;
            i = i + 1;
        end
    end
    $fclose(file);
    //$display("Register file initialized from ../../programs/sub_reg_init.hex");
    
    $display("\n################################################################################\n");
    
    $display("RUNNING TESTS FOR SUB INSTRUCTION\n");

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/sub_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sub_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            $display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("\nSUB INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("\nSUB INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;
    
    $display("\n################################################################################\n");

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    $finish;
    
end

endmodule