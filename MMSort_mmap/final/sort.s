@ sort.s
@ no parameters needed

    .data
    .balign     4

setPinsMessage:
    .asciz      "motor pins 11, 17 and 27 set\n"

    .text

    .balign   4
    .global   sort
    .type     sort, %function

sort:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    bl      startFeeder
    bl      setMotorPins

    sortFor:
        mov     r4, #1
        cmp     r4, #2
        blt     sortLoop

    sortLoop:
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel
        bl      colordetection
        bl      moveOutletToNextColor
        b       sortFor

    bl      clearMotorPins
    bl      stopFeeder

    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
