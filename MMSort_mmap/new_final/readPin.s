@ readPin.s
@ if the returend value in r0 is equal to 0 the pin is off
@ if the returend value in r0 is unequal to 0 the pin is on
@ Parameters: 
@       r0  <- number of the pin
@       r10 <- GPIO register

    .text

    .balign   4
    .global   readPin
    .type     readPin, %function

readPin:
    str     lr, [sp, #-8]!

    ldr     r1, [r10, #52] @ load the high/low gpio information into register 1
    mov     r2, #1         @ move 0b000...001 to r2 to make it only have a 1 at GPIO-pin 0
    mov     r2, r2, lsl r0 @ shift register r2 to the left until you reach the bit of the GPIO-pin given in r0
    and     r0, r2, r1     @ now you can filter out the GPIO-pin output bit you are interested in. 

    ldr     lr, [sp], #+8
    bx      lr


