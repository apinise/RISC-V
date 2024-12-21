addi x1, x0, 1737
slli x1, x1, 18
addi x3, x0, 1804
slli x3, x3, 5
addi x3, x3, 234
add x1, x1, x3
sw x1, 0(x0)
sw x1, -4(x2)
sw x1, 0(x2)
lhu x4, 0(x0)
lhu x5, -4(x2)
lhu x6, 8(x0)
lhu x7, 10(x0)
