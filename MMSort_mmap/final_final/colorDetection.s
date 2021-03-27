@ colorDetection.s
@ this function loads the number related to the detected color in r11 (COLOR register)
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       none
@ Returns:
@       r11 -> COLOR register

.data 
colorDetected:
    .asciz    "Color detected: %d\n"

.text
.balign     4
.global colorDetection
.type colorDetection, %function

colorDetection:
    str     lr, [sp, #-8]!

    ldr     r0, [r10, #52]  @ load the on/off state of the GPIO registers into r0
    mov     r0, r0, lsr #22 @ shift r0 22 to the right to have the three color bits as the least significant bits of r0
    mov     r1, #0b111
    and     r11, r1, r0 @ now execute a bitwise and operation with 0b111 to only filter out the three GPIO color bits
                        @ the value if the detected color is now stored in the color register

    mov     r1, r11
    ldr     r0, =colorDetected
    bl      printf

    ldr     lr, [sp], #+8
    bx      lr
