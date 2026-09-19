main:
    li a0, 5
    jal ra, fib
    li a7, 10
    ecall
    
fib:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    
    addi s0, a0, 0
    
    li t0, 1
    ble s0, t0, Done_base
    
    addi a0, s0, -1
    jal ra, fib
    
    addi s1, a0, 0
    
    addi a0, s0, -2
    jal ra, fib
    
    add a0, s1, a0
    
    j Done
    
Done_base:
    addi a0, s0, 0
    
Done:
    lw   s1,  4(sp)
    lw   s0,  8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    jalr x0, ra, 0
    
    