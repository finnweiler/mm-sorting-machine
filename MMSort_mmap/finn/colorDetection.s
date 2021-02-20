@ Jessy 14.2.2021
@ Color Detection Code

.text
.balign     4
.global colorDetection
.type colorDetection, %function

colorDetection:
    str     lr, [sp, #-8]!

    ldr     r0, [r10, #52]
    mov     r0, r0, lsr #22
    mov     r1, #0b111
    and     r11, r1, r0

    ldr     lr, [sp], #+8
    bx      lr
