; 16bit Main Timer der bei jedem Tick um 1 erhöht wird. Free Running Timer
; Wir haben 16bit Register die wir beschreiben können
; Wenn unsere Zahl == Main Timer Zahl ist -> passiert irgendwas

; Wir haben Prescaler Blöcke. Diese teilen die Taktfrequenz. /128,/64. Je nachdem was wir einstellen.

; Registersammlung
; TIOS -> Entweder Vergleich mit Main Timer oder Zählen von Input Flanken.
; TCNT -> Timer Count Register. Register des 16bit free running timers.
; TSCR1 -> Timer Control Register 1. Und wir wollen eigentlich nur Bit 7 auf 1. Also 0x80 im Register.
; TCTLX -> Bestimmen das Verhalten des Timer Moduls zum Port an dem der Timer hängt.
; TIE -> Enables Interrupts in the Timer on specific Timer Channels. 
; Wir wollen nur Channel 0 benutzen. Also sollte im TIE Register nur 0x01 stehen.
; Ebenso sollte deswegen im TIOS Register auch nur 0x01 stehen.
; TSCR2-> Timer Control Register 2. Da steht unser Prescaler drin.
; Wir wollen einen 128 Prescaler haben. Dazu müssen wir die letzten 3 bits in TSCR2 auf 1 stellen. 0x07
; Die Taktfrequenz wird dadurch von 24MHz zu 187.5KHz reduziert.
; Das bedeutet wir haben statt 24.000.000 Takte/s 187500Takte/s
; Wir wollen einen Delay von 250ms. Das sind 1/4s also 1/4s von 187500Takte/s = 46875Takte
; TC0 -> Timer Channel 0 Register. Das ist das Register in dem wir unsere Magic Number schreiben.
; TFLG1-> Timer Interrupt Flag Register. 




  INCLUDE 'mc9s12dp256.inc'
  
  XDEF initTimer;



.data: Section
 ;Softwarecounter 
 counter: DC.B 1;
.const: Section

.vect: Section
  ORG $FFEE
  timerHandler:  DC.W handleTimerChannel0Interrupt
  
.init: Section

initTimer:
  MOVB #$01,TIOS;
  MOVB #$01,TIE;
  MOVB #$07,TSCR2;
  ;MOVW #46875,TC0;
  MOVW #$B71B,TC0;
  MOVB #$00,counter;
  ; Aktiviert den Timer,sollte das letzte sein was passiert.
  MOVB #$80,TSCR1;
  
  RTS;

handleTimerChannel0Interrupt:
  ; Löst den Interrupt auf. Bzw. sagt dem Microcontroller, dass der Interrupt gehandelt ist.
  MOVB #$01,TFLG1;
  ; Stellt sicher, dass der nächste Interrupt nicht zu spät kommt, bzw der Offset konstant bleibt.
  LDD TC0;
  ADDD #$B71B;
  STD TC0;
 
 ;Incrementieren den counter um 1;
  INC counter; 
  
  ; D = A und B Register
  CLRA;
  LDAB counter;
  ; Wenn bei der Division mit 4 kein Rest entsteht, haben wir das ganze 4 mal ausgeführt.
  ; Das bedeutet nur jeder 4te Interrupt lässt die LED blinken
  LDX #8;
  IDIV;
  CMPB #0;
  BEQ blinkLED;
  BRA returnFromInterrupt;

blinkLED:  
  ;Lassen die LEDs blinken.
  COM  PORTB;
returnFromInterrupt:  
  ; Return from Interrupt
  RTI;
  
  



 



