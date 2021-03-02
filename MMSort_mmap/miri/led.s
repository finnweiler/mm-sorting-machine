@ led.s

    .data
    .balign     4

GPIOREG .req      r10

startLedMessage:
    .asciz      "Leds started\n"

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
    .global   led
    .type     led, %function

led:
    push    {GPIOREG}
    bl      WS2812RPi_Init
    mov     r0, #50
    bl      WS2812RPi_SetBrightness
    bl      WS2812RPi_Show
    bl      WS2812RPi_DeInit
    pop     {GPIOREG}
