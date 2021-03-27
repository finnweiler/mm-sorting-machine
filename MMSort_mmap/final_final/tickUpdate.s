@ tickUpdate.s
@ This functions is called regularly to update the status of the button.
@ If the endbutton is pressed, a 1 is written to the global variable endButtonPressed.
@ This will be used to stop the sorting when the current M&M is sorted.
@ Parameters: 
@       none
@ Returns:
@       none

    .data
    .balign     4

.global endButtonPressed
endButtonPressed: 
    .word       0

    .text
    .balign   4
    .global   tickUpdate
    .type     tickUpdate, %function

tickUpdate:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    
    @ check if button was pressed
    @ if it was pressed write 1 to the global variable endButtonPressed
    mov     r0, #9 @ read pin 9 / button 2
    bl      readPin

    cmp     r0, #0 @ compare sensor value to 0
    bne     endTickUpdate

    ldr     r0, address_of_endButtonPressed
    mov     r1, #1
    str     r1, [r0]

    endTickUpdate:
        @ leaves the function 
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  
        bx      lr

.global address_of_endButtonPressed
address_of_endButtonPressed: .word endButtonPressed
