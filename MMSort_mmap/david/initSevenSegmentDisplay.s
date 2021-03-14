@ David & Marvin, 12.03.21

.data

.text
.extern usleep
.balign   4
.global   initSevenSegmentDisplay
.type     initSevenSegmentDisplay, %function

@ Function refreshes each of the four digits according to the 7segment binary configuration information stored in r2 
@ input: r2 contains the four 8bit 7segment binary configuration of the mmCounter Variable
@ whereas the first 8bits (MSB) represent thousand digit binary segment configuration
@ the second 8bits represent hundred digit binary segment configuration
@ the third 8bits represent decimal digit binary segment configuration
@ the fourth 8bits (LSB) represent single digit binary segment configuration
initSevenSegmentDisplay:
    str lr, [sp, #-8]!
  

  
    @ Single ----
    @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select single SevenSegment Digit
    @ set GPIO Pin 6 low
    mov     r0, #1
    lsl     r0, r0, #6 
    str     r0, [r10, #40]
    @ set GPIO Pin 7 low
    mov     r0, #1
    lsl     r0, r0, #7 
    str     r0, [r10, #40]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]

    @ set GPIO Pin 5 (RCLK) low
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) low 
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 4 (nSRCLR) low - a Low Level on Pin nSRCLR resets the contents of each Flip-Flop of the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 5 (RCLK) high - a Low-High-Pulse on Pin RCLK is used to load the content of each Flip-Flop from the Schieberegister into the Ausgangsregister
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #28]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]




    @ Decimal ----
    @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select decimal SevenSegment Digit
    @ set GPIO Pin 6 high
    mov     r0, #1
    lsl     r0, r0, #6 
    str     r0, [r10, #28]
    @ set GPIO Pin 7 low
    mov     r0, #1
    lsl     r0, r0, #7 
    str     r0, [r10, #40]


    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]

    @ set GPIO Pin 5 (RCLK) low
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) low 
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 4 (nSRCLR) low - a Low Level on Pin nSRCLR resets the contents of each Flip-Flop of the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 5 (RCLK) high - a Low-High-Pulse on Pin RCLK is used to load the content of each Flip-Flop from the Schieberegister into the Ausgangsregister
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #28]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]




    @ Hundred ----
    @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select hundred SevenSegment Digit
    @ set GPIO Pin 6 low
    mov     r0, #1
    lsl     r0, r0, #6 
    str     r0, [r10, #40]
    @ set GPIO Pin 7 high
    mov     r0, #1
    lsl     r0, r0, #7 
    str     r0, [r10, #28]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]

    @ set GPIO Pin 5 (RCLK) low
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) low 
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 4 (nSRCLR) low - a Low Level on Pin nSRCLR resets the contents of each Flip-Flop of the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 5 (RCLK) high - a Low-High-Pulse on Pin RCLK is used to load the content of each Flip-Flop from the Schieberegister into the Ausgangsregister
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #28]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]
            

         
            
    @ Thousand ----
    @ Multiplexer needs Signal A (GPIO Pin 6) and B (GPIO Pin 7) to select thousand SevenSegment Digit
    @ set GPIO Pin 6 high
    mov     r0, #1
    lsl     r0, r0, #6 
    str     r0, [r10, #28]
    @ set GPIO Pin 7 high
    mov     r0, #1
    lsl     r0, r0, #7 
    str     r0, [r10, #28]
            
    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]

    @ set GPIO Pin 5 (RCLK) low
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) low 
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 4 (nSRCLR) low - a Low Level on Pin nSRCLR resets the contents of each Flip-Flop of the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #40]

    @ set GPIO Pin 3 (SRCLK) high - a Low-High-Pulse on Pin SRCLK is used to shift the a) contents of each Flip-Flop from the Schieberegister into the successor Flip-Flop from the Schieberegister
    @ and b) to set the SER bit to the first FlipFlop in the Schieberegister
    mov     r0, #1
    lsl     r0, r0, #3 
    str     r0, [r10, #40]

    @ set GPIO Pin 5 (RCLK) high - a Low-High-Pulse on Pin RCLK is used to load the content of each Flip-Flop from the Schieberegister into the Ausgangsregister
    mov     r0, #1
    lsl     r0, r0, #5 
    str     r0, [r10, #28]

    @ set GPIO Pin 4 (nSRCLR) high
    mov     r0, #1
    lsl     r0, r0, #4 
    str     r0, [r10, #28]
        
            
    
    end_initSevenSegmentDisplay:
        ldr lr, [sp], #+8
        bx      lr



@Gewünschtes Level (0 oder 1) an Pin „SER“ anlegen und nSRCLR auf
@ High-Level setzen. (Ein Low-Level würde zum Reset der Logik führen.)

    @2. Generierung des Takts an Pin „SRCLK“ oder „SCK“
    @1. Eine steigende Flanke an diesem Pin sorgt dafür, dass der aktuell an „SER“ anliegende Wert als
    @ neuer Wert für Bit 0 übernommen wird.
    @2. Alle anderen Werte werden von dem IC selbstständig „weitergeschoben“.

@3. Erzeugung des Übernahmetaktes an Pin „RCLK“ oder „RCK“
    @1. Ein Low-High Puls (d.h. eine steigende Flanke) sorgt dafür, dass die Inhalte der Schieberegister in das
    @ Ausgangsregister übernommen werden

@4. Pin „nSRCLR“ auf Low-Level setzen


@Raspberry Pi
@(GPIO) Signal Label Hardware
@2 Output SER 7-Segment
@3 Output SRCLK 7-Segment
@4 Output nSRCLR 7-Segment
@5 Output RCLK 7-Segment
@6 Output A 7-Segment
@7 Output B 7-Segment


@7-SegmentDisplay B A
@1 0 0
@2 0 1
@3 1 0
@4 1 1

@ Hinweise:
@- max. Clock-Frequenz: 5MHz
@- 0b 1 1 1 1 1 1 1 1
@ A B C D E F G DOT
@d.h. das Level (0 = Low; 1 =
@High) für den DOT wird zu
@erst in das Schieberegister
@gegeben. 