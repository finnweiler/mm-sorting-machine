@ calibrateColorWheel.s
@ Parameters: 
@       r10 <- GPIO register

    .data
    .balign     4

stepMessage:
    .asciz      "stepping\n"
clockwise:
    .asciz      "end\n"

    .text

    .extern usleep

    .balign   4
    .global   calibrateColorWheel
    .type     calibrateColorWheel, %function

calibrateColorWheel:
    str     lr, [sp, #-8]!  /* preindex: sp ← sp - 8; *sp ← lr */

    findLeftEdge:
        ldr     r0, [r10], #+52
        mov     r1, #12 @ select pin
        and     r0, r0, r1

        cmp     r0, #0
        beq     findHallEdge

        mov     r0, #0
        mov     r1, #1
        b       stepColorWheel

        b       findLeftEdge

    ldr     lr, [sp], #+8   /* postindex; lr ← *sp; sp ← sp + 8 */
    bx      lr