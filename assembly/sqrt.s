.globl _start

.section .data
output:
    .skip 4
input:
    .align 4
    .skip 4 # input is a

.section .text
_start:
    # ask for input
    li a0, 0                # load file descriptor
    la a1, input            # load offset of closest label where input should be copied into
    add a1, a1, 12          # add 12 to get to the correct expected offset (it was aligned)
    li a2, 4                # length of stdin to copy
    li a7, 63               # syscall to request and copy input from stdin
    ecall                   # make syscall

    # translate input from ascii to the translated base10 number
    li t2, 48               # number to subtract from a 1 digit number to translate it to its base 10 equivalent, load it into t2
                            # t0 = a
                            # t1 = digit
                            # t2 = 48
                            # t3 = 10 ** digitIndex

    # translate each digit and take its place/position in the number into account as a power
    /*
        let digit = input argument

        let total: int = output;
        
        let digit: str = digits[0]
        let digit: int = int(digit) - 48
        let num: int = (num * (10 ** 3)) + total

        let digit: str = digits[1]
        let digit: int = int(digit) - 48
        let num: int = (num * (10 ** 2)) + total

        let digit: str = digits[2]
        let digit: int = int(digit) - 48
        let num: int = (num * (10 ** 1)) + total

        let digit: str = digits[3]
        let digit: int = int(digit) - 48
        let num: int = (num * (10 ** 0)) + total
    */
    la t1, input            # load offset of closest label where input is stored
    lb t1, 12(t1)           # load the first byte (from input + 12) into t1
    sub t1, t1, t2          # t1 -= t2 subtract 48 from it
    li t3, 1000             # t3 = 1000
    mul t0, t1, t3          # t0 = digit * 1000 

    la t1, input            # load offset of closest label where input is stored
    lb t1, 13(t1)           # load the second byte (from input + 13) into t1
    sub t1, t1, t2          # t1 -= t2 subtract 48 from it
    li t3, 100              # t3 = 100
    mul t1, t1, t3          # t1 = digit * 100, we don't need digit again so we can overwrite t1
    add t0, t0, t1          # t0 += t1

    la t1, input            # load offset of closest label where input is stored
    lb t1, 14(t1)           # load the third byte (from input + 14) into t1
    sub t1, t1, t2          # t1 -= t2 subtract 48 from it
    li t3, 10               # t3 = 10
    mul t1, t1, t3          # t1 = digit * 100, we don't need digit again so we can overwrite t1
    add t0, t0, t1          # t0 += t1

    la t1, input            # load offset of closest label where input is stored
    lb t1, 15(t1)           # load the fourth byte (from input + 15) into t1
    sub t1, t1, t2          # t1 -= t2 subtract 48 from it
    add t0, t0, t1          # to += t1


    # square root calculation, babylonian method, 10 iterations
    /*
        let a = input argument
        let b = output

        b = a / 2
        for(let i; i < 10; i++) {
            b = (b + (a/b)) / 2
        }
    */
    # b = a / 2
    li t2, 2                # t2 = 2
    div t1, t0, t2          # b = a / 2
    li t3, 0                # t3 = i
    li t5, 10               # t5 = loop iterations

    LOOP:
        mv t4, t1           # pre_b
        div t1, t0, t4      # a/b
        add t1, t1, t4      # b + a/b
        div t1, t1, t2      # (b + a/b) / 2
        add t3, t3, 1       # t3 += 1
        bne t3, t5, LOOP    # continue loop if not equal


    # convert to and store the result as ascii
    /*
        let total = input argument
        let digits: [4] = output

        let x = total / (10 ** 3))
        if (x > 0) {
            digits[0] = x + 48
            total -= (x * (10 ** 3))
        }

        let x = total / (10 ** 2))
        if (x > 0) {
            digits[1] = x + 48
            total -= (x * (10 ** 2))
        }

        let x = total / (10 ** 1))
        if (x > 0) {
            digits[0] = x + 48
            total -= (x * (10 ** 1))
        }

        let x = total / (10 ** 0))
        if (x > 0) {
            digits[0] = x + 48
        }
    */
    la t3, output           # store output address offset

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



    # output it to stdout
    li a0, 1
    mv a1, t3
    li a2, 4
    li a7, 64
    ecall


    # exit with code 0
    li a0, 0
    li a7, 93
    ecall
    