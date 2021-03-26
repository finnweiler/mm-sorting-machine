@ waitForStartButton.s
    
    
    .data
    .balign     4

stepMessage:
    .asciz      "stepping\n"
clockwise:
    .asciz      "end\n"

    .text

    .balign   4
    .global   waitForStartButton
    .type     waitForStartButton, %function

@ this function runs as long the start button is not pressed
@ when the start button is pressed it finshes
waitForStartButton:
    str     lr, [sp, #-8]!

    @ a loop that is repeated until the start button is pressed
    checkButton:
        @ read the value of the start button (GPIO pin 8)
        mov     r0, #8
        bl      readPin

        cmp     r0, #0 @ check if the start button is off/on
        bne     checkButton @ if the start button is off, jump back to the top of the loop
                            @ else leave the function


    ldr     lr, [sp], #+8
    bx      lr


