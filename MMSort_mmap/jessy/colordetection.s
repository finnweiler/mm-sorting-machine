@ Jessy 14.2.2021
@ Color Detection Code

.text
 .global colordetection

colordetection:

    @ set r11 to 0 for following additions
    mov r11, #0   

    @ read GPIO22/Pin15 
    mov r0, #15             /*PinNr to read*/   
    bl read_pin             
    cmp r0, #1
    beq add_four

    @ read GPIO23/Pin16
    mov r0, #16             /*PinNr to read*/
    bl read_pin
    cmp r0, #1
    beq add_two

    @ read GPIO24/Pin18
    mov r0, #18              /*PinNr to read*/
    bl read_pin
    cmp r0, #1
    beq add_one
    bl colorfunction

    read_pin:
    ldr     r1, [r10], #+64
    mov     r2, #1
    mov     r2, r2, lsl r0
    and     r0, r2, r1

    @ if Pin15 is high, add four to r11 (because of placement of colorbit)
    add_four:  
        mov r0, #4              /* r0 = 4*/
        add r11, r11, r0        /* r11 = r11 + r0 */    

    @ if Pin16 is high, add two to r11 (because of placement of colorbit)
    add_two:
        mov r0, #2              /* r0 = 2*/
        add r11, r11, r0        /* r11 = r11 + r0 */    

    @ if Pin18 is high, add one to r11 (because of placement of colorbit)
    add_one:    
        mov r0, #1              /* r0 = 1 */
        add r11, r11, r0        /* r11 = r11 + r0 */

    colorfunction:
        @ After the three additions, r11 should contain a number matching the color of the mm
        @ if : the color red was detected, go to function red
        cmp r11, #1
        beq mov COLREG, #1
        @ if : the color green was detected, go to function green
        cmp r11, #2
        beq mov COLREG, #2
        @ if : the color blue was detected, go to function blue
        cmp r11, #3
        beq bmov COLREG, #3
        @ if : the color brown was detected, go to function brown
        cmp r11, #4
        beq mov COLREG, #4
        @ if : the color orange was detected, go to function orange
        cmp r11, #5
        beq mov COLREG, #5
        @ if : the color yellow was detected, go to function yellow
        cmp r11, #6
        beq mov COLREG, #6
        @ if : no color was detected
        cmp r11, #0
        beq mov COLREG, #0