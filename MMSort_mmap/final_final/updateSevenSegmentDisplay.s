@ updateSevenSegmentDisplay.s
@ This function calls the three relevant 7Segemnt Functions to refresh the 7Segement Display
@ Parameters:
@       none
@ Returns:
@       none
    
.data
.text
.balign   4
.global   updateSevenSegmentDisplay
.type     updateSevenSegmentDisplay, %function

updateSevenSegmentDisplay:
    str     lr, [sp, #-8]!  @store value of lr in the stack to be able to return later 
        
    bl getDecimalPlacesOfCounterVariable
    bl prepareSevenSegmentDisplayQueue
    bl refreshSevenSegmentDisplay
    
    end_updateSevenSegmentDisplay:
        ldr     lr, [sp], #+8  /* Pop the top of the stack and put it in lr */
        bx      lr
