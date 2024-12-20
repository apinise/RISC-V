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

integer file, line_num, i, target_pc, Test_Failed, R_Type_Failed, I_Type_Failed;
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
    R_Type_Failed = 0;
    I_Type_Failed = 0;

    $display("\n################################################################################\n");
    $display("RUNNING TESTS FOR R TYPE INSTRUCTIONS\n");

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
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("ADD INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("ADD INSTRUCTION TESTING PASSED");
    end
    
    Test_Failed = 0;

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
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SUB INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SUB INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SLL                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing sll instructions
    file = $fopen("../../programs/sll.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sll.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/sll_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sll_reg_init.hex");
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
    
    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/sll_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sll_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLL INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLL INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SLT                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing slt instructions
    file = $fopen("../../programs/slt.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slt.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/slt_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slt_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/slt_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slt_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLT INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLT INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SLTU                                            //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing sltu instructions
    file = $fopen("../../programs/sltu.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltu.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/sltu_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltu_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/sltu_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltu_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLTU INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLTU INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              XOR                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing xor instructions
    file = $fopen("../../programs/xor.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xor.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/xor_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xor_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/xor_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xor_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("XOR INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("XOR INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SRL                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing srl instructions
    file = $fopen("../../programs/srl.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srl.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/srl_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srl_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/srl_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srl_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SRL INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SRL INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              SRA                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing sra instructions
    file = $fopen("../../programs/sra.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sra.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/sra_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sra_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/sra_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sra_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SRA INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SRA INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              OR                                              //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing or instructions
    file = $fopen("../../programs/or.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/or.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/or_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/or_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/or_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/or_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("OR INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("OR INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                              AND                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing and instructions
    file = $fopen("../../programs/and.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/and.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/and_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/and_reg_init.hex");
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
    
    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/and_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/and_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                R_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("AND INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("AND INSTRUCTION TESTING PASSED");
    end

    if (R_Type_Failed == 1) begin
        $display("\nR TYPE INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("\nR TYPE INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    $display("\n################################################################################\n");
    $display("RUNNING TESTS FOR I TYPE INSTRUCTIONS\n");

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                             ADDI                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing addi instructions
    file = $fopen("../../programs/addi.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/addi.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/addi_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/addi_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/addi_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/addi_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("ADDI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("ADDI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                             SLTI                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing slti instructions
    file = $fopen("../../programs/slti.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slti.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/slti_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slti_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/slti_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slti_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLTI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLTI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                            SLTIU                                             //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing sltiu instructions
    file = $fopen("../../programs/sltiu.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltiu.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/sltiu_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltiu_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/sltiu_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/sltiu_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLTIU INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLTIU INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                            XORI                                              //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing xori instructions
    file = $fopen("../../programs/xori.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xori.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/xori_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xori_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/xori_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/xori_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("XORI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("XORI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                            ORI                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing ori instructions
    file = $fopen("../../programs/ori.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/ori.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/ori_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/ori_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/ori_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/ori_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("ORI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("ORI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                           ANDI                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing andi instructions
    file = $fopen("../../programs/andi.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/andi.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/andi_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/andi_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/andi_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/andi_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("ANDI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("ANDI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                           SLLI                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing slli instructions
    file = $fopen("../../programs/slli.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slli.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/slli_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slli_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/slli_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/slli_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SLLI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SLLI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                           SRLI                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing srli instructions
    file = $fopen("../../programs/srli.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srli.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/srli_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srli_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/srli_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srli_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SRLI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SRLI INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////

    Rst_Core_N = 0;
    repeat (2) begin
      @(posedge Clk_Core_IF);
    end
    Rst_Core_N = 1;

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //                                           SRAI                                               //
    //////////////////////////////////////////////////////////////////////////////////////////////////

    // Begin testing srai instructions
    file = $fopen("../../programs/srai.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srai.hex");
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
    
    target_pc = line_num * 4;
    
    file = $fopen("../../programs/srai_reg_init.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srai_reg_init.hex");
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

    wait (target_pc == DUT.core_1.program_counter.program_count_reg);

    for (i = 0; i < line_num; i = i + 1) begin
        release DUT.instruction_mem.instr_mem[i];
    end
    
    file = $fopen("../../programs/srai_reg_final.hex", "r");
    if (file == 0) begin
        $display("ERROR: Failed to open file ../../programs/srai_reg_final.hex");
        $finish;
    end
    
    i = 0;
    while (!$feof(file)) begin
        if ($fscanf(file, "%h\n", expected) > 0) begin
            //$display("Register Address: %h Expected Value: %h Calculated Value: %h", i, expected, DUT.core_1.register_file.reg_array[i]);
            if (DUT.core_1.register_file.reg_array[i] != expected) begin
                Test_Failed = 1;
                I_Type_Failed = 1;
            end
            i = i + 1;
        end
    end
    
    if (Test_Failed == 1) begin
        $display("SRAI INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("SRAI INSTRUCTION TESTING PASSED");
    end

    if (I_Type_Failed == 1) begin
        $display("\nI TYPE INSTRUCTION TESTING FAILED");
    end
    else begin
        $display("\nI TYPE INSTRUCTION TESTING PASSED");
    end

    Test_Failed = 0;

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