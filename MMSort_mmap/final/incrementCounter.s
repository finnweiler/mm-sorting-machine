@ Marvin, 13.02.21
@ Implementierung einer InkrementCounter Funktion, um die Anzahl an richtig sortierten m&m's einzusehen
@ Implemenierung einer PrintCouner Funktion, um in der Konsole den Counter mit kurzer Message einzusehen

.data
.balign 4

@ Message String to see the current number of successfully allocated m&m's
mmCounterMessage: 
    .asciz      "MM-Counter: %d\n"

@ Counter Integer Variable to store in the current number of successfully allocated m&m's
mmCounterVariable: 
    .word       0 

.text

.balign   4
.global   address_of_mmCounterVariable
.global   incrementCounter
.type     incrementCounter, %function


@ Function that increments the mmCounter Variable by 1 to indicate a successful m&m allocation
@ no necessary input registers and no ouput
incrementCounter:
    str lr, [sp, #-8]!

    ldr     r0, address_of_mmCounterVariable
    ldr     r1, [r0]
    add     r1, r1, #1
    str     r1, [r0]
    
    ldr lr, [sp], #+8
    bx      lr


@ Function that prints into the console (stdout) the current number of successfully allocated m&m's
@ no necessary input registers
@ example output: MM-Counter: 21
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
address_of_mmCounterVariable : .word mmCounterVariable

@ Address of Message String onto Console to see the current number of successfully allocated m&m's
address_of_mmCounterMessage : .word mmCounterMessage