@ led.s
@ contains three led functions
@ changeColorLed changes the color and position of the led according to the value stored in the COLREG
@ Global Parameters:
@       r10 <- GPIO register
@ Parameters:
@       r11 <- COLREG
@ Returns:
@       none    

    .data
    .balign     4

GPIOREG .req      r10
COLREG  .req      r11

initLedMsg:
    .asciz      "Leds initiated\n"

deinitLedMsg:
    .asciz      "Leds deinitiated\n"

colorLedMsg:
    .asciz      "Color and position of leds changed\n"


    .text

@ externals for RGB LEDs
.extern WS2812RPi_Init
.extern WS2812RPi_DeInit
.extern WS2812RPi_SetBrightness       @ provide (uint8_t brightness);
.extern WS2812RPi_SetSingle           @ provide (uint8_t pos, uint32_t color);
.extern WS2812RPi_SetOthersOff        @ provide (uint8_t pos);
.extern WS2812RPi_AllOff              @ provide (void);
.extern WS2812RPi_AnimDo              @ provide (uint32_t cntCycles);
.extern WS2812RPi_Show


    .balign   4
    .global   changeColorLed
    .type     changeColorLed, %function

changeColorLed:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    push    {GPIOREG}
    
    @ turns all leds off
    bl      WS2812RPi_AllOff
    bl      WS2812RPi_Show

    decision:
    @ checks which color was stored in the COLREG
    mov     r1, COLREG

    cmp     r1, #1
    beq     caseRed
    cmp     r1, #2
    beq     caseGreen
    cmp     r1, #3
    beq     caseBlue
    cmp     r1, #4
    beq     caseBrown
    cmp     r1, #5
    beq     caseOrange
    cmp     r1, #6
    beq     caseYellow
    cmp     r1, #0
    beq     endChangeColorLed

    @ stores the color and position of the leds according to the recognized color
    caseRed:
        mov     r0, #6
        ldr     r1, =#0xFF0000
        b       setLed
    caseGreen:
        mov     r0, #1
        ldr     r1, =#0x00FF00
        b       setLed
    caseBlue:
        mov     r0, #2
        ldr     r1, =#0x0000FF
        b       setLed
    caseBrown:
        mov     r0, #4
        ldr     r1, =#0x611a03
        b       setLed
    caseOrange:
        mov     r0, #5
        ldr     r1, =#0xeb5b02
        b       setLed
    caseYellow:
        mov     r0, #3
        ldr     r1, =#0xf0fc00
        b       setLed
    
    @ sets the led to the stored color and position
    setLed:
        bl      WS2812RPi_SetSingle
        bl      WS2812RPi_Show

        @ sets the brightness of the leds to 70
        mov     r0, #70
        bl      WS2812RPi_SetBrightness
        bl      WS2812RPi_Show

    endChangeColorLed:
        ldr     r0, =colorLedMsg
        bl      printf
        
        pop     {GPIOREG}
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr



    .balign   4
    .global   initLed
    .type     initLed, %function

@ leds are initiated before using them the first time
initLed:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    push    {GPIOREG}

    bl      WS2812RPi_Init
    ldr     r0, =initLedMsg
    bl      printf

    pop     {GPIOREG}
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr



    .balign   4
    .global   deinitLed
    .type     deinitLed, %function

@ leds are deinitiated when they're not needed anymore
deinitLed:
    str     lr, [sp, #-4]!  @store value of lr in the stack to be able to return later 
    str     r4, [sp, #-4]!
    push    {GPIOREG}

    bl      WS2812RPi_AllOff
    bl      WS2812RPi_DeInit
    ldr     r0, =deinitLedMsg
    bl      printf

    pop     {GPIOREG}
    ldr     r4, [sp], #+4
    ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
    bx      lr
