@ sortTest1.s
@ no parameters needed

    .data
    .balign     4

startSortMessage:
    .asciz      "started sort Test 1\n"

    .text
    .extern sleep

    .balign   4
    .global   sortTest1
    .type     sortTest1, %function

@ Test1: sort without the calibration and colorDetection
@ 3 colors are entered manually in the COLREG to test the moveOutletToNextColor function
sortTest1:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    ldr     r0, =startSortMessage
    bl      printf

    bl      setMotorPins

    @ starts the feeder and sets the pins for the motors an co-processor
    bl      startFeeder

    @ turns the color wheel 90 degrees clockwise
    mov     r0, #0
    mov     r1, #400
    bl      stepColorWheel

    @ go to color 1
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #1
    bl      moveOutletToNextColor

    @ go to color 4
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #4
    bl      moveOutletToNextColor

    @ go to color 2
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #2
    bl      moveOutletToNextColor

    @ go to color 6
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #6
    bl      moveOutletToNextColor

    @ go to color 1
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #1
    bl      moveOutletToNextColor

    @ go to color 1
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #1
    bl      moveOutletToNextColor

    @ go to color 5
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #5
    bl      moveOutletToNextColor

    @ go to color 3
    @ add short delay
    ldr     r0, =#2 @ sleep 2 s
    bl      sleep
    mov     r11, #3
    bl      moveOutletToNextColor



    endSort:
        @ stops the feeder and clears the pins for the motors and co-processor
        bl      clearMotorPins
        bl      stopFeeder

        @leaves the function sort
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
        bx      lr