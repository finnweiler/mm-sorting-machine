@ sort.s
@ no parameters needed

    .data
    .balign     4

startSortMessage:
    .asciz      "started sort"

    .text

    .balign   4
    .global   sort
    .type     sort, %function

sort:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    ldr     r0, =startSortMessage
    bl      printf

    bl      setMotorPins
    bl      calibrateOutlet
    bl      calibrateColorWheel

    @ starts the feeder and sets the pins for the motors an co-processor
    bl      startFeeder

    @ infinite loop to turn the colorwheel and sort the m&ms with the color detection and outlet
    sortFor:
        mov     r4, #1
        cmp     r4, #2
        blt     sortLoop

    sortLoop:
        @ turns the color wheel 90 degrees clockwise
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel

        @ starts the color detection
        bl      colorDetection
        
        @ moves the outlet dependent on the detected color
        bl      moveOutletToNextColor
        b       sortFor

    @ stops the feeder and clears the pins for the motors and co-processor
    bl      clearMotorPins
    bl      stopFeeder

    @leaves the function sort
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
    bx      lr
