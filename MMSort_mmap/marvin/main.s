@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@     main.s
@@@ ---------------------------------------------------------------------------
@@@     author:  ...
@@@     target:  Raspberry Pi
@@@     project: MM-Sorting-Machine
@@@     date:    YYYY/MM/DD
@@@     version: ...
@@@ ---------------------------------------------------------------------------
@@@ This program controls the MM-Sorting-Machine by reading two inputs,
@@@ controlling the motors(, serving the 7-segment display) and interacting
@@@ with the co-processor.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Constants for assembler
@ The following are defined in /usr/include/asm-generic/fcntl.h:
@ Note that the values are specified in octal.
    .equ    O_RDWR,00000002             @ open for read/write
    .equ    O_DSYNC,00010000            @ synchronize virtual memory
    .equ    __O_SYNC,04000000           @ programming changes with
    .equ    O_SYNC,__O_SYNC|O_DSYNC     @ I/O memory
@ The following are defined in /usr/include/asm-generic/mman-common.h:
    .equ    PROT_READ,0x1               @ page can be read
    .equ    PROT_WRITE,0x2              @ page can be written
    .equ    MAP_SHARED,0x01             @ share changes
@ The following are defined by me:
@    .equ      PERIPH,0x3f000000        @ RPi 2 & 3 peripherals
    .equ    PERIPH,0x20000000           @ RPi zero & 1 peripherals
    .equ    GPIO_OFFSET,0x200000        @ start of GPIO device
    .equ    TIMERIR_OFFSET,0xB000       @ start f´of IR and timer
    .equ    O_FLAGS,O_RDWR|O_SYNC       @ open file flags
    .equ    PROT_RDWR,PROT_READ|PROT_WRITE
    .equ    NO_PREF,0
    .equ    PAGE_SIZE,4096              @ Raspbian memory page
    .equ    FILE_DESCRP_ARG,0           @ file descriptor
    .equ    DEVICE_ARG,4                @ device address
    .equ    STACK_ARGS,8                @ sp already 8-byte aligned
@ The following are defined by my application logic:
    .equ    INPUT,0
    .equ    OUTPUT,1

TMPREG  .req    r5
RETREG  .req    r6
WAITREG .req    r8
RLDREG  .req    r9
GPIOREG .req    r10
COLREG  .req    r11

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ - START OF DATA SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    .data
    .balign   4

gpiomem:
    .asciz    "/dev/gpiomem"
mem:
    .asciz    "/dev/mem"
fdMsg:
    .asciz    "File descriptor = %i\n"
memMsgGpio:
    .asciz    "(GPIO) Using memory at %p\n"
memMsgTimerIR:
    .asciz    "(Timer + IR) Using memory at %p\n"

IntroMsg:
    .asciz    "Welcome to the MM-Sorting-Machine!\n"

testMsg1:
    .asciz    "test 1\n"

testMsg2:
    .asciz    "test 2\n"

    .balign   4
gpio_mmap_adr:
    .word     0           @ ...
gpio_mmap_fd:
    .word     0
timerir_mmap_adr:
    .word     0
timerir_mmap_fd:
    .word     0

@ - END OF DATA SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ - START OF TEXT SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    .text

    @ externals for making use of std-functions
    .extern printf

    @ externals for RGB LEDs
    .extern WS2812RPi_Init
    .extern WS2812RPi_DeInit
    .extern WS2812RPi_SetBrightness     @ provide (uint8_t brightness);
    .extern WS2812RPi_SetSingle         @ provide (uint8_t pos, uint32_t color);
    .extern WS2812RPi_SetOthersOff      @ provide (uint8_t pos);
    .extern WS2812RPi_AllOff            @ provide (void);
    .extern WS2812RPi_AnimDo            @ provide (uint32_t cntCycles);
    .extern WS2812RPi_Show

    .balign   4
    .global   main
    .type     main, %function
@ -----------------------------------------------------------------------------
@ main entry point of the application
@   param:     none
@   return:    none
@ -----------------------------------------------------------------------------
main:
    ldr r0, =IntroMsg
    bl  printf

    @ GET GPIO VIRTUAL MEMORY ---------------------------------------------
    @ create backup and reserve stack space
    sub     sp, sp, #16                 @ space for saving regs
    str     r4, [sp, #0]                @ save r4
    str     r5, [sp, #4]                @      r5
    str     fp, [sp, #8]                @      fp
    str     lr, [sp, #12]               @      lr
    add     fp, sp, #12                 @ set our frame pointer
    sub     sp, sp, #STACK_ARGS         @ sp on 8-byte boundary

    @ open /dev/gpiomem for read/write and syncing
    ldr     r0, =gpiomem                @ address of /dev/gpiomem
    ldr     r1, openMode                @ flags for accessing device
    bl      open
    mov     r4, r0                      @ use r4 for file descriptor

    @ display file descriptor
    ldr     r0, =fdMsg                  @ format for printf
    mov     r1, r4                      @ file descriptor
    bl      printf

    @ map the GPIO registers to a virtual memory location so we can access them
    str     r4, [sp, #FILE_DESCRP_ARG]  @ /dev/gpiomem file descriptor
    ldr     r0, gpio                    @ address of GPIO
    str     r0, [sp, #DEVICE_ARG]       @ location of GPIO
    mov     r0, #NO_PREF                @ let kernel pick memory
    mov     r1, #PAGE_SIZE              @ get 1 page of memory
    mov     r2, #PROT_RDWR              @ read/write this memory
    mov     r3, #MAP_SHARED             @ share with other processes
    bl      mmap

    @ save virtual memory address
    ldr     r1, =gpio_mmap_adr          @ store gpio mmap (virtual address)
    str     r0, [r1]
    ldr     r1, =gpio_mmap_fd           @ store the file descriptor
    str     r4, [r1]

    ldr     r6, [r1]
    mov     r1, r0                      @ display virtual address
    ldr     r0, =memMsgGpio
    bl      printf
    mov     r1, r6
    ldr     r0, =memMsgGpio
    bl      printf

    @ restore sp and free stack
    add     sp, sp, #STACK_ARGS         @ fix sp
    ldr     r4, [sp, #0]                @ restore r4
    ldr     r5, [sp, #4]                @      r5
    ldr     fp, [sp, #8]                @     fp
    ldr     lr, [sp, #12]               @     lr
    add     sp, sp, #16                 @ restore sp

    @ GET TIMER + IR VIRTUAL MEMORY ---------------------------------------
    @ create backup and reserve stack space
    sub     sp, sp, #16                 @ space for saving regs
    str     r4, [sp, #0]                @ save r4
    str     r5, [sp, #4]                @      r5
    str     fp, [sp, #8]                @      fp
    str     lr, [sp, #12]               @      lr
    add     fp, sp, #12                 @ set our frame pointer
    sub     sp, sp, #STACK_ARGS         @ sp on 8-byte boundary

    @ open /dev/gpiomem for read/write and syncing
    ldr     r0, =mem                    @ address of /dev/mem
    ldr     r1, openMode                @ flags for accessing device
    bl      open
    mov     r4, r0                      @ use r4 for file descriptor

    @ display file descriptor
    ldr     r0, =fdMsg                  @ format for printf
    mov     r1, r4                      @ file descriptor
    bl      printf

    @ map the GPIO registers to a virtual memory location so we can access them
    str     r4, [sp, #FILE_DESCRP_ARG]  @ /dev/mem file descriptor
    ldr     r0, timerIR                 @ address of timer + IR
    str     r0, [sp, #DEVICE_ARG]       @ location of timer +IR
    mov     r0, #NO_PREF                @ let kernel pick memory
    mov     r1, #PAGE_SIZE              @ get 1 page of memory
    mov     r2, #PROT_RDWR              @ read/write this memory
    mov     r3, #MAP_SHARED             @ share with other processes
    bl      mmap

    @ save virtual memory address
    ldr     r1, =timerir_mmap_adr       @ store timer + IR mmap (virtual address)
    str     r0, [r1]
    ldr     r1, =timerir_mmap_fd        @ store the file descriptor
    str     r4, [r1]

    ldr     r6, [r1]
    mov     r1, r0                      @ display virtual address
    ldr     r0, =memMsgTimerIR
    bl      printf
    mov     r1, r6
    ldr     r0, =memMsgTimerIR
    bl      printf

    @ restore sp and free stack
    add     sp, sp, #STACK_ARGS         @ fix sp
    ldr     r4, [sp, #0]                @ restore r4
    ldr     r5, [sp, #4]                @      r5
    ldr     fp, [sp, #8]                @     fp
    ldr     lr, [sp, #12]               @     lr
    add     sp, sp, #16                 @ restore sp

    @ initialize all other hardware
    b       hw_init

hw_init:
    ldr     r1, =gpio_mmap_adr          @ reload the addr for accessing the GPIOs
    ldr     GPIOREG, [r1]

                @Pins 9  8  7  6  5  4  3  2  1  0
    ldr     r0, =#0b000000001001001001001001000000
    str     r0, [GPIOREG] @Function Select Register 0 (Pin 0 - 9)

                @    19 18 17 16 15 14 13 12 11 10
    ldr     r0, =#0b001001001001000000001001001000
    str     r0, [GPIOREG, #4] @Function Select Register 1 (Pin 10 - 19) 

                @          27 26 25 24 23 22 21 20
    ldr     r0, =#0b000000001001000000000000000000
    str     r0, [GPIOREG, #8] @Function Select Register 1 (Pin 20 - 29)

    @ vairable currentPositionOfOutlet : currentColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown
    @ register COLREG : destinationColorInformation with range 0,1,2,...,6 , where 0 : no color detected, 1 : blue, 2 : green, 3 : yellow, 4 : orange, 5 : red, 6 : brown
    
    ldr r0, address_of_currentPositionOfOutlet 
    str #2, [r0]
    mov COLREG, #+5

    bl moveOutletToNextColor


    ldr r0, address_of_currentPositionOfOutlet 
    str #5, [r0]
    mov COLREG, #+2

    bl moveOutletToNextColor

    ldr r0, address_of_currentPositionOfOutlet 
    str #2, [r0]
    mov COLREG, #+5

    bl moveOutletToNextColor

    ldr r0, address_of_currentPositionOfOutlet 
    str #3, [r0]
    mov COLREG, #+1

    bl moveOutletToNextColor

    ldr r0, address_of_currentPositionOfOutlet 
    str #1, [r0]
    mov COLREG, #+3

    bl moveOutletToNextColor


    ldr r0, address_of_currentPositionOfOutlet 
    str #5, [r0]
    mov COLREG, #+0

    bl moveOutletToNextColor


    ldr r0, address_of_currentPositionOfOutlet 
    str #0, [r0]
    mov COLREG, #+5

    bl moveOutletToNextColor


    ldr r0, address_of_currentPositionOfOutlet 
    str #4, [r0]
    mov COLREG, #+4

    ldr r0, address_of_currentPositionOfOutlet 
    str #4, [r0]
    mov COLREG, #+0

    bl moveOutletToNextColor
    b       end_of_app



@ --------------------------------------------------------------------------------------------------------------------
@
@ ADDRESSES: Further definitions.
@
@ --------------------------------------------------------------------------------------------------------------------
    .balign 4
@ addresses of messages
openMode:
    .word   O_FLAGS
gpio:
    .word   PERIPH+GPIO_OFFSET
timerIR:
    .word   PERIPH+TIMERIR_OFFSET

@ --------------------------------------------------------------------------------------------------------------------
@
@ END OF APPLICATION
@
@ --------------------------------------------------------------------------------------------------------------------
end_of_app:
    ldr     r1, =gpio_mmap_adr          @ reload the addr for accessing the GPIOs
    ldr     r0, [r1]                    @ memory to unmap
    mov     r1, #PAGE_SIZE              @ amount we mapped
    bl      munmap                      @ unmap it
    ldr     r1, =gpio_mmap_fd           @ reload the addr for accessing the GPIOs
    ldr     r0, [r1]                    @ memory to unmap
    bl      close                       @ close the file

    ldr     r1, =timerir_mmap_adr       @ reload the addr for accessing the Timer + IR
    ldr     r0, [r1]                    @ memory to unmap
    mov     r1, #PAGE_SIZE              @ amount we mapped
    bl      munmap                      @ unmap it
    ldr     r1, =timerir_mmap_fd        @ reload the addr for accessing the Timer + IR
    ldr     r0, [r1]                    @ memory to unmap
    bl      close                       @ close the file

    mov     r0, #0                      @ return code 0
    mov     r7, #1                      @ exit app
    svc     0
    .end

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
