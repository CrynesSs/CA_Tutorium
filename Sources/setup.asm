
    INCLUDE 'mc9s12dp256.inc'

	XDEF initLed,initSevenSeg
	

SEVEN_SEGS_OFF  EQU 1                   ; Uncomment this to turn seven segment display off

.data: SECTION

.const: SECTION

.init: SECTION

initLed:
	; Editors Note : 
	; Every Port has an associated Data Direction Registry
	; Port J = Power Control
    ; Port P = PWM und SPI (SPI 1 = Seven Seg)
    ; Port B = LEDs (LEDs)
	; The function of which is to tell if it is an Output or Input Port
	; DDR? Registers are always initialized to 00
	; Port Register most of the time are initialized to 0xFF
	; End Editors Note
	
	; Set the Data Direction of Port B to be OUTPUT
	MOVB #$FF, DDRB	
	; Remove any Data in the Port Register if there was any
	MOVB #$00, PORTB	
	BSET DDRJ, #2                   ; Bit Set:   Port J.1 as output
    BCLR PTJ,  #2                   ; Bit Clear: J.1=0 --> Activate LEDs
    RTS
initSevenSeg:        
	ifdef SEVEN_SEGS_OFF 
	   	; Set the Data Direction of the lower 4 bits of Port P to be OUTPUT     
		MOVB #$0F, DDRP                 ; Port P.3..0 as outputs (seven segment display control)
		; Set the Port Register to 0F so the Seven Seg is OFF
		MOVB #$0F, PTP                  ; Turn off seven segment display
	endif	
	RTS
	
	