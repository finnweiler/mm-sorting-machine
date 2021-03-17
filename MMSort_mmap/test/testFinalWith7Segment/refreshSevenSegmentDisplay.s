@ David & Marvin, 12.03.21

.data

.text
.extern customSleep
.balign   4
.global   refreshSevenSegmentDisplay
.type     refreshSevenSegmentDisplay, %function

@ Function refreshes each of the four digits according to the 7segment binary configuration information stored in r2 
@ input: r2 contains the four 8bit 7segment binary configuration of the mmCounter Variable
@ whereas the first 8bits (MSB) represent thousand digit binary segment configuration
@ the second 8bits represent hundred digit binary segment configuration
@ the third 8bits represent decimal digit binary segment configuration
@ the fourth 8bits (LSB) represent single digit binary segment configuration
refreshSevenSegmentDisplay:
    str lr, [sp, #-8]!
  
    
    mov r3, #0 @ counter within range 0,1,2,3 to indicate each decimal place from single, decimal, hundreds, thousand
    decimalPlacePrintLoop:
        emptySchiebegreister:
            @ set nSRCLR high
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #28]
            bl      customSleep
            @ set RCLK low
            mov     r0, #1
            lsl     r0, r0, #5 
            str     r0, [r10, #40]
            bl      customSleep
            @ set SRCLK low
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #40]
            bl      customSleep
            @ set nSRCLR low
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #40]
            bl      customSleep
            @ set SRCLK high
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #28]
            bl      customSleep
            @ set SRCLK low
            mov     r0, #1
            lsl     r0, r0, #3 
            str     r0, [r10, #40]
            bl      customSleep
            @ set nSRCLR high
            mov     r0, #1
            lsl     r0, r0, #4 
            str     r0, [r10, #28]

        @ end Delay
        cmp r3, #4
        beq end_refreshSevenSegmentDisplay
        cmp r3, #0
        beq if_singleDigitShouldBeRefreshed
        cmp r3, #1
        beq if_decimalDigitShouldBeRefreshed
        cmp r3, #2
        beq if_hundredsDigitShouldBeRefreshed
        cmp r3, #3
        beq if_thousandDigitShouldBeRefreshed

        @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select one of the four Schieberegisters to refresh either the single, decimal, hundred or thousand SevenSegment Digit 
        if_singleDigitShouldBeRefreshed:
            @ set GPIO Pin 6 low
            mov     r0, #1
            lsl     r0, r0, #6 
            str     r0, [r10, #40]
            bl      customSleep
            @ set GPIO Pin 7 low
            mov     r0, #1
            lsl     r0, r0, #7 
            str     r0, [r10, #40]
            b refreshCurrentDigit
        
        if_decimalDigitShouldBeRefreshed:
            @ set GPIO Pin 6 high
            mov     r0, #1
            lsl     r0, r0, #6 
            str     r0, [r10, #28]
            bl      customSleep
            @ set GPIO Pin 7 low
            mov     r0, #1
            lsl     r0, r0, #7 
            str     r0, [r10, #40]
            b refreshCurrentDigit

        if_hundredsDigitShouldBeRefreshed:
            @ set GPIO Pin 6 low
            mov     r0, #1
            lsl     r0, r0, #6 
            str     r0, [r10, #40]
            bl      customSleep
            @ set GPIO Pin 7 high
            mov     r0, #1
            lsl     r0, r0, #7 
            str     r0, [r10, #28]
            b refreshCurrentDigit
        
        if_thousandDigitShouldBeRefreshed:
            @ set GPIO Pin 6 high
            mov     r0, #1
            lsl     r0, r0, #6 
            str     r0, [r10, #28]
            bl      customSleep
            @ set GPIO Pin 7 high
            mov     r0, #1
            lsl     r0, r0, #7 
            str     r0, [r10, #28]
            b refreshCurrentDigit
        
        refreshCurrentDigit:
            shiftEmptySchieberegisterIntoOutputRegister:
                @ set RCLK low
                mov     r0, #1
                lsl     r0, r0, #5 
                str     r0, [r10, #40]
                bl      customSleep
                @ set RCLK high
                mov     r0, #1
                lsl     r0, r0, #5 
                str     r0, [r10, #28]

                bl      customSleep
                @ set RCLK low
                mov     r0, #1
                lsl     r0, r0, #5 
                str     r0, [r10, #40]

            mov r1, #0 @ counter within range 0,1,2,3,4,5,6,7 to indicate each setting of a different bit (8bits) of a different FlipFlop into the Schieberegister 
            fillingTheSchieberegisterLoop:

                bl      customSleep

                cmp r1, #+8
                beq end_fillingTheSchieberegisterLoop
                add r1, r1, #+1
                @ set GPIO Pin 3 (SRCLK) low 
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
                    bl      customSleep
                    @ set GPIO Pin 2 (SER) low 
                    mov     r0, #1
                    lsl     r0, r0, #2 
                    str     r0, [r10, #40]
                    b setClockToSetNextFlipflopInSchieberegister

                if_bitIsOne:
                    bl      customSleep
                    @ set GPIO Pin 2 (SER) high 
                    mov     r0, #1
                    lsl     r0, r0, #2 
                    str     r0, [r10, #28]
                    b setClockToSetNextFlipflopInSchieberegister

                setClockToSetNextFlipflopInSchieberegister:
                    bl      customSleep
                    
                    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
                    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
                    mov     r0, #1
                    lsl     r0, r0, #3 
                    str     r0, [r10, #28]
            
                    bl      customSleep
                    @ set GPIO Pin 3 (SRCLK) low 
                    mov     r0, #1
                    lsl     r0, r0, #3 
                    str     r0, [r10, #40]            

                    b fillingTheSchieberegisterLoop

            end_fillingTheSchieberegisterLoop:
                shiftSchieberegisterIntoOutputRegister:
                    @ set RCLK low
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #40]
                    bl      customSleep
                    @ set RCLK high
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #28]
                    bl      customSleep
                    @ set RCLK low
                    mov     r0, #1
                    lsl     r0, r0, #5 
                    str     r0, [r10, #40]
                add r3, r3, #+1
                b decimalPlacePrintLoop
    
    end_refreshSevenSegmentDisplay:
        ldr lr, [sp], #+8
        bx      lr


customSleep:
    str lr, [sp, #-8]!
    
    @ ldr r0, =#10
    @ ldr r0, =#20
    @ ldr r0, =#50

    @ ldr r0, =#100
    @ ldr r0, =#200
    @ ldr r0, =#500

    @ ldr r0, =#1000
    @ ldr r0, =#2000
    @ ldr r0, =#5000

    @ ldr r0, =#10000
    @ ldr r0, =#20000
    @ ldr r0, =#50000

    @ ldr r0, =#100000
    @ ldr r0, =#200000
    @ ldr r0, =#500000

    ldr r0, =#1000000
    @ ldr r0, =#2000000
    @ ldr r0, =#5000000

    @ ldr r0, =#10000000
    @ ldr r0, =#20000000
    @ ldr r0, =#50000000

    @ ldr r0, =#100000000
    @ ldr r0, =#200000000
    @ ldr r0, =#500000000

    @ ldr r0, =#1000000000
    @ ldr r0, =#2000000000
    @ ldr r0, =#5000000000

    @ ldr r0, =#10000000000
    @ ldr r0, =#20000000000
    @ ldr r0, =#50000000000
    


    sleepLoop:
        cmp r0, #0
        beq end_customSleep
        sub r0, r0, #1
        b sleepLoop
    
    end_customSleep:
        ldr lr, [sp], #+8
        bx      lr

