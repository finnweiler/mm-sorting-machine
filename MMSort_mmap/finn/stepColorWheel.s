@ stepColorWheel.s
@ Parameters: 
@       r0  <- direction to turn the color wheel in (0=clockwise, 1=counter-clockwise)
@       r1  <- number of steps that shall be done
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
    .global   stepColorWheel
    .type     stepColorWheel, %function

stepColorWheel:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r4, r1
    
    setColorWheelDirection:
        cmp     r0, #1
        beq     setDirectionCounterClockwise
        @ set Pin 16 to low level to turn the color wheel clockwise
        setDirectionClockwise:
            mov     r2, #1
            mov     r0, r2, lsl #16
            str     r0, [r10, #40] 
            b       nextColorWheelStep
        @ set Pin 16 to high level to turn the color wheel counter-clockwise
        setDirectionCounterClockwise:
            mov     r2, #1
            mov     r0, r2, lsl #16
            str     r0, [r10, #28]
    
    nextColorWheelStep:
        cmp     r4, #0
        beq     endStepColorWheel
        sub     r4, r4, #1

        ldr     r0, =stepMessage
        bl      printf 

        @ set 'Step' Pin 13 to high and then to low level to do one step with the color wheel
        @ set 'Step' Pin 13 to high level
        mov     r2, #1
        mov     r0, r2, lsl #13
        str     r0, [r10, #28]

        @ add short delay
        ldr     r0, =#50000 @ sleep 50 ms
        bl      usleep

        @ set 'Step' Pin 13 to low level
        mov     r2, #1
        mov     r0, r2, lsl #13
        str     r0, [r10, #40]

        @ add short delay
        ldr     r0, =#50000 @ sleep 50 ms
        bl      usleep

        b       nextColorWheelStep
    
    @leaves the function stepColorWheel
    endStepColorWheel:
        ldr     r0, =clockwise
        bl      printf 
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr
