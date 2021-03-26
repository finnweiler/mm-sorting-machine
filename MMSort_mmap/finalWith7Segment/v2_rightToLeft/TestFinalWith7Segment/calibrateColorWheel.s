@ calibrateOutlet.s
@ Parameters: 
@       r10 <- GPIO register

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
        mov     r0, #20 @ read pin 20
        bl      readPin @ load value of pin 20 in r0

        cmp     r0, #0 @ compare sensor value to 0
        beq     prepareRightEdge @ if hall sensor has contact, it can start searching for the right edge

        @ else:
        mov     r0, #0 @ move clockwise
        mov     r1, #1 @ move 1 step
        bl      stepColorWheel @ make color wheel move

        b       findContact @ repeat the loop

    prepareRightEdge:
        ldr     r0, =rightEdge
        bl      printf

    findRightEdge:
        mov     r0, #20 @ read pin 20
        bl      readPin @ load value of pin 20 in r0

        cmp     r0, #0  @ compare sensor value to 0
        bne     prepareLeftEdge @ if hall sensor lost contact, prepare to find left edge

        @ else:
        mov     r0, #1 @ move counter-clockwise
        mov     r1, #1 @ move 1 step
        bl      stepColorWheel @ make color wheel move

        b       findRightEdge @ repeat the loop

    prepareLeftEdge: @ move outlet a bit to the right to make sure the hall sensor is avtive again
        ldr     r0, =leftEdge
        bl      printf

        mov     r0, #0 @ move clockwise
        mov     r1, #5 @ move 5 steps
        bl      stepColorWheel @ make color wheel move

        add     r4, r4, #5 @ add 5 steps to the counter

    findLeftEdge:
        mov     r0, #0
        mov     r1, #1
        bl      stepColorWheel

        add     r4, r4, #1

        mov     r0, #20
        bl      readPin

        cmp     r0, #0
        bne     findCenter @ if hall sensor lost contact
        b       findLeftEdge

    findCenter:
        ldr     r0, =center
        mov     r1, r4
        bl      printf

        mov     r0, #1
        mov     r1, r4, lsr #1
        bl      stepColorWheel


    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr
