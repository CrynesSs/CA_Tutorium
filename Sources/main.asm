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
        XREF delay_500ms
        XREF add2zahlen
        XREF to_upper;
        XREF copy_string;
        XREF copy_string_stack;

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

IMAX: EQU 2048                          ; Symbolic constant
SEVEN_SEGS_OFF  EQU 1                   ; Uncomment this to turn seven segment display off

; RAM: Variable data section
.data: SECTION                          ; (Not used here, count variable i is put in register)
    ; DC.W == 16 bit Variable
    zahl: DC.W 1
    zahl2: DC.W 1
    ;String im Ram bleibt undefiniert
    ;string: DC.B "Hello World!1!",0 ; Test String für to_upper. Ist Null terminiert
    string2: DC.B "Hello World!1!"  ; Test String             . Ist nicht Null terminiert
    copytarget: DS.B 16;
; ROM: Constant data
.const:SECTION                          ; (Not used here)
    string: DC.B "Hello World!1!",0
; ROM: Code section
.init: SECTION  

main:                                   ; Begin of the program
Entry:   
        ; Port J = Stromversorgung
        ; Port P = PWM und SPI (SPI 1 hängt Seven Seg)
        ; Port B = LEDs (Daten für den Zustand der LEDs)               
        
        ; This is very importand and not optional
        ; To Init the Stack Pointer
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        
        CLI                             ; Enable interrupts, needed for debugger
        ;Jeder Port hat ein assoziertes Data Direction Registry
        ;Dieses Register steuert die Richtung des Datenflusses. Input / Output
        BSET DDRJ, #2                   ; Bit Set:   Port J.1 as output
        BCLR PTJ,  #2                   ; Bit Clear: J.1=0 --> Activate LEDs

  ifdef SEVEN_SEGS_OFF 
        ;MOVB bewegt einen Byte an eine bestimmte Stelle       
        MOVB #$0F, DDRP                 ; Port P.3..0 as outputs (seven segment display control)
        MOVB #$0F, PTP                  ; Turn off seven segment display
  endif

        MOVB #$FF, DDRB                 ; $FF -> DDRB:  Port B.7...0 as outputs (LEDs)
        ; #$55 = b01010101
        MOVB #$55, PORTB                ; $55 -> PORTB: Turn on every other LED
        ; Bewege 16 bit Zahl in die Variable zahl
        MOVW #$1111, zahl;
        MOVW #$2222, zahl2;
        ; Wir laden die Addresse des Strings in X;
        ;Initialisieren des Strings im RAM
        ; Ich muss den String von string -> copytarget kopieren
        
        
        
        PSHX; Push the X Register Content onto the Stack
        PSHY; Push the Y Register Content onto the Stack
        ; When using any Push, the Stackpointer decrements by that byte amount
        ; For Example if we push X, SP is decremented by 2.
        
        ; Source ist im X Register
        LDX #string
        ; Target ist im Y Register
        LDY #copytarget
        ; Aufruf der Subroutine
        JSR copy_string;
        
        ;Bring the Variables from before the function call back
        PULY; Pull the Y Register Value Back from the Stack;
        PULX; 
        
        
        ;T=0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
        PSHX; Push the X Register Content onto the Stack
        PSHY; Push the Y Register Content onto the Stack
        ; When using any Push, the Stackpointer decrements by that byte amount
        ; For Example if we push X, SP is decremented by 2.
        ;T=1
        ; Source ist im X Register
        LDX #string
        ; Target ist im Y Register
        LDY #copytarget
        PSHX;
        PSHY;
        ; Aufruf der Subroutine
        ; Return Address is written to the Stack
        JSR copy_string_stack;
        ;We will land here after Subroutine Returns.
        LEAS 4,+SP;
        
        
        ;Bring the Variables from before the function call back
        PULY; Pull the Y Register Value Back from the Stack;
        PULX;
        
        
        
        
        ; Schreiben die Addresse des neu kopierten Strings in das X Register
        LDX #copytarget;
        ; Wir rufen die to_upper funktion auf.
        JSR to_upper;
        
        
        
        
        
        
loop:   COM  PORTB                      ; Complement Port B: Toggle LEDs (Loop takes approx. 12 Mio CPU cycles => 0,5sec)

        ; Mit # laden wir die Speicheraddresse
        LDX #zahl;
        ; Ohne das # laden wir den tatsächlichen Wert
        LDY zahl2;
        JSR add2zahlen;
        
        JSR delay_500ms;
        ; Pseudo C Code : 
        ; for(int i=2048;i>0;--i){
        ;   for(int i=2048;i>0;--i){
        ;
        ;   } 
        ; }
        BRA loop                        ; Branch to loop

