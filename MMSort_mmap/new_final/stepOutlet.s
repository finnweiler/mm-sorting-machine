@ stepOutlet.s
@ Parameters: 
@       r0  <- direction to turn the outlet in (0=clockwise, 1=counter-clockwise)
@       r1  <- number of steps that shall be done
@       r10 <- GPIO register
    
    
    .data
    .balign     4

stepLeftMsg:
    .asciz      "outlet stepping %d left\n"
stepRightMsg:
    .asciz      "outlet stepping %d right\n"

    .text

    .extern usleep

    .balign   4
    .global   stepOutlet
    .type     stepOutlet, %function

stepOutlet:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    mov     r4, r1
    
    @ sets the direction of the outlet according to the direction stored in r0
    setOutletDirection:
        cmp     r0, #1
        beq     setDirectionCounterClockwise
        @ set Pin 26 to low level to turn the outlet clockwise
        setDirectionClockwise:
            ldr     r0, =stepRightMsg
            bl      printf 

            mov     r2, #1
            mov     r0, r2, lsl #26
            str     r0, [r10, #40]

            b       nextOutletStep
        @ set Pin 26 to high level to turn the outlet counter-clockwise
        setDirectionCounterClockwise:
            ldr     r0, =stepLeftMsg
            bl      printf

            mov     r2, #1
            mov     r0, r2, lsl #26
            str     r0, [r10, #28]
    
    @ lets the outlet do one step until the number of steps stored in r1 is reached
    nextOutletStep:
        cmp     r4, #0
        beq     endStepOutlet
        sub     r4, r4, #1

        @ set 'Step' Pin 12 to high and then to low level to do one step with the outlet
        @ set 'Step' Pin 12 to high level
        mov     r2, #1
        mov     r0, r2, lsl #12
        str     r0, [r10, #28]

        @ add short delay
        ldr     r0, =#10000 @ sleep 10 ms
        bl      usleep

        @ call tickUpdate to handle background tasks
        bl      tickUpdate

        @ set 'Step' Pin 12 to low level
        mov     r2, #1
        mov     r0, r2, lsl #12
        str     r0, [r10, #40]

        @ add short delay
        ldr     r0, =#10000 @ sleep 10 ms
        bl      usleep

        b       nextOutletStep
    
    @leaves the function stepOutlet
    endStepOutlet:
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr
