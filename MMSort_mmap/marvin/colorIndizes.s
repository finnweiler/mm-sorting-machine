@ function returns in r0 the absolute outlet position given an value in COLREG (r11) 
@ regarding this Rainbow Color Order {0: noColorDetected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown}
COLREG  .req    r11
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

    if_no_color_got_detected: mov r0, #-1
    if_destination_is_blue: mov r0, #0
    if_destination_is_green: mov r0, #67
    if_destination_is_yellow: mov r0, #133
    if_destination_is_orange: mov r0, #200
    if_destination_is_red: mov r0, #267
    if_destination_is_brown: mov r0, #333

    ldr lr, [sp], #+8 @ pop initial lr from the stack and leave the whole colorIndizeToOutletPosition function
    bx lr

.global main
main:
    str lr, [sp, #-8]!

    @ vairable currentPositionOfOutlet : currentColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown
    @ register COLREG : destinationColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown

    mov COLREG, #+4
    bl colorIndizeToOutletPosition

    ldr lr, [sp], #+8
    bx lr