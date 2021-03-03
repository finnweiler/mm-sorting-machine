@ led.s

    .data
    .balign     4

GPIOREG .req      r10
COLREG  .req      r11

initLedMsg:
    .asciz      "Leds initiated\n"

deinitLedMsg:
    .asciz      "Leds deinitiated\n"

colorLedMsg:
    .asciz      "Color and position of leds changed"


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

    @ GPIOREG pushed on stack to save the content of the register
    push    {GPIOREG}
    
    @ sets the position and the color of the leds
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

    caseRed:
        mov     r0, #6
        ldr     r1, =#15712392
    caseGreen:
        mov     r0, #1
        ldr     r1, =#10020736
    caseBlue:
        mov     r0, #2
        ldr     r1, =#8451815
    caseBrown:
        mov     r0, #4
        ldr     r1, =#8431776
    caseOrange:
        mov     r0, #5
        ldr     r1, =#15198896
    caseYellow:
        mov     r0, #3
        ldr     r1, =#16316544
    
    bl      WS2812RPi_AllOff

    bl      WS2812RPi_SetSingle
    bl      WS2812RPi_Show

    @ sets the brightness of the leds to 70
    mov     r0, #70
    bl      WS2812RPi_SetBrightness
    bl      WS2812RPi_Show

    endChangeColorLed:
        ldr     r0, =colorLedMsg
        bl      printf
        @ pops the content of the stack back into the GPIOREG
        pop     {GPIOREG}
        ldr     r4, [sp], #+4
        ldr     lr, [sp], #+4  /* Pop the top of the stack and put it in lr */
        bx      lr



    .balign   4
    .global   initLed
    .type     initLed, %function

@ leds need to be initiated before using them the first time
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

@ leds need to be deinitiated when they're not needed anymore
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
