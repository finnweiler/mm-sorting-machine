@ calibrateOutlet.s
@ Parameters: 
@       r10 <- GPIO register

    .data
    .balign     4

loop:
    .asciz      "loop\n"

    .text

    .balign   4
    .global   calibrateOutlet
    .type     calibrateOutlet, %function

calibrateOutlet:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r4, #0

    findContact:
        mov     r0, #21
        bl      readPin

        cmp     r0, #0
        beq     findRightEdge @ if hall sensor has contact # TODO: eq oder ne

        mov     r0, #0
        mov     r1, #1
        bl      stepOutlet

        b       findContact

    findRightEdge:
        mov     r0, #21
        bl      readPin

        cmp     r0, #0
        bne     findLeftEdge @ if hall sensor lost contact # TODO: eq oder ne

        mov     r0, #1
        mov     r1, #1
        bl      stepOutlet

        b       findRightEdge

    findLeftEdge:
        mov     r0, #0
        mov     r1, #1
        bl      stepOutlet

        add     r4, r4, #1

        mov     r0, #21
        bl      readPin

        cmp     r0, #0
        bne     findCenter @ if hall sensor lost contact # TODO: eq oder ne
        b       findLeftEdge

    findCenter:

        mov     r0, #1
        mov     r1, r4, lsr #1
        bl      stepOutlet


    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr
