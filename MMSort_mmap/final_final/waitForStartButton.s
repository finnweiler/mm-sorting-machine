@ waitForStartButton.s
@ This function runs until the start button is pressed.
@ Parameters: 
@       none
@ Returns:
@       none

    .text

    .balign   4
    .global   waitForStartButton
    .type     waitForStartButton, %function

waitForStartButton:
    str     lr, [sp, #-8]!

    checkButton:
        mov     r0, #8 @ read pin 8 / button 1
        bl      readPin @ load value of button 2 in r0

        cmp     r0, #0 @ compare sensor value to 0
        bne     checkButton


    ldr     lr, [sp], #+8
    bx      lr


