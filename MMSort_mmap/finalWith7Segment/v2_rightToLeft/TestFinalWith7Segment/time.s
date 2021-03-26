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

    @ ldr r0, =#1000000
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

    ldr r0, =#10000000000
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