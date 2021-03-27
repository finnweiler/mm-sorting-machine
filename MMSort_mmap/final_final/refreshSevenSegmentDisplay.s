@ refreshSevenSegmentDisplay.s

@ This function refreshes each of the four digits according to the 7segment binary configuration information stored in r2 
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       r2 <- four 8bit 7segment binary configuration of the mmCounter Variable
@       whereas the first 8bits (MSB) represent thousand digit binary segment configuration
@       the second 8bits represent hundred digit binary segment configuration
@       the third 8bits represent decimal digit binary segment configuration
@       the fourth 8bits (LSB) represent single digit binary segment configuration
@ Returns:
@       none


.data

.text
.extern usleep
.balign   4
.global   refreshSevenSegmentDisplay
.type     refreshSevenSegmentDisplay, %function
refreshSevenSegmentDisplay:
    str lr, [sp, #-8]!
  
    
    mov r3, #0 @ counter within range 0,1,2,3 to indicate each decimal place from single, decimal, hundreds, thousand
    decimalPlacePrintLoop:
        emptySchieberegister:
            @ set nSRCLR high
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #28]
            @ set RCLK low
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #5 
            str     r0, [r10, #40]
            @ set SRCLK low
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #40]
            @ set nSRCLR low
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #40]
            @ set SRCLK high
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #28]
            @ set SRCLK low
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #40]    
            @ set nSRCLR high
            bl      customSleep
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #28]

        cmp r3, #4
        beq end_refreshSevenSegmentDisplay
        
        refreshCurrentDigit:
            mov r1, #0 @ counter within range 0,1,2,3,4,5,6,7 to indicate each setting of a different bit (8bits) of a different FlipFlop into the Schieberegister 
            fillingTheSchieberegisterLoop:

                cmp r1, #+8
                beq end_fillingTheSchieberegisterLoop
                add r1, r1, #+1
                @ set GPIO Pin 3 (SRCLK) low 
                bl      customSleep
                mov     r0, #1
                lsl     r0, r0, #3 
                str     r0, [r10, #40]

                mov     r0, #0
                and r0, r2, #0b00000000000000000000000000000001
                asr r2, r2, #1

                cmp r0, #0
                beq if_bitIsZero
                cmp r0, #1
                beq if_bitIsOne

                if_bitIsZero:
                    @ set GPIO Pin 2 (SER) low
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #2 
                    str     r0, [r10, #40]
                    b setClockToSetNextFlipflopInSchieberegister

                if_bitIsOne:
                    @ set GPIO Pin 2 (SER) high 
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #2 
                    str     r0, [r10, #28]
                    b setClockToSetNextFlipflopInSchieberegister

                setClockToSetNextFlipflopInSchieberegister:                    
                    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
                    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #3 
                    str     r0, [r10, #28]
        
                    @ set GPIO Pin 3 (SRCLK) low 
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #3 
                    str     r0, [r10, #40]            
                    b fillingTheSchieberegisterLoop

            end_fillingTheSchieberegisterLoop:
                setMultiplexer:
                    cmp r3, #0
                    beq if_thousandDigitShouldBeRefreshed
                    cmp r3, #1
                    beq if_hundredsDigitShouldBeRefreshed
                    cmp r3, #2
                    beq if_decimalDigitShouldBeRefreshed
                    cmp r3, #3
                    beq if_singleDigitShouldBeRefreshed

                    @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select one of the four Schieberegisters to refresh either the single, decimal, hundred or thousand SevenSegment Digit 
                    if_singleDigitShouldBeRefreshed:
                        @ set GPIO Pin 6 low
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #6 
                        str     r0, [r10, #40]
                        @ set GPIO Pin 7 low
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #7 
                        str     r0, [r10, #40]
                        b shiftSchieberegisterIntoOutputRegister
                    
                    if_decimalDigitShouldBeRefreshed:
                        @ set GPIO Pin 6 high
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #6 
                        str     r0, [r10, #28]
                        @ set GPIO Pin 7 low
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #7 
                        str     r0, [r10, #40]
                        b shiftSchieberegisterIntoOutputRegister

                    if_hundredsDigitShouldBeRefreshed:
                        @ set GPIO Pin 6 low
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #6 
                        str     r0, [r10, #40]
                        @ set GPIO Pin 7 high
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #7 
                        str     r0, [r10, #28]
                        b shiftSchieberegisterIntoOutputRegister
                    
                    if_thousandDigitShouldBeRefreshed:
                        @ set GPIO Pin 6 high
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #6 
                        str     r0, [r10, #28]
                        @ set GPIO Pin 7 high
                        bl      customSleep
                        mov     r0, #1
                        lsl     r0, r0, #7 
                        str     r0, [r10, #28]
                        b shiftSchieberegisterIntoOutputRegister

                shiftSchieberegisterIntoOutputRegister:    
                    @ set RCLK low
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #40]
                    @ set RCLK high
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #28]
                    @ set RCLK low
                    bl      customSleep
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #40]
                
                nextDecimalPlaceIteration:
                    add r3, r3, #+1
                    b decimalPlacePrintLoop
    
    end_refreshSevenSegmentDisplay:
        ldr lr, [sp], #+8
        bx      lr

@ HelperFunction
@ customSleep
@ This function pushes r0-r3 on the stack, sleeps for 3 mikro seconds and pops r0-r3 from the stack
@ Parameters:
@       none 
@ Returns:
@       none
customSleep:
    str lr, [sp, #-4]!
    
    str r0, [sp, #-4]!
    str r1, [sp, #-4]!
    str r2, [sp, #-4]!
    str r3, [sp, #-8]!
    
    ldr     r0, =#3 @ sleeps 3 mikro seconds
    bl      usleep

    ldr r3, [sp], #+8
    ldr r2, [sp], #+4
    ldr r1, [sp], #+4
    ldr r0, [sp], #+4

    end_customSleep:
        ldr lr, [sp], #+4
        bx      lr
