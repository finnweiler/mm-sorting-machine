@ colorDetection.s
@ no parameters needed

.data 
colorDetected:
    .asciz    "Color detected: %d\n"

.text
.balign     4
.global colorDetection
.type colorDetection, %function

@ reads the color code of the pins 22, 23 and 24 and stores them in r11
colorDetection:
    str     lr, [sp, #-8]!

    ldr     r0, [r10, #52]
    mov     r0, r0, lsr #22
    mov     r1, #0b111
    and     r11, r1, r0

    mov     r1, r11
    ldr     r0, =colorDetected
    bl      printf

    ldr     lr, [sp], #+8
    bx      lr
