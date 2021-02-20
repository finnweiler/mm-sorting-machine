
.data 
currMsg:
    .asciz    "Current: %d\n"
movingMsgNg:
    .asciz    "Moving (ng): %d\n"
movingMsgGt:
    .asciz    "Moving (gt): %d\n"
movingMsgLt:
    .asciz    "Moving (lt): %d\n"

.balign   4
currentPosition:
    .word     0  

.text
.balign 4
.global colorToPosition
.type colorToPosition, %function
colorToPosition:
    str lr, [sp, #-8]! /* lr needs to be stored (pushed on stack), because a subfunction gets called within this function */

    cmp r11, #0 
    beq clear
    cmp r11, #1
    beq red
    cmp r11, #2      
    beq green
    cmp r11, #3      
    beq blue
    cmp r11, #4      
    beq brown
    cmp r11, #5      
    beq orange
    cmp r11, #6      
    beq yellow

    clear:
        mov r0, #0
        b endColorToPosition
    red:
        mov r0, #0
        b endColorToPosition
    green:
        ldr r0,=#67
        b endColorToPosition
    blue:
        ldr r0,=#133
        b endColorToPosition
    brown:
        ldr r0,=#200
        b endColorToPosition
    orange: 
        ldr r0,=#267
        b endColorToPosition
    yellow: 
        ldr r0,=#333
        b endColorToPosition

    endColorToPosition:
        ldr lr, [sp], #+8 @ pop initial lr from the stack and leave the whole colorIndizeToOutletPosition function
        bx lr



.balign 4
.global moveOutletToNextPosition
.type moveOutletToNextPosition, %function
moveOutletToNextPosition:
    str     lr, [sp, #-4]!  
    str     r4, [sp, #-4]!

    bl      colorToPosition 
    ldr     r2, addrOfCurrentPosition
    ldr     r1, [r2]
    str     r0, [r2]

    mov     r4, r0
    ldr     r0, =currMsg
    bl      printf
    mov     r0, r4

    sub     r4, r0, r1

    cmp     r4, #0
    beq     endMoveOutletToNextPosition

    cmp     r4, #200
    bgt     stepsGT
    cmp     r4, #-200
    ble     stepsLE
    cmp     r4, #0
    blt     stepsNeg
    b       moveRight

    stepsNeg: @ -200 to -1
        mov     r2, #-1
        mov     r3, r4
        mul     r4, r3, r2

        mov     r1, r4
        ldr     r0, =movingMsg
        bl      printf

        b       moveLeft

    stepsGT: @ >200
        ldr     r2, =#400
        sub     r4, r4, r2

        mov     r1, r4
        ldr     r0, =movingMsg
        bl      printf

        b       moveLeft

    stepsLE: @ <-200 
        ldr     r2, =#400
        add     r4, r4, r2

        mov     r1, r4
        ldr     r0, =movingMsg
        bl      printf

        b       moveRight


    moveLeft:
        mov     r0, #1
        mov     r1, r4
        bl      stepOutlet
        b       endMoveOutletToNextPosition

    moveRight:
        mov     r0, #0
        mov     r1, r4
        bl      stepOutlet

    endMoveOutletToNextPosition:
    
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr

addrOfCurrentPosition : .word currentPosition
