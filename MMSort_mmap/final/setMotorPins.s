@ setMotorPins.s
@ no parameters needed

    .data
    .balign     4

GPIOREG .req      r10

setPinsMessage:
    .asciz      "motor pins 11, 17 and 27 set\n"

    .text

    .balign   4
    .global   setMotorPins
    .type     setMotorPins, %function

@ sets the outlet and color wheel motor pins 11, 17 and 27 to high level
setMotorPins:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    @ set Pin 11 to high level
    mov     r1, #1
    mov     r0, r1, lsl #11
    str     r0, [GPIOREG, #28]

    @ set Pin 17 to high level
    mov     r1, #1
    mov     r0, r1, lsl #17
    str     r0, [GPIOREG, #28]

    @ set Pin 27 to high-level
    mov     r1, #1
    mov     r0, r1, lsl #27
    str     r0, [GPIOREG, #28]

    ldr     r0, =setPinsMessage
    bl      printf
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
