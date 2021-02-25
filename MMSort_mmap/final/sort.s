@ sort.s
@ no parameters needed

    .data
    .balign     4

startSortMessage:
    .asciz      "started sort"
colorDetected:
    .asciz    "Color detected: %d\n"

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
    @bl      calibrateOutlet
    @bl      calibrateColorWheel

    @ starts the feeder and sets the pins for the motors an co-processor
    bl      startFeeder

    @ does the sortLoop function 10 times
    sortLoop:
        @ turns the color wheel 90 degrees clockwise
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel

        @ starts the color detection
        bl      colorDetection
        
        @ moves the outlet dependent on the detected color
        bl      moveOutletToNextColor

        ldr     r5, address_of_mmCounterVariable
        ldr     r5, [r5]
        cmp     r5, #10
        beq     endSort
        blt     

    
    endSort:
        @ stops the feeder and clears the pins for the motors and co-processor
        bl      clearMotorPins
        bl      stopFeeder

        @ leaves the function sort
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
        bx      lr
