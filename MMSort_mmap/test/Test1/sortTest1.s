@ sortTest1.s
@ no parameters needed

    .data
    .balign     4

startSortMessage:
    .asciz      "started sort Test1\n"

    .text

    .balign   4
    .global   sortTest1
    .type     sortTest1, %function

@ Test1: sort without the calibration and colorDetection
@ 3 colors are entered manually in the COLREG to test the moveOutletToNextPosition function
sortTest1:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    ldr     r0, =startSortMessage
    bl      printf

    bl      setMotorPins

    @ starts the feeder and sets the pins for the motors an co-processor
    bl      startFeeder

    mov     r4, #1
    @ loop that counts the colors from 1 to 6 and tests the function moveOutletToNextPosition
    sortLoop1:
        @ turns the color wheel 90 degrees clockwise
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel

        mov     r11, r4
        bl      moveOutletToNextPosition
        cmp     r4, #6
        beq     sortLoop2
        add     r4, r4, #1
        blt     sortLoop1
    
    mov     r4, #5
    @ loop that counts the colors from 5 to 1 and tests the function moveOutletToNextPosition
    sortLoop2:
        @ turns the color wheel 90 degrees clockwise
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel

        mov     r11, r4
        bl      moveOutletToNextPosition
        cmp     r4, #1
        beq     endSort
        sub     r4, r4, #1
        bgt     sortLoop2


    endSort:
        @ stops the feeder and clears the pins for the motors and co-processor
        bl      clearMotorPins
        bl      stopFeeder

        @leaves the function sort
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
        bx      lr