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
        .equ      O_RDWR,00000002             @ open for read/write
        .equ      O_DSYNC,00010000            @ synchronize virtual memory
        .equ      __O_SYNC,04000000           @      programming changes with
        .equ      O_SYNC,__O_SYNC|O_DSYNC     @ I/O memory
@ The following are defined in /usr/include/asm-generic/mman-common.h:
        .equ      PROT_READ,0x1               @ page can be read
        .equ      PROT_WRITE,0x2              @ page can be written
        .equ      MAP_SHARED,0x01             @ share changes
@ The following are defined by me:
@        .equ      PERIPH,0x3f000000           @ RPi 2 & 3 peripherals
        .equ      PERIPH,0x20000000           @ RPi zero & 1 peripherals
        .equ      GPIO_OFFSET,0x200000        @ start of GPIO device
        .equ      TIMERIR_OFFSET,0xB000       @ start f´of IR and timer
        .equ      O_FLAGS,O_RDWR|O_SYNC       @ open file flags
        .equ      PROT_RDWR,PROT_READ|PROT_WRITE
        .equ      NO_PREF,0
        .equ      PAGE_SIZE,4096              @ Raspbian memory page
        .equ      FILE_DESCRP_ARG,0           @ file descriptor
        .equ      DEVICE_ARG,4                @ device address
        .equ      STACK_ARGS,8                @ sp already 8-byte aligned

TMPREG  .req      r5
RETREG  .req      r6
WAITREG .req      r8
RLDREG  .req      r9
GPIOREG .req      r10           @ Adresse von den Pins, benutzen um Pins anzusprechen
COLREG  .req      r11           @ aktuell gescannte Farbe wird gespeichert

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

        .balign   4
gpio_mmap_adr:
        .word     0               @ ...
gpio_mmap_fd:
        .word     0
timerir_mmap_adr:
        .word     0
timerir_mmap_fd:
        .word     0

return_motor:
        .word     0
return_cw_90:
        .word     0
return_wait:
        .word     0

@ - END OF DATA SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ - START OF TEXT SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        .text

        @ externals for making use of std-functions
        .extern printf

        @ externals for delay functions (sleep, usleep)
        .extern sleep
        .extern usleep

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
        sub       sp, sp, #16                 @ space for saving regs
        str       r4, [sp, #0]                @ save r4
        str       r5, [sp, #4]                @      r5
        str       fp, [sp, #8]                @      fp
        str       lr, [sp, #12]               @      lr
        add       fp, sp, #12                 @ set our frame pointer
        sub       sp, sp, #STACK_ARGS         @ sp on 8-byte boundary

        @ open /dev/gpiomem for read/write and syncing
        ldr       r0, =gpiomem                 @ address of /dev/gpiomem
        ldr       r1, openMode                @ flags for accessing device
        bl        open
        mov       r4, r0                      @ use r4 for file descriptor

        @ display file descriptor
        ldr       r0, =fdMsg                  @ format for printf
        mov       r1, r4                      @ file descriptor
        bl        printf

        @ map the GPIO registers to a virtual memory location so we can access them
        str       r4, [sp, #FILE_DESCRP_ARG]  @ /dev/gpiomem file descriptor
        ldr       r0, gpio                    @ address of GPIO
        str       r0, [sp, #DEVICE_ARG]       @ location of GPIO
        mov       r0, #NO_PREF                @ let kernel pick memory
        mov       r1, #PAGE_SIZE              @ get 1 page of memory
        mov       r2, #PROT_RDWR              @ read/write this memory
        mov       r3, #MAP_SHARED             @ share with other processes
        bl        mmap

        @ save virtual memory address
        ldr       r1, =gpio_mmap_adr          @ store gpio mmap (virtual address)
        str       r0, [r1]
        ldr       r1, =gpio_mmap_fd           @ store the file descriptor
        str       r4, [r1]

        ldr       r6, [r1]
        mov       r1, r0                      @ display virtual address
        ldr       r0, =memMsgGpio
        bl        printf
        mov       r1, r6
        ldr       r0, =memMsgGpio
        bl        printf

        @ restore sp and free stack
        add       sp, sp, #STACK_ARGS         @ fix sp
        ldr       r4, [sp, #0]                @ restore r4
        ldr       r5, [sp, #4]                @      r5
        ldr       fp, [sp, #8]                @         fp
        ldr       lr, [sp, #12]               @         lr
        add       sp, sp, #16                 @ restore sp

        @ GET TIMER + IR VIRTUAL MEMORY ---------------------------------------
        @ create backup and reserve stack space
        sub       sp, sp, #16                 @ space for saving regs
        str       r4, [sp, #0]                @ save r4
        str       r5, [sp, #4]                @      r5
        str       fp, [sp, #8]                @      fp
        str       lr, [sp, #12]               @      lr
        add       fp, sp, #12                 @ set our frame pointer
        sub       sp, sp, #STACK_ARGS         @ sp on 8-byte boundary

        @ open /dev/gpiomem for read/write and syncing
        ldr       r0, =mem                    @ address of /dev/mem
        ldr       r1, openMode                @ flags for accessing device
        bl        open
        mov       r4, r0                      @ use r4 for file descriptor

        @ display file descriptor
        ldr       r0, =fdMsg                  @ format for printf
        mov       r1, r4                      @ file descriptor
        bl        printf

        @ map the GPIO registers to a virtual memory location so we can access them
        str       r4, [sp, #FILE_DESCRP_ARG]  @ /dev/mem file descriptor
        ldr       r0, timerIR                 @ address of timer + IR
        str       r0, [sp, #DEVICE_ARG]       @ location of timer +IR
        mov       r0, #NO_PREF                @ let kernel pick memory
        mov       r1, #PAGE_SIZE              @ get 1 page of memory
        mov       r2, #PROT_RDWR              @ read/write this memory
        mov       r3, #MAP_SHARED             @ share with other processes
        bl        mmap

        @ save virtual memory address
        ldr       r1, =timerir_mmap_adr       @ store timer + IR mmap (virtual address)
        str       r0, [r1]
        ldr       r1, =timerir_mmap_fd        @ store the file descriptor
        str       r4, [r1]

        ldr       r6, [r1]
        mov       r1, r0                      @ display virtual address
        ldr       r0, =memMsgTimerIR
        bl        printf
        mov       r1, r6
        ldr       r0, =memMsgTimerIR
        bl        printf

        @ restore sp and free stack
        add       sp, sp, #STACK_ARGS         @ fix sp
        ldr       r4, [sp, #0]                @ restore r4
        ldr       r5, [sp, #4]                @      r5
        ldr       fp, [sp, #8]                @         fp
        ldr       lr, [sp, #12]               @         lr
        add       sp, sp, #16                 @ restore sp

        @ initialize all other hardware
        b         hw_init

        @ regulates the sequence of the machine's functions
        application_code:
                bl      startFeeder
                bl      setMotorPins
                @bl      calibrateColorWheel
                @bl      color_wheel_turn_90_degrees
                @@@@ test values for the motors
                mov     r1, #400  @ 400 steps
                mov     r0, #1  @ turn counter-clockwise
                @@@@
                bl      stepColorWheel
                bl      stepOutlet
                bl      clearMotorPins
                bl      stopFeeder
                b       end_of_app

        @ starts the feeder by setting Pin 19 to high level
        start_feeder:
                mov     r1, #1
                mov     r0, r1, lsl #19
                str     r0, [GPIOREG, #28]
                bx      lr
        
        @ stops the feeder by setting Pin 19 to low level
        stop_feeder:
                mov     r1, #1
                mov     r0, r1, lsl #19
                str     r0, [GPIOREG, #40]
                bx      lr


        @ direction of rotation has to be stored in r2 before (0 = clockwise, 1 = counter clockwise)
        @ number of steps has to be stored in r4 before
        @ Color wheel performs the required number of steps in the direction clockwise or counter-clockwise
        steps_motor_color_wheel:

                @ stores the value of lr in address_of_return to be able to leave the function later
                ldr     r1, address_of_return_motor
                str     lr, [r1]

                @@@ set GPIO Output Pins 17 and 27 to high-level
                @ set Pin 17 to high level
                mov     r1, #1
                mov     r0, r1, lsl #17
                str     r0, [GPIOREG, #28]

                @ set Pin 27 to high-level
                mov     r1, #1
                mov     r0, r1, lsl #27
                str     r0, [GPIOREG, #28]
                
                @@@ sets the DirCW Pin of the Color Wheel, which controls the direction
                set_direction_color_wheel:
                        @ checks the received direction stored in r2 (0=clockwise, 1=counter-clockwise)
                        if_check_direction_color_wheel:
                                mov     r0, #1
                                cmp     r2, r0
                                blt     clockwise_color_wheel
                                beq     counter_clockwise_color_wheel
                                @ default: choose direcion clockwise
                                b       clockwise_color_wheel
                                @ set Pin 16 to low level to turn the color wheel clockwise
                                clockwise_color_wheel:
                                        mov     r1, #1
                                        mov     r0, r1, lsl #16
                                        str     r0, [GPIOREG, #40]
                                        b       step_counter_color_wheel
                                @ set Pin 16 to high level to turn the color wheel counter-clockwise
                                counter_clockwise_color_wheel:
                                        mov     r1, #1
                                        mov     r0, r1, lsl #16
                                        str     r0, [GPIOREG, #28]
                                        b       step_counter_color_wheel
                
                @ checks the amount of steps (stored in r4) and performs them
                step_counter_color_wheel:
                mov     TMPREG, #0
                @ checks if the final amount of steps is reached
                step_counter_loop_color_wheel:
                        cmp     TMPREG, r4
                        beq     end_motor_color_wheel
                        add     TMPREG, TMPREG, #1
                        b       one_step_color_wheel
                
                        @ set 'Step' Pin 13 to high and then to low level to do one step with the color wheel
                        one_step_color_wheel:

                                @ set 'Step' Pin 13 to high level
                                mov     r1, #1
                                mov     r0, r1, lsl #13
                                str     r0, [GPIOREG, #28]

                                @ add short delay
                                bl      wait_sleep
        
                                @ set 'Step' Pin 13 to low level
                                mov     r1, #1
                                mov     r0, r1, lsl #13
                                str     r0, [GPIOREG, #40]

                                @ add short delay
                                bl      wait_sleep

                                b       step_counter_loop_color_wheel
                
                @leaves the function steps_motor_color_wheel
                end_motor_color_wheel:
                        ldr     r1, address_of_return_motor
                        ldr     lr, [r1]
                        bx      lr
        
        
        @ function that turns the color wheel 90 degrees clockwise
        @ no necessary input registers
        color_wheel_turn_90_degrees:
                @ stores the value of lr in address_of_return to be able to leave the function later
                ldr     r1, address_of_return_cw_90
                str     lr, [r1]

                @ stores the direction and the steps in r2 and r4
                mov     r2, #0
                mov     r4, #400

                bl      steps_motor_color_wheel

                @ leaves the function color_wheel_90_degrees
                ldr     r1, address_of_return_cw_90
                ldr     lr, [r1]
                bx      lr
        

        @ direction of rotation has to be stored in r2 before (0 = clockwise, 1 = counter clockwise)
        @ number of steps has to be stored in r4 before
        @ Outlet performs the required number of steps in the required direction (clockwise or counter-clockwise)
        steps_motor_outlet:
        
                @ stores the value of lr in address_of_return to be able to leave the function later
                ldr     r1, address_of_return_motor
                str     lr, [r1]

                @@@ set GPIO Output Pins 11 and 27 to high-level
                @ set Pin 11 to high level
                mov     r1, #1
                mov     r0, r1, lsl #11
                str     r0, [GPIOREG, #28]

                @ set Pin 27 to high-level
                mov     r1, #1
                mov     r0, r1, lsl #27
                str     r0, [GPIOREG, #28]
                
                @@@ sets the 'DirOut' Pin 26 of the Outlet, which controls the direction
                set_direction_outlet:
                        @ checks the received direction stored in r2 (0=clockwise, 1=counter-clockwise)
                        if_check_direction_outlet:
                                mov     r0, #1
                                cmp     r2, r0
                                blt     clockwise_outlet
                                beq     counter_clockwise_outlet
                                @ default: choose direction clockwise
                                b       clockwise_outlet
                                @ set Pin 26 to low level to turn the outlet clockwise
                                clockwise_outlet:
                                        mov     r1, #1
                                        mov     r0, r1, lsl #26
                                        str     r0, [GPIOREG, #40]
                                        b       step_counter_outlet
                                @ set Pin 26 to high level to turn the outlet counter-clockwise
                                counter_clockwise_outlet:
                                        mov     r1, #1
                                        mov     r0, r1, lsl #26
                                        str     r0, [GPIOREG, #28]
                                        b       step_counter_outlet
                
                @ checks the amount of steps (stored in r4) and performs them
                step_counter_outlet:
                mov     TMPREG, #0
                @ checks if the final amount of steps is reached
                step_counter_loop_outlet:
                        cmp     TMPREG, r4
                        beq     end_motor_outlet
                        add     TMPREG, TMPREG, #1
                        b       one_step_outlet
                
                        @ set 'Step' Pin 12 to high and then to low level to do one step with the outlet
                        one_step_outlet:
                                @ set 'Step' Pin 12 to high level
                                mov     r1, #1
                                mov     r0, r1, lsl #12
                                str     r0, [GPIOREG, #28]

                                @ add short delay
                                bl      wait_sleep

                                @ set 'Step' Pin 12 to low level
                                mov     r1, #1
                                mov     r0, r1, lsl #12
                                str     r0, [GPIOREG, #40]

                                @ add short delay
                                bl      wait_sleep

                                b       step_counter_loop_outlet

                @ leaves the function steps_motor_color_wheel
                end_motor_outlet:
                        ldr     r1, address_of_return_motor
                        ldr     lr, [r1]
                        bx      lr
        
        @ function that creates a short break
        wait_sleep:
                @ stores the values of lr in addr_of_wait_return to be able to leave the function later
                ldr     r1, address_of_return_wait
                str     lr, [r1]
                @ create a short delay
                mov     r0, #10
                bl      usleep
                @ leaves the function wait_sleep
                ldr     r1, address_of_return_wait
                ldr     lr, [r1]
                bx      lr

address_of_return_motor:      .word return_motor
address_of_return_cw_90:    .word return_cw_90
address_of_return_wait: .word return_wait

hw_init:
        ldr       r1, =gpio_mmap_adr          @ reload the addr for accessing the GPIOs
        ldr       GPIOREG, [r1]

        @ TODO: PLEASE INIT HW HERE
        @ HINT:
        @   configuration of inputs is not necessary cause the pins are
        @   configured as inputs after reset

                    @Pins 9  8  7  6  5  4  3  2  1  0
        ldr     r0, =#0b000000001001001001001001000000
        str     r0, [GPIOREG] @Function Select Register 0 (Pin 0 - 9)

                    @    19 18 17 16 15 14 13 12 11 10
        ldr     r0, =#0b001001001001000000001001001000
        str     r0, [GPIOREG, #4] @Function Select Register 1 (Pin 10 - 19) 

                    @          27 26 25 24 23 22 21 20
        ldr     r0, =#0b000000001001000000000000000000
        str     r0, [GPIOREG, #8] @Function Select Register 2???? (Pin 20 - 29)


        @ TODO: BRANCH HERE TO YOUR APPLICATION CODE
        @ b         ...
        @ WARNING:
        @   call "end_of_app" if you're done with your application

        bl      sortTest1
        b       end_of_app

@ --------------------------------------------------------------------------------------------------------------------
@
@ ADDRESSES: Further definitions.
@
@ --------------------------------------------------------------------------------------------------------------------
        .balign   4
@ addresses of messages
openMode:
        .word     O_FLAGS
gpio:
        .word     PERIPH+GPIO_OFFSET
timerIR:
        .word     PERIPH+TIMERIR_OFFSET

@ --------------------------------------------------------------------------------------------------------------------
@
@ END OF APPLICATION
@
@ --------------------------------------------------------------------------------------------------------------------
end_of_app:
        ldr       r1, =gpio_mmap_adr          @ reload the addr for accessing the GPIOs
        ldr       r0, [r1]                    @ memory to unmap
        mov       r1, #PAGE_SIZE              @ amount we mapped
        bl        munmap                      @ unmap it
        ldr       r1, =gpio_mmap_fd           @ reload the addr for accessing the GPIOs
        ldr       r0, [r1]                    @ memory to unmap
        bl        close                       @ close the file

        ldr       r1, =timerir_mmap_adr       @ reload the addr for accessing the Timer + IR
        ldr       r0, [r1]                    @ memory to unmap
        mov       r1, #PAGE_SIZE              @ amount we mapped
        bl        munmap                      @ unmap it
        ldr       r1, =timerir_mmap_fd        @ reload the addr for accessing the Timer + IR
        ldr       r0, [r1]                    @ memory to unmap
        bl        close                       @ close the file

        mov       r0, #0                      @ return code 0
        mov       r7, #1                      @ exit app
        svc       0
        .end

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
