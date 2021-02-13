@ Marvin, 13.02.21


@ QUESTION1: Wie viele Steps brauche ich um von einer Farbe zu einer benachbarten Farbe zu kommen? 
@ Gegebene Infos: Es gibt einmal die Angabe 400 steps/cycle und einmal 200 steps/cycle. Dann natürlich 6 colors, 360°/6=60° 
@ -> Vermutung 400/6 = ca. 67 steps
@ Stimmt das?

@ Question2: Ist das COLREG die Fabe, wo ich quasi hin will, oder da wo ich gerade schon bin? Quasi Destination oder CurrentPosition? 
@ Meine Inputs sind ja nur die aktuelle Farbe und die kommende Farbe. Welche Register soll ich dafür verwenden? R12 und R13?

@ Question3: Wollen diese Farbreihenfolge verwenden? Hat ein Regenbogenmuster ;)
@ Rainbow Color Order
@ 0 : blue
@ 1 : green
@ 2 : yellow 
@ 3 : orange
@ 4 : red
@ 5 : brown

.data
.text
@ function computes the direction and number of steps to get from the current color position to the destination color position
@ function then calls the steps_motor_outlet function with the computed parameters direction and number of steps
@ function input: r12 - currentPosition, r13 - destinationPosition. Both have an integer value inclusivly in between 0 and 5, as there are six colors
@ function returns nothing
moveOutletToNextColor:
    str lr, [sp, #-8]! /* lr needs to be stored (pushed on stack), because a subfunction gets called within this function */

    @ stores in r0 the difference between the destinationPosition and the currentPosition
    sub r0, r13, r12
    
    @ if : checks whether destination and current postion are the same
    cmp r0, #0
    beq if_again_same_color
    @ elif: checks whether computed difference suggests a unnecessary long counterclockwise move instead of a shorter clockwise move
    cmp r0, #-3
    bmi elif_negative_detour  
    @ elif: checks whether computed difference suggests a unnecessary long clockwise move instead of a shorter counterclockwise move
    cmp r0, #+3
    bpl elif_positive_detour  
    @ else: 
    b else

    if_again_same_color: bx lr               /* return from the whole moveOutletToNextColor function */
    elif_negative_detour: add r1, r0, #+6    /* store in r1 the improved difference (short clockwise move, not unnecessary long counterclockwise move) */
    elif_positive_detour: sub r1, r0, #+6    /* store in r1 the improved difference (short counterclockwise move, not unnecessary long clockwise move) */
    else: ldr r1, r0                         /* store in r1 the difference even if it was prior already the shortest move to the destination */
    
    @ current information in register r1
    @ sign: charackterizes wethere clockwise or counterclockwise direction
    @ absolute value: represents an x * 60° rotation (Why 60°? Because (360° / six colors) = 60°) @@@@@@@@@@@@@@@@@@@ 360/6 OR 400/6 OR 200/6 @@@@@@@@@@@@@@@@@@@@@@

    @ if : check for clockwise move 
    cmp r1, #0
    bpl if_moving_clockwise
    @ else : counterclockwise move 
    b else_moving_counterclockwise 

    if_moving_clockwise:
        mov r2, #0
        ldr r4, r1
        mul r4, r4, #67                @@@@@@@@@@@@@@@@@ IS 67 = 400/6 the right choice ??? @@@@@@@@@@@@@@@@@@@@@ 400/6 OR 200/6
        bl steps_motor_outlet

    else_moving_counterclockwise
        mov r2, #1
        sub r4, #0, r1
        mul r4, r4, #67                @@@@@@@@@@@@@@@@@ IS 67 = 400/6 the right choice ??? @@@@@@@@@@@@@@@@@@@@@ 400/6 OR 200/6 
        bl steps_motor_outlet 

    @ the outlet was successfully moved from its oldposition to its new position, threfore: currentPosition = destinationPosition
    ldr r12, r13

    @ pop initial lr from the stack and leave the whole moveOutletToNextColor function
    ldr lr, [sp], #+8
    bx lr

.global main
main:
    str lr, [sp, #-8]!

    @ r12 : currentPosition 
    @ r13 : destinationPosition 
    mov r12, #2 /* yellow */
    mov r13, #5 /* brown */

    bl moveOutletToNextColor


    ldr lr, [sp], #+8
    bx lr
