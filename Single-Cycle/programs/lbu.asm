addi x2, x0, 8
addi x1, x0, 1737
slli x1, x1, 18
addi x3, x0, 1804
slli x3, x3, 5
addi x3, x3, 234
add x1, x1, x3
sw x1, 0(x0)
sw x1, -4(x2)
sw x1, 0(x2)
lbu x4, 0(x0)
lbu x5, -4(x2)
lbu x6, 8(x0)
lbu x7, 9(x0)
lbu x8, 10(x0)
lbu x9, 11(x0)
