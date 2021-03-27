@ readPin.s
@ Reads a specified pin state from the GPIO pins and returns it.
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters: 
@       r0  <- the number of the pin which state should be read (e.g. 0 for pin 0, 4 for pin 4, etc.)
@ Returns:
@       r0  <- the state of the pin (r0 == 0 => pin is off, r0 != 0 => pin is on)
    
    
    .data
    .balign     4

stepMessage:
    .asciz      "stepping\n"
clockwise:
    .asciz      "end\n"

    .text

    .balign   4
    .global   readPin
    .type     readPin, %function

readPin:
    str     lr, [sp, #-8]!

    ldr     r1, [r10, #52]
    mov     r2, #1
    mov     r2, r2, lsl r0
    and     r0, r2, r1

    ldr     lr, [sp], #+8
    bx      lr


