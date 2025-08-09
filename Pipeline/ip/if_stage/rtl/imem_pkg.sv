package imem_pkg;

  // Size of instruction memory in words
  parameter int IMEM_SIZE = 128;

  // Address width
  parameter int IMEM_ADDR = $clog2(IMEM_SIZE);

endpackage : imem_pkg