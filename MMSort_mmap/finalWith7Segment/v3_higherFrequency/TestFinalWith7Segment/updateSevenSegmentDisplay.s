@ updateSevenSegmentDisplay.s
@ Parameters: 
@       None
    
    
.data
.text
.balign   4
.global   updateSevenSegmentDisplay
.type     updateSevenSegmentDisplay, %function

updateSevenSegmentDisplay:
    str     lr, [sp, #-8]!  @store value of lr in the stack to be able to return later 
    
    mov r0, #0
    refreshLoop:
        cmp r0, #+10
        beq end_updateSevenSegmentDisplay
        bl getDecimalPlacesOfCounterVariable
        bl prepareSevenSegmentDisplayQueue
        bl refreshSevenSegmentDisplay
        add r0, r0, #+1
        b refreshLoop        
    
    end_updateSevenSegmentDisplay:
        ldr     lr, [sp], #+8  /* Pop the top of the stack and put it in lr */
        bx      lr
