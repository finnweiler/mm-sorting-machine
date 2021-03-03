@ stepOutlet.s
@ Parameters: 
@       r0  <- direction to turn the outlet in (0=clockwise, 1=counter-clockwise)
@       r1  <- number of steps that shall be done
@       r10 <- GPIO register
    
    
    .data
    .balign     4

stepMessage:
    .asciz      "outlet stepping\n"

endMessage:
    .asciz      "end\n"

    .text

    .extern usleep

    .balign   4
    .global   stepOutlet
    .type     stepOutlet, %function

stepOutlet:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r4, r1
    
    setOutletDirection:
        cmp     r0, #1
        beq     setDirectionCounterClockwise
        @ set Pin 26 to low level to turn the outlet clockwise
        setDirectionClockwise:
            mov     r2, #1
            mov     r0, r2, lsl #26
            str     r0, [r10, #40] 
            b       nextOutletStep
        @ set Pin 26 to high level to turn the outlet counter-clockwise
        setDirectionCounterClockwise:
            mov     r2, #1
            mov     r0, r2, lsl #26
            str     r0, [r10, #28]
    
    nextOutletStep:
        cmp     r4, #0
        beq     endStepOutlet
        sub     r4, r4, #1

        ldr     r0, =stepMessage
        bl      printf 

        @ set 'Step' Pin 12 to high and then to low level to do one step with the outlet
        @ set 'Step' Pin 12 to high level
        mov     r2, #1
        mov     r0, r2, lsl #12
        str     r0, [r10, #28]

        @ add short delay
        ldr     r0, =#50000 @ sleep 50 ms
        bl      usleep

        @ set 'Step' Pin 12 to low level
        mov     r2, #1
        mov     r0, r2, lsl #12
        str     r0, [r10, #40]

        @ add short delay
        ldr     r0, =#50000 @ sleep 50 ms
        bl      usleep

        b       nextOutletStep
    
    @leaves the function stepOutlet
    endStepOutlet:
        ldr     r0, =endMessage
        bl      printf 
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr
