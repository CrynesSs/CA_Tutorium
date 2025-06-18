;   Blinking LEDs on Dragon12 - ASM version
;
;   Computerarchitektur
;   (C) 2021 J. Friedrich, W. Zimmermann
;   Hochschule Esslingen
;
;   Author:  W.Zimmermann, Jan 21, 2021
;            (based on code provided by J. Friedrich)
;


; export symbols
        XDEF Entry, main
        XDEF IMAX
       

; import symbols
        XREF __SEG_END_SSTACK           ; End of stack
        ; From delay.asm
        XREF delay_500ms     
	   	XREF initPWM;
        XREF initTimer;
        XREF initLed,initSevenSeg
        XREF exampleUsage
        XREF initPortHinterrupts;
		XREF test128bitFunctions;

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

IMAX: EQU 2048                          ; Symbolic constant

; RAM: Variable data section
.data: SECTION                          ; (Not used here, count variable i is put in register)  
    
; ROM: Constant data
.const:SECTION                          ; (Not used here)
    
; ROM: Code section
.init: SECTION  

main:                                   ; Begin of the program
Entry:   
                       
        
        ; This is very importand and not optional
        ; To Init the Stack Pointer
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        
        CLI                             ; Enable interrupts, needed for debugger
        
        JSR initLed;
        
        JSR initSevenSeg;
        
        JSR initPortHinterrupts; 
        
        JSR initTimer;
        
        JSR initPWM;
        
        JSR exampleUsage;
        
        JSR test128bitFunctions;

        
        
loop:   
		;COM  PORTB                      ; Complement Port B: Toggle LEDs (Loop takes approx. 12 Mio CPU cycles => 0,5sec)

        ;JSR delay_500ms;
        
        BRA loop                        ; Branch to loop

