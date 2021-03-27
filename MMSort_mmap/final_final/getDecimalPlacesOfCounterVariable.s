@ getDecimalPlacesOfCounterVariable.s
@ This Function converts the value of the mmCounter variable into four separate 4bit digits
@ that each store either the thousand, hundred, decimal or single digit value in r1
@ Parameters: 
@       r0 <- mmCounterVariable 
@                contains the number of m&ms which are already sorted

@ Returns:
@       r1 -> contains the four decimal digit values for the four 7 segment digits on the display
@                therefore it stores 16 bits (for each digit it stores 4 bits, as 4 bits are needed to cover the number space from 0-9 )
@                if r1 is for instance 
@                0000 | 0000 | 0000 |  0000 |  t   t   t   t  |  h   h   h   h  |  d   d   d   d |  s   s   s   s
@                ( n o t        n e e d e d )  thousand digit    hundred digit     decimal digit    single digit

.data

.text
.balign   4
.global   getDecimalPlacesOfCounterVariable
.type     getDecimalPlacesOfCounterVariable, %function


getDecimalPlacesOfCounterVariable:
    str lr, [sp, #-8]!

    @ r1 contains the four decimal digit values for the four 7 segment digits on the display
    @ therefore it stores 16 bits (for each digit it stores 4 bits, as 4 bits are needed to cover the number space from 0-9 )
    @ if r1 is for instance 
    @ 0000 | 0000 | 0000 |  0000 |  t   t   t   t  |  h   h   h   h  |  d   d   d   d |  s   s   s   s
    @ ( n o t        n e e d e d )  thousand digit    hundred digit     decimal digit    single digit
    mov r1, #0
    
    ldr r0, =mmCounterVariable
    ldr r0, [r0]

    @ r2 counts the amount of subtractions of 1000 needed to eliminate the thousand digit
    mov r2, #0
    thousandLoop:
        sub r0, r0, #+1000
        add r2, r2, #+1
        cmp r0, #0
        bpl thousandLoop
    sub r2, r2, #+1
    add r0, r0, #+1000
    lsl r2, r2, #12
    @ r1: 0000 | 0000 | 0000 |  0000 |  0   0   0   0  |  0   0   0   0  |  0   0   0   0 |  0   0   0   0
    @ r2: 0000 | 0000 | 0000 |  0000 |  a   b   c   d  |  0   0   0   0  |  0   0   0   0 |  0   0   0   0
    mov r1, r2
    
        

    @ r2 counts the amount of subtractions of 100 needed to eliminate the hundred digit
    mov r2, #0
    hundredLoop:
        sub r0, r0, #+100
        add r2, r2, #+1
        cmp r0, #0
        bpl hundredLoop
    sub r2, r2, #+1
    add r0, r0, #+100
    lsl r2, r2, #8
    @ r1: 0000 | 0000 | 0000 |  0000 |  t   t   t   t  |  0   0   0   0  |  0   0   0   0 |  0   0   0   0
    @ r2: 0000 | 0000 | 0000 |  0000 |  0   0   0   0  |  a   b   c   d  |  0   0   0   0 |  0   0   0   0
    add r1, r1, r2



    @ r2 counts the amount of subtractions of 10 needed to eliminate the decimal digit
    mov r2, #0
    decimalLoop:
        sub r0, r0, #+10
        add r2, r2, #+1
        cmp r0, #0
        bpl decimalLoop
    sub r2, r2, #+1
    add r0, r0, #+10
    lsl r2, r2, #4
    @ r1: 0000 | 0000 | 0000 |  0000 |  t   t   t   t  |  h   h   h   h  |  0   0   0   0 |  0   0   0   0
    @ r2: 0000 | 0000 | 0000 |  0000 |  0   0   0   0  |  0   0   0   0  |  a   b   c   d |  0   0   0   0
    add r1, r1, r2

    @ r2 counts the amount of subtractions of 1 needed to eliminate the single digit
    mov r2, #0
    singleLoop:
        sub r0, r0, #+1
        add r2, r2, #+1
        cmp r0, #0
        bpl singleLoop
    sub r2, r2, #+1
    add r0, r0, #+1
    @ lsl r2, r2, #0
    @ r1: 0000 | 0000 | 0000 |  0000 |  t   t   t   t  |  h   h   h   h  |  d   d   d   d |  0   0   0   0
    @ r2: 0000 | 0000 | 0000 |  0000 |  0   0   0   0  |  0   0   0   0  |  0   0   0   0 |  a   b   c   d
    add r1, r1, r2

    end_getDecimalPlacesOfCounterVariable:
        ldr lr, [sp], #+8
        bx      lr
