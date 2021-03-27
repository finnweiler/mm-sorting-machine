@ colorDetection.s
@ this function loads the number related to the detected color in r11 (COLOR register)
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       r11 <- COLOR register
@ Returns:
@       r11 -> (COLOR register)

.data 
colorDetected:
    .asciz    "Color detected: %d\n"

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
    @ writes input of GPIO 22, 23, 24 into r11

    mov     r1, r11
    ldr     r0, =colorDetected
    bl      printf

    ldr     lr, [sp], #+8
    bx      lr
