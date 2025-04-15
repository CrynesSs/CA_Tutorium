
; PPSH -> Port H Polarity Select Register. 
; Select the active Interrupt Edge. Rising Edge or Falling Edge.
; Falling Edge : We are going from 1 to 0;
; Rising Edge : We are going from 0 to 1;
; Quick Trivia : 
; If both Edges are doing something, we can call that Dual Edge.

; DDRH -> Data Direction Registry Port H.
; Indicates if Port H is used as an INPUT or OUTPUT.

; PIEH -> Port H Interrupt Enable Register
; Enables Interrupts on Port H

; PIFH -> Port H Flag Register
; Indicates on which Bit of Port H the Interrupt happened.
; If you dont clear this before resuming, your program is ded.
; FIRST THING TO DO IS CLEARING THIS

  INCLUDE 'mc9s12dp256.inc'

  XDEF initPortHinterrupts;


.data: Section


.const: Section


.vect: Section
    ; Address of the Interrupt. Found in the Interrupt Vector Table in the Manual.
	ORG $FFCC
	; We link our Function to the Interrupt
  	DC.W buttonInterruptHandler;
  	;Alternatively you can also name this. If not it will show up as Var0000001 in the Memory Tab of the Debugger.
  	;Uncomment this line to see that in effect. Dont forget to comment out the line above.
	;portHInterruptHandler: DC.W buttonInterruptHandler

.init: Section

initPortHinterrupts:
  ; Write to the Register DDRH that Port H is used as INPUT. 0->Input
  MOVB #$00,DDRH
  
  ; Case we are in the Simulator. Buttons start with 0. And when pressed go to 1;
  ; Button Press is a Rising Edge. Rising Edge -> 1 in the PPSH
  MOVB #$0F,PPSH
  ; Case we are in the Monitor/On the Board. Buttons start with 1. When pressed go to 0;
  ; Button Press is a Falling Edge. Falling Edge -> 0 in the PPSH
  ; MOVB #$00,PPSH
  
  ; For the PIEH we need a 1 in the Register where we want our Interrupts to be active.
  ; Because we want them only active on the lower 4 bits of the Port H 
  MOVB #$0F,PIEH;
  
  RTS; 


buttonInterruptHandler:
  ; Load the Flag Register into B so we can use it later.
  LDAB PIFH;
  PSHB; We pushed something on the Stack. So here the Stackpointer is already decremented by 1;
  ; Here we are CLEARING the Register
  MOVB #$FF,PIFH;
  ; There will always be just 1 bit that is 1 in the Register B.
  CMPB #$01; If this is true/equal we know the Interrupt happened on Bit 0, Or Button 1;
  BEQ handleButton1;
  CMPB #$02; If this is true/equal we know the Interrupt happened on Bit 1, Or Button 2;
  BEQ handleButton2;
  CMPB #$04; If this is true/equal we know the Interrupt happened on Bit 2, Or Button 3;
  BEQ handleButton3;
  CMPB #$08; If this is true/equal we know the Interrupt happened on Bit 3, Or Button 4;
  BEQ handleButton4;

handleButton1:
  LDAA #1;
  ;LBRA return; Takes longer to branch, but reaches further than normal BRA
  BRA return; Usually what you want to use.
  JSR return_jump; Be careful with the Stack Pointer. Because you will get the wrong return address if you dont move the Stack Pointer accordingly.
  ;RTI ; Fourth Option. Just use an RTI directly.
handleButton2:
  LDAA #2;
  BRA return;
handleButton3:
  LDAA #3;
  BRA return;
handleButton4:  
  LDAA #4;
  BRA return;
return:
  LEAS 1,+SP; Because we pushed something on the Stack, we need to adjust the SP to point to the return Address.
  RTI;
  
return_jump:
  LEAS 3,+SP;
  RTI;	  
  
  


