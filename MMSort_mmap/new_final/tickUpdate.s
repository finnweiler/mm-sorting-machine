@ sort.s
@ no parameters needed

    .data
    .balign     4

    .text
    .balign   4
    .global   tickUpdate
    .type     tickUpdate, %function

@ is run regulary to update button status
tickUpdate:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    mov     r0, #8 @ read pin 8 / button 1
    bl      readPin

    cmp     r0, #0 @ compare sensor value to 0
    bne     endTickUpdate

    mov     r8, #1

    endTickUpdate:
        @ leaves the function 
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  
        bx      lr
