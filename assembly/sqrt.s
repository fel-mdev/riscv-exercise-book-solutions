.globl _start

.section .data
numbers:
    .skip 4
input:
    .align 4
    .skip 4

.section .text
_start:
    # ask for input
    li a0, 0
    la a1, input
    add a1, a1, 12
    li a2, 4
    li a7, 63
    ecall

    # a = t0
    # b = t1
    li t2, 48

    la t1, input
    lb t1, 12(t1)
    sub t1, t1, t2
    li t3, 1000
    mul t0, t1, t3

    la t1, input
    lb t1, 13(t1)
    sub t1, t1, t2
    li t3, 100
    mul t1, t1, t3
    add t0, t0, t1

    la t1, input
    lb t1, 14(t1)
    sub t1, t1, t2
    li t3, 10
    mul t1, t1, t3
    add t0, t0, t1

    la t1, input
    lb t1, 15(t1)
    sub t1, t1, t2
    add t0, t0, t1


    # b = a / 2
    li t2, 2
    div t1, t0, t2

    LOOP:
        mv t3, t1           # pre_b
        div t1, t0, t3      # a/b
        add t1, t1, t3      # b + a/b
        div t1, t1, t2      # (b + a/b) / 2
        bne t1, t3, LOOP    # continue loop if not equal


    # convert to and store result as ascii

    la t3, numbers

    li t2, 1000
    div t0, t1, t2
    beqz t0, C_100
    addi t4, t0, 48
    sb t4, (t3)
    mul t4, t0, t2
    sub t1, t1, t4

    C_100:
    li t2, 100
    div t0, t1, t2
    beqz t0, C_10
    addi t4, t0, 48
    sb t4, 1(t3)
    mul t4, t0, t2
    sub t1, t1, t4

    C_10:
    li t2, 10
    div t0, t1, t2
    beqz t0, C_1
    addi t4, t0, 48
    sb t4, 2(t3)
    mul t4, t0, t2
    sub t1, t1, t4
    
    C_1:
    addi t4, t1, 48
    sb t4, 3(t3)


    # output
    li a0, 1
    mv a1, t3
    li a2, 4
    li a7, 64
    ecall


    # exit
    li a0, 0
    li a7, 93
    ecall