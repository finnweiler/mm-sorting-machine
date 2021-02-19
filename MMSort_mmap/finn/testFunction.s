    .text

    .balign   4
    .global   testFunction
    .type     testFunction, %function

testFunction:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r0, #0
    mov     r1, #5
    bl      stepColorWheel

    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr
