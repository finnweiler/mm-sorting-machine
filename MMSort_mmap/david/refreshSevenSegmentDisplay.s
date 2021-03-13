@ David & Marvin, 12.03.21

.data

.text
.balign   4
.global   refreshSevenSegmentDisplay
.type     refreshSevenSegmentDisplay, %function

@ Function refreshes each of the four digits according to the 7segment binary configuration information stored in r2 
@ input: r2 contains the four 8bit 7segment binary configuration of the mmCounter Variable
@ whereas the first 8bits (MSB) represent thousand digit binary segment configuration
@ the second 8bits represent hundred digit binary segment configuration
@ the third 8bits represent decimal digit binary segment configuration
@ the fourth 8bits (LSB) represent single digit binary segment configuration
refreshSevenSegmentDisplay:
    str lr, [sp, #-8]!
  
    
    mov r3, #0 @ counter within range 0,1,2,3 to indicate each decimal place from single, decimal, hundreds, thousand
    decimalPlacePrintLoop:
        cmp r3, #4
        beq end_refreshSevenSegmentDisplay
        add r3, r3, #+1
            
    
    end_refreshSevenSegmentDisplay:
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
