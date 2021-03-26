@ stopFeeder.s
@ no parameters needed

GPIOREG .req      r10

    .data
    .balign     4

stopMessage:
    .asciz      "feeder stopped\n"

    .text

    .balign   4
    .global   stopFeeder
    .type     stopFeeder, %function

 
@ stops the feeder by setting Pin 19 to low level
stopFeeder:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r1, #1
    mov     r0, r1, lsl #19
    str     r0, [GPIOREG, #40]

    ldr     r0, =stopMessage
    bl      printf
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
