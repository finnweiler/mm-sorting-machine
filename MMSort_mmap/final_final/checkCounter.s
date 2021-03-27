@ Implementierung einer InkrementCounter Funktion, um die Anzahl an richtig sortierten m&m's einzusehen
@ Implemenierung einer PrintCouner Funktion, um in der Konsole den Counter mit kurzer Message einzusehen

@ checkCounter.s
@ The checkCounter Function increments the mmCounterVariable by 1 to indicate a successful m&m allocation
@ Global Parameters:
@       r10 <- GPIO register 
@       r0 <- address_of_mmCounterVariable
@ Returns:
@       mmCounterVariable -> contains the number of m&ms which are already sorted


@ printMMCounterIntoConsole:
@ The printMMCounterIntoConsole Function prints the current number of successfully allocated m&m's into the console (stdout) 
@ Global Parameters: 
@       r0 <- address_of_mmCounterMessage
@       r1 <- address_of_mmCounterVariable
@ Returns:
@       r1 -> address_of_mmCounterVariable

.data
.balign 4

@ Message String to see the current number of successfully allocated m&m's
mmCounterMessage: 
    .asciz      "MM-Counter: %d\n"

@ Counter Integer Variable to store in the current number of successfully allocated m&m's
.global mmCounterVariable
mmCounterVariable: 
    .word       -1 

@ Counter Integer Variable to store in the current number of unsuccessfully detected m&m's a row
.global missingObjectVariable
missingObjectVariable: 
    .word       0

.text

.balign   4
.global   address_of_mmCounterVariable
.global   checkCounter
.type     checkCounter, %function


checkCounter:

    str lr, [sp, #-8]!

@ Reading Pin from Objectsensor
    mov r0, #22
    ldr     r1, [r10, #52]
    mov     r2, #1
    mov     r2, r2, lsl r0
    and     r0, r2, r1
@ check whether Object detected, if detected don't move to Counter
    cmp     r0, #1
    beq     missingObjectCounter

    cmp     r11, #0
    beq     missingObjectCounter

    ldr     r0, address_of_mmCounterVariable
    ldr     r1, [r0]
    add     r1, r1, #1
    str     r1, [r0]

    ldr     r0, address_of_missingObjectVariable
    ldr     r1, [r0]
    mov     r1, #0
    str     r1, [r0]

    bl end_checkCounter
    
    missingObjectCounter:
        ldr     r0, address_of_missingObjectVariable
        ldr     r1, [r0]
        add     r1, r1, #1
        str     r1, [r0]

    end_checkCounter:
        ldr lr, [sp], #+8
        bx      lr


.global   printMMCounterIntoConsole
.type     printMMCounterIntoConsole, %function
printMMCounterIntoConsole:
    str lr, [sp, #-8]!
    
    ldr r0, address_of_mmCounterMessage
    ldr r1, address_of_mmCounterVariable
    ldr r1, [r1]
    bl printf

    ldr lr, [sp], #+8
    bx lr


@ Address of Counter Integer Variable to store in the current number of successfully allocated m&m's
.global address_of_mmCounterVariable
address_of_mmCounterVariable : .word mmCounterVariable

@ Address of Message String onto Console to see the current number of successfully allocated m&m's
address_of_mmCounterMessage : .word mmCounterMessage

.global address_of_missingObjectVariable
address_of_missingObjectVariable: .word missingObjectVariable
