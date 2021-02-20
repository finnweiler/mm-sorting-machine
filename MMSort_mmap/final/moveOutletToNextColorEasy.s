@ Marvin, 13.02.21, 19.02.21

@ function returns in r0 the absolute outlet position given an value in COLREG (r11) 
@ regarding this Rainbow Color Order {0: noColorDetected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown}
.text
.balign 4
.global colorIndizeToOutletPosition
.type colorIndizeToOutletPosition, %function
colorIndizeToOutletPosition:
    str lr, [sp, #-8]! /* lr needs to be stored (pushed on stack), because a subfunction gets called within this function */

    cmp r11, #0 
    beq if_no_color_got_detected
    cmp r11, #1
    beq if_destination_is_blue
    cmp r11, #2      
    beq if_destination_is_green
    cmp r11, #3      
    beq if_destination_is_yellow
    cmp r11, #4      
    beq if_destination_is_orange
    cmp r11, #5      
    beq if_destination_is_red
    cmp r11, #6      
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
        ldr r0,=#133
        b end_colorIndizeToOutletPosition
    if_destination_is_orange:
        ldr r0,=#200
        b end_colorIndizeToOutletPosition
    if_destination_is_red: 
        ldr r0,=#267
        b end_colorIndizeToOutletPosition
    if_destination_is_brown: 
        ldr r0,=#333
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
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    bl      colorIndizeToOutletPosition /* after the return of function: in r0 is the absolute destination position stored */ 
    mov     r4, r0 /* storing the absolute destination position also in r3 to use it later again, to store in the current position variable the destinationPosition  */

    mov     r0, #0
    mov     r1, r4
    bl      stepOutlet
    
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr

.balign 4
.global moveOutletBackFromColor
.type moveOutletBackFromColor, %function
moveOutletBackFromColor:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!

    bl      colorIndizeToOutletPosition /* after the return of function: in r0 is the absolute destination position stored */ 
    mov     r4, r0 /* storing the absolute destination position also in r3 to use it later again, to store in the current position variable the destinationPosition  */

    mov     r0, #1
    mov     r1, r4
    bl      stepOutlet
    
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr

