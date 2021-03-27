@ startFeeder.s
@ starts the feeder by setting Pin 19 to high level
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       none
@ Returns:
@       none

GPIOREG .req      r10

    .data
    .balign     4

startMessage:
    .asciz      "feeder started\n"

    .text

    .balign   4
    .global   startFeeder
    .type     startFeeder, %function

startFeeder:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r1, #1
    mov     r0, r1, lsl #19
    str     r0, [GPIOREG, #28]

    ldr     r0, =startMessage
    bl      printf
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
