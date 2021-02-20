@ Marvin, 13.02.21, 19.02.21

COLREG  .req    r11

.data
.balign 4
currentPositionOfOutlet: .word 0 /* stores the absolute position of outlet. value range 0,1,2,...,399 is aquivalent to amount of outlet steps per cycle */
.balign 4
stepMessage:
    .asciz "outlet stepping\n"
.balign 4
endMessage:
    .asciz "end\n"


@ function returns in r0 the absolute outlet position given an value in COLREG (r11) 
@ regarding this Rainbow Color Order {0: noColorDetected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown}
.text
.balign 4
.global colorIndizeToOutletPosition
.type colorIndizeToOutletPosition, %function
colorIndizeToOutletPosition:
    str lr, [sp, #-8]! /* lr needs to be stored (pushed on stack), because a subfunction gets called within this function */

    cmp COLREG, #0 
    beq if_no_color_got_detected
    cmp COLREG, #1
    beq if_destination_is_blue
    cmp COLREG, #2      
    beq if_destination_is_green
    cmp COLREG, #3      
    beq if_destination_is_yellow
    cmp COLREG, #4      
    beq if_destination_is_orange
    cmp COLREG, #5      
    beq if_destination_is_red
    cmp COLREG, #6      
    beq if_destination_is_brown

    if_no_color_got_detected:
        mov r0, #-1 
        b end_colorIndizeToOutletPosition
    if_destination_is_blue:
        mov r0, #0
        b end_colorIndizeToOutletPosition
    if_destination_is_green:
        mov r0, #67
        b end_colorIndizeToOutletPosition
    if_destination_is_yellow:
        mov r0, #133
        b end_colorIndizeToOutletPosition
    if_destination_is_orange:
        mov r0, #200
        b end_colorIndizeToOutletPosition
    if_destination_is_red: 
        mov r0, #267
        b end_colorIndizeToOutletPosition
    if_destination_is_brown: 
        mov r0, #333
        b end_colorIndizeToOutletPosition

    end_colorIndizeToOutletPosition:
        ldr lr, [sp], #+8 @ pop initial lr from the stack and leave the whole colorIndizeToOutletPosition function
        bx lr


@ function computes the direction and number of steps to get from the current color position to the destination color position
@ function then calls the steps_motor_outlet function with the computed parameters direction and number of steps
@ function input: r12 - currentPosition, r13 - destinationPosition. Both have an integer value inclusivly in between 0 and 5, as there are six colors
@ function returns nothing
.balign 4
.global moveOutletToNextColor
.type moveOutletToNextColor, %function
moveOutletToNextColor:
    str lr, [sp, #-8]! /* lr needs to be stored (pushed on stack), because a subfunction gets called within this function */

    ldr r1, address_of_currentPositionOfOutlet
    ldr r1, [r1] /* load in r1 the absolute current position */

    bl colorIndizeToOutletPosition /* after the return of function: in r0 is the absolute destination position stored */ 
    mov r3, r0 /* storing the absolute destination position also in r3 to use it later again, to store in the current position variable the destinationPosition  */

    cmp r0, #-1 /* if no color got detected (colorIndizeToOutletPosition function returns -1), then don't move the outlet */
    beq end_moveOutletToNextColor

    @ stores in r0 the difference between the destinationPosition (r0) and the currentPosition (r1)
    
    sub r0, r0, r1
    
    @ if : checks whether destination and current postion are the same
    cmp r0, #0
    beq if_again_same_color
    @ elif: checks whether computed difference suggests a unnecessary long counterclockwise move instead of a shorter clockwise move
    cmp r0, #-200
    bmi elif_negative_detour  
    @ elif: checks whether computed difference suggests a unnecessary long clockwise move instead of a shorter counterclockwise move
    cmp r0, #+200
    bpl elif_positive_detour  
    @ else: 
    b else

    if_again_same_color: 
        b end_moveOutletToNextColor   /* return from the whole moveOutletToNextColor function */
    elif_negative_detour: 
        add r1, r0, #+400        /* store in r1 the improved difference (short clockwise move, not unnecessary long counterclockwise move) */
        b checkForClockwiseMove  
    elif_positive_detour: 
        sub r1, r0, #+400        /* store in r1 the improved difference (short counterclockwise move, not unnecessary long clockwise move) */
        b checkForClockwiseMove  
    else: 
        mov r1, r0             /* store in r1 the difference even if it was prior already the shortest move to the destination */
        b checkForClockwiseMove

    @ current information in register r1
    @ sign: charackterizes wethere clockwise or counterclockwise direction
    @ absolute value: represents the amount of outlet steps it takes to get from the current color to the destination color

    @ if : check for clockwise move 
    checkForClockwiseMove:
        cmp r1, #0
        bpl if_moving_clockwise
        @ else : counterclockwise move 
        b else_moving_counterclockwise 

        if_moving_clockwise:
            mov r0, #0                
            bl stepOutlet

        else_moving_counterclockwise:
            mov r0, #1
            mov r2, #0
            sub r1, r2, r1                 
            bl stepOutlet 

        @ the outlet was successfully moved from its oldposition to its new position, threfore: currentPosition = destinationPosition
        ldr r0, address_of_currentPositionOfOutlet
        str r3, [r0]
        b end_moveOutletToNextColor 

    end_moveOutletToNextColor:
        @ pop initial lr from the stack and leave the whole moveOutletToNextColor function
        ldr lr, [sp], #+8
        bx lr


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



.global main
main:
    str lr, [sp, #-8]!

    @ vairable currentPositionOfOutlet : currentColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown
    @ register COLREG : destinationColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown

    mov COLREG, #+4
    bl moveOutletToNextColor

    ldr lr, [sp], #+8
    bx lr
address_of_currentPositionOfOutlet: .word currentPositionOfOutlet
