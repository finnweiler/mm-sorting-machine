@ Marvin, 13.02.21
@ Implementierung einer InkrementCounter Funktion, um die Anzahl an richtig sortierten m&m's einzusehen
@ Implemenierung einer PrintCouner Funktion, um in der Konsole den Counter mit kurzer Message einzusehen


.data
@ Message String to see the current number of successfully allocated m&m's
.balign 4
mmCounterMessage: .asciz "MM-Counter: %d\n"
@ Counter Integer Variable to store in the current number of successfully allocated m&m's
.balign 4
mmCounterVariable: .word 0 

.text
@ Function that increments the mmCounter Variable by 1 to indicate a successful m&m allocation
@ no necessary input registers and no ouput
incrementCounter:
    @ str lr, [sp, #-8]!
    ldr r0, address_of_mmCounterVariable
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    @ ldr lr, [sp], #+8
    bx lr
@ Function that prints into the console (stdout) the current number of successfully allocated m&m's
@ no necessary input registers
@ example output: MM-Counter: 21
printMMCounterIntoConsole:
    str lr, [sp, #-8]!
    
    ldr r0, address_of_mmCounterMessage
    ldr r1, address_of_mmCounterVariable
    ldr r1, [r1]
    bl printf

    ldr lr, [sp], #+8
    bx lr

.global main
main:
    str lr, [sp, #-8]!


    /* Example Usage of the print and increment functions implemented */
    bl printMMCounterIntoConsole

    bl incrementCounter
    bl incrementCounter
    bl incrementCounter
    bl incrementCounter

    bl printMMCounterIntoConsole

    bl incrementCounter
    bl incrementCounter
    bl incrementCounter
    bl incrementCounter

    bl printMMCounterIntoConsole
    /* Example Usage of the print and increment functions implemented */


    ldr lr, [sp], #+8
    bx lr
@ Address of Message String onto Console to see the current number of successfully allocated m&m's
address_of_mmCounterMessage : .word mmCounterMessage
@ Address of Counter Integer Variable to store in the current number of successfully allocated m&m's
address_of_mmCounterVariable : .word mmCounterVariable
/* External */
.global printf

@ MakeFile CheatSheet
@ target: target.o
@ 	gcc -o target target.o
@ 	rm target.o
@ target.o: target.s
@ 	as -o target.o target.s
