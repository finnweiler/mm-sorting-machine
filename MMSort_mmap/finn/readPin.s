@ readPin.s
@ Parameters: 
@       r0  <- number of the pin
@       r10 <- GPIO register
    
    
    .data
    .balign     4

stepMessage:
    .asciz      "stepping\n"
clockwise:
    .asciz      "end\n"

    .text

    .balign   4
    .global   readPin
    .type     readPin, %function

readPin:
    str     lr, [sp, #-8]!

    ldr     r1, [r10], #+64
    mov     r2, #1
    mov     r2, r2, lsl r0
    @and     r0, r2, r1

    ldr     lr, [sp], #+8
    bx      lr


