@ clearMotorPins.s
@ clears the outlet and color wheel motor pins 11, 17 and 27 to low level
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       none
@ Returns:
@       none

GPIOREG .req      r10

    .data
    .balign     4

clearPinsMessage:
    .asciz      "motor pins 11, 17 and 27 cleared\n"

    .text

    .balign   4
    .global   clearMotorPins
    .type     clearMotorPins, %function

clearMotorPins:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    @ set Pin 11 to low level
    mov     r1, #1
    mov     r0, r1, lsl #11
    str     r0, [GPIOREG, #40]

    @ set Pin 17 to low level
    mov     r1, #1
    mov     r0, r1, lsl #17
    str     r0, [GPIOREG, #40]

    @ set Pin 27 to low level
    mov     r1, #1
    mov     r0, r1, lsl #27
    str     r0, [GPIOREG, #40]

    ldr     r0, =clearPinsMessage
    bl      printf
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
