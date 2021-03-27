@ calibrateColorWheel.s
@ This functions moves the colorWheel to it's initial position
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters: 
@       none
@ Returns:
@       none

    .data
    .balign     4

rightEdge:
    .asciz      "!! searching for right edge\n"

leftEdge:
    .asciz      "!! searching for left edge\n"

center:
    .asciz      "!! moving to center, total steps made: %d\n"

    .text

    .balign   4
    .global   calibrateColorWheel
    .type     calibrateColorWheel, %function

calibrateColorWheel:
    str     lr, [sp, #-4]!  @ store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!  @ store value of r4 in the stack

    mov     r4, #0 @ clear r4 to use it as a counter later on

    findContact:
        mov     r0, #20 
        bl      readPin @ read value of hall sensor

        cmp     r0, #0 @ check hall sensor state
        beq     prepareRightEdge @ if hall sensor has contact, it can start searching for the right edge

        @ else:
        mov     r0, #0
        mov     r1, #1
        bl      stepColorWheel @ move color wheel 1 step clockwise

        b       findContact @ repeat the loop

    prepareRightEdge:
        ldr     r0, =rightEdge
        bl      printf

    findRightEdge:
        mov     r0, #20
        bl      readPin @ read value of hall sensor

        cmp     r0, #0  @ check hall sensor state
        bne     prepareLeftEdge @ if hall sensor lost contact, prepare to find left edge

        @ else:
        mov     r0, #1
        mov     r1, #1
        bl      stepColorWheel @ move color wheel 1 step counter-clockwise

        b       findRightEdge @ repeat the loop

    prepareLeftEdge: @ move outlet a bit clockwise to make sure the hall sensor has contact again
        ldr     r0, =leftEdge
        bl      printf

        mov     r0, #0
        mov     r1, #5
        bl      stepColorWheel @ move color wheel 5 steps clockwise

        add     r4, r4, #5 @ increment step-counter by 5 steps

    findLeftEdge:
        mov     r0, #0
        mov     r1, #1
        bl      stepColorWheel @ move color wheel 1 step clockwise

        add     r4, r4, #1 @ increment step-counter by 1 step

        mov     r0, #20
        bl      readPin @ read value of hall sensor

        cmp     r0, #0  @ check hall sensor state
        bne     findCenter @ if hall sensor has lost contact both edges have been found.
        b       findLeftEdge @ repeat the loop

    findCenter:
        ldr     r0, =center
        mov     r1, r4
        bl      printf

        mov     r0, #1
        mov     r1, r4, lsr #1
        bl      stepColorWheel @ move color wheel to the center by moving it half the counters steps counter-clockwise


    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr
