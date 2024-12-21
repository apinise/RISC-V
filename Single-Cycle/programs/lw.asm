addi x2, x0, 8
addi x1, x0, 1737
slli x1, x1, 18
addi x1, x1, 1737
sw x1, 0(x0)
sw x1, -4(x2)
sw x1, 0(x2)
lw x3, 0(x0)
lw x4, -4(x2)
lw x5, 8(x0)
