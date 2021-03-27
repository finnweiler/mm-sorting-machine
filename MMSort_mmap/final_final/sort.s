@ sort.s
@ calls important funcitons to initiate the machine and the leds and starts the calibration
@ regulates the sorting process, the counter, the buttons and the leds by calling the necessary functions in a loop
@ deinitiates the machine and the leds, when the sorting process is over
@ Parameters:
@       none
@ Global Parameters:
@       r10 <- GPIO register
@ Returns:
@       none

    .data
    .balign     4

startSortMessage:
    .asciz      "Start sorting"

    .text
    .balign   4
    .global   sort
    .type     sort, %function

sort:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    ldr     r0, =startSortMessage
    bl      printf

    @ set wait register to 0
    mov     r8, #0

    @ necessary pins are set, the calibration of the motors is done and the leds are initiated
    bl      setMotorPins
    bl      calibrateOutlet
    bl      calibrateColorWheel
    bl      initLed

    @ wait till start button is pressesd
    bl      waitForStartButton

    @ starts the feeder
    bl      startFeeder

    @ sortLoop is run until no M&Ms were recognized 10 times
    sortLoop:

        @ Check if stop button was pressed causing the sort to stop early
        ldr     r5, =endButtonPressed
        ldr     r5, [r5]
        cmp     r5, #1
        beq     endSort

        @ stops if Object was missing ten times in a row
        ldr     r5, =missingObjectVariable
        ldr     r5, [r5]
        cmp     r5, #10
        beq     endSort

        @ turns the color wheel 90 degrees clockwise
        mov     r0, #0
        mov     r1, #400
        bl      stepColorWheel

        @ starts the color detection
        bl      colorDetection

        @ changes led color according to detected color
        bl      changeColorLed
        
        @ moves the outlet according to detected color
        bl      moveOutletToNextColor

        @ Counter is increased by one if a color was detected successfully and the object sensor didn't recognize a M&M
        bl      checkCounter
        bl      printMMCounterIntoConsole

        b       sortLoop

    endSort:
        @ stops the feeder, clears the pins for the motors and co-processor and deinitiates the leds
        bl      clearMotorPins
        bl      deinitLed
        bl      stopFeeder

        @ leaves the function sort
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4   @Pop the top of the stack and put it in lr
        bx      lr
