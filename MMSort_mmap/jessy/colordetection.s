@ Jessy 14.2.2021
@ Color Detection Code
.data

GPIOREG .req r10

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
    @ FEHLER: internal_relocation (type: OFFSET_IMM) not fixed up
    @   ldr r1, GPIOREG         /*urspründlich anstelle der ersten zwei Zeilen von read_pin*/
    @ FEHLER: undefined reference to `GPIOREG'
        ldr r3,=GPIOREG
        ldr r1, [r3]            /*physical adress of start of adresses of the gpio pins*/
        ldr r2, [r1, #52]       /*loads adress of exact pin you want to read into register*/
        lsr r2, r2, r0          /*assuming r0 is set to the pin number to read*/
        and r0, r2, #1          /*this will clear all values except the least significant bit (our pin value).*/

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
        beq red
        @ if : the color green was detected, go to function green
        cmp r11, #2
        beq green
        @ if : the color blue was detected, go to function blue
        cmp r11, #3
        beq blue
        @ if : the color brown was detected, go to function brown
        cmp r11, #4
        beq brown
        @ if : the color orange was detected, go to function orange
        cmp r11, #5
        beq orange
        @ if : the color yellow was detected, go to function yellow
        cmp r11, #6
        beq yellow
        @ if : no color was detected (?)
        @ Soll die Farberkennung nochmal durchgeführt werden (?, anpassen ans color wheel)
        cmp r11, #0
        beq colordetection