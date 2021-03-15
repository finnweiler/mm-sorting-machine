@ David & Marvin, 12.03.21

.data

.text
.balign   4
.global   prepareSevenSegmentDisplayQueue
.type     prepareSevenSegmentDisplayQueue, %function

@ Function converts the four digits ( stored each as four bits in r1 (input) ) into four 8bit SevenSegmentDisplay Binary configurations
@ these 4 * 8bit binary SevenSegmentDisplay configurations are the output of the function and stored in r2 (32bit of information)
@ the first 8 bits (MSB) represent the thousand digit binary segment configuration,
@ the second 8 bits represent the hundred digit binary segment configuration, ..., 
@ the fourth 8 bits (LSB) represent the single digit binary segment configuration
@ input is r1 with four 4bit decimal digits indicating the thousand, hundred, decimal and single values
prepareSevenSegmentDisplayQueue:
    str lr, [sp, #-8]!
  
    mov r0, #0 @ represents the last digit of the mmCounter Variable. If counterVariable is 421, then at the beginning 1, then 2, then 4  
    mov r2, #0 @ contains the four 8bit 7segment binary configuration of the mmCounter Variable

    @ store in r0 the 4bits of the single digit in the mmCounter Variable
    @ f.i. if Counter is 245, in r0 is now stored a 5

    mov r3, #0 @ counter within range 0,1,2,3 to indicate each decimal place from single, decimal, hundreds, thousand
    decimalPlaceLoop:
        cmp r3, #4
        beq end_prepareSevenSegmentDisplayQueue
        add r3, r3, #+1
        and r0, r1, #0b1111
        asr r1, r1, #4
        
        cmp r0, #0
        beq if_DigitIsZero
        cmp r0, #1
        beq if_DigitIsOne
        cmp r0, #2
        beq if_DigitIsTwo
        cmp r0, #3
        beq if_DigitIsThree
        cmp r0, #4
        beq if_DigitIsFour
        cmp r0, #5
        beq if_DigitIsFive
        cmp r0, #6
        beq if_DigitIsSix
        cmp r0, #7
        beq if_DigitIsSeven
        cmp r0, #8
        beq if_DigitIsEight
        cmp r0, #9
        beq if_DigitIsNine

        if_DigitIsZero: 
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            @ and r2, r2, #16777215
            orr r2, r2, #0b00000000000000000000000000000000
            @orr r2, r2, #0
            b decimalPlaceLoop
            
        if_DigitIsOne:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b01100000000000000000000000000000
            b decimalPlaceLoop
            
        if_DigitIsTwo:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b11011010000000000000000000000000
            b decimalPlaceLoop

        if_DigitIsThree:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b11110010000000000000000000000000
            b decimalPlaceLoop

        if_DigitIsFour:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b01100110000000000000000000000000
            b decimalPlaceLoop

        if_DigitIsFive:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b10110110000000000000000000000000
            b decimalPlaceLoop

        if_DigitIsSix:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b10111110000000000000000000000000
            b decimalPlaceLoop
            
        if_DigitIsSeven:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b11100000000000000000000000000000
            b decimalPlaceLoop
            
        if_DigitIsEight:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b11111110000000000000000000000000
            b decimalPlaceLoop
            
        if_DigitIsNine:
            asr r2, r2, #8
            and r2, r2, #0b00000000111111111111111111111111
            orr r2, r2, #0b11110110000000000000000000000000
            b decimalPlaceLoop

    end_prepareSevenSegmentDisplayQueue:
        ldr     lr, [sp], #+8
        bx      lr