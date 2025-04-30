; Ziel ist es einen 1s/10s Timer abzubilden.
; Beide Timer mit jeweils einem Interrupt zu realisierien sind

; Register / Good to Know
; $FF8E Addresse für den Port P Interrupt
; Für unsere Zwecke wollen wir eigentlich nur auf einer Flanke triggern. Also Rising/Falling nicht Dual.

; PWME Enable Register für PWM
; PWMPOL Entscheidet ob das PWM Signal mit einer 0 oder 1 anfängt.
; PWMPER PWM Period Register (T2)
; PWMDTY PWM Duty Register (T1)
; Clock A = 2400000Take/s / Prescaler
; PWMSCLA Scale for Clock A. Clock SA = Clock A / (2 * PWMSCLA)  PWMSCLA element [1,255] 0 -> 256
; PWMSCLB Scale for Clock B. Clock SB = Clock B / (2 * PWMSCLB)  PWMSCLB element [1,255] 0 -> 256

; PWMPRCLK Prescale for Clock A und B. Wie auch beim Timer. Bit 4-6 ist Prescale Clock B. Bit 0-2 ist Prescale Clock A.

; Der Vorteil hier : Wir können den Prescaler weiter mit der Scale vergrößern.
; Maximaler Prescale ist 128 * 512 = 65536. Wir können nur in Inkrementen von 2 erhöhen.
; E Clock wird um den Prescaler geteilt und dann um 2 * PWMSCLA geteilt.

; PWMCTL PWM Control Register. Das schliesst 2 8 bit Channel zu einem 16 bit Channel zusammen. (#$F0)
; PWMCLK PWM Clock Select Register. Wählt zwischen Clock A/SA und B/SB.

; PIEP Port P Interrupt Enable Register (#$55) Weil wir nur 1010 1010 jeden zweiten Bit tatsächlich benutzen
; PPSP Port P Polority Select Register. Ob der Interrupt bei Rising oder Falling Edge ist.

; Wir benutzen nur die Clock A. In Channel 1 und 5. 1s soll in Channel 1 sein. Die 10s sollen in Channel 5 sein.
; Das bedeutet die Zahl in PWMPER5 = PWMPER1 * 10. PWMDTY5 = PWMDTY1 * 10;
; Zwei Zahlen zwischen 0 und 65535 sodass mit dem gleichen Prescaler im Channel 1 1s und im Channel 5 10s Interrupts passieren.

; Die PORTS sind Out of Reset im Zustand FF. 
; Das bedeutet unser PWM Signal sollte auf 1 beginnen und nach 1s wieder auf 1 gehen. Irgendwo dazwischen muss es 0 sein.
; Das der Interrupt auf dem Port P sollte bei einer Rising Edge triggern.


; 24000000 / 128 = 187500 Takte/s. also muss SA = 1875Takte/s sein. 1875 soll 1s sein. 18750 soll 10s sein.
; 1875 = 187500 / (2 * PWMSCLA) <=> PWMSCLA = (187500 / 1875) / 2 = 50. Verlangsamung ist Faktor 100 * 128 = 12800
; 24000000 / 12800 = 1875 Takte/s
; Magic Number für 1s ist 1875 -> PWMPER1. 0x0753
; Magic Number für 10s ist 18750 -> PWMPER5. 0x493E 
; Duty cycles sind uns hier egal. -> PWMDTY 1,5 irgendeine Zahl sein kann die entsprechend zwischen (0,PWMPERx)
 INCLUDE 'mc9s12dp256.inc'
	
    XDEF initPWM;

.vect: Section
  org $FF8E
  pwm: DC.W pwmInterruptHandler;
.init: Section

; NOTE : Alle Register waren im Tutorium verkehrt herum geschrieben. 
; Also PWMPER0 <-> PWMPER1...
; In dieser Version korrigiert...
initPWM:	
  ; Port P Soll Output sein für das PWM Signal
  MOVB #$FF,DDRP;
  ; Weil wir Channel 7,5,3,1 benutzen
  ; MOVB #$55,PIEP; Falsch das muss #$AA sein.
  MOVB #$AA,PIEP;
  ; Rising Edge Interrupt auf dem Port P
  MOVB #$FF,PPSP
  ; Ab Hier nur noch PWM Init
  ; Magic Number für die Period Length 1s
  MOVB #$07,PWMPER0;
  MOVB #$53,PWMPER1;
  ; Magic Number für die Period Length 10s
  MOVB #$49,PWMPER4;
  MOVB #$3E,PWMPER5;
  ;DUTY Register
  ; 375 in PWMDTY für Channel 5. 0x0177
  ; 3750 in PWMDTY für Channel 1 0x0EA6
  MOVB #$01,PWMDTY0;
  MOVB #$77,PWMDTY1;
  
  MOVB #$0E,PWMDTY4;
  MOVB #$A6,PWMDTY5;
  ; Signal beginnt mit einer 1 und geht bei Duty Count = PWMCount zu 0;
  MOVB #$FF,PWMPOL;
  ; Schliesst die Channel 01,23,45,67 zu einem Zusammen
  MOVB #$F0,PWMCTL;
  ; Clock Select. FF -> Alle 4 Channels benutzen SA/SB statt A/B
  MOVB #$FF,PWMCLK;
  ; Berechneter Scaler für die Clock A
  MOVB #$32,PWMSCLA;
  ; Prescaler 128 für beide Clocks
  MOVB #$77,PWMPRCLK;
   
  ; Enable all Channels
  MOVB #$FF,PWME;
  
  RTS;
; In the Simulator, this code fires immediately after the PWME as the Ports in the Sim start at 00 and on the Board with FF 
pwmInterruptHandler:
checkChannel1:
  BRCLR PIFP,#$02,checkChannel3;
  JSR handleChannel1;  
checkChannel3:
  BRCLR PIFP,#$08,checkChannel5;
  JSR handleChannel3;  
checkChannel5:
  BRCLR PIFP,#$20,checkChannel7;
  JSR handleChannel5;
checkChannel7:
  BRCLR PIFP,#$80,checkEnd;
  JSR handleChannel7;  	  
checkEnd:  
  RTI;

handleChannel1:
 MOVB #$02,PIFP;
 RTS;
handleChannel3:
 MOVB #$08,PIFP;
 RTS; 
 handleChannel5:
 MOVB #$20,PIFP;
 RTS; 
 handleChannel7:
 MOVB #$80,PIFP;
 RTS; 
  
  
  
  
  
  
  
  
  
  
  
  