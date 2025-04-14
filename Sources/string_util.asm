; array[0] , array[12] 
; DS.B: string "Hello World",0
; LDX string
; Zeigt die Addresse in X auf das erste Element des Strings. => "H"  
; Ich möchte den Char "H" in D laden und einen Buchstaben weiter gehen.
; LDD 1,X+ postincrement i++
; LDD 1,+X preincrement ++i
; LDD 1,X- postdecrement i--
; LDD 1,-X predecrement --i;
; Ich lade den Wert an der Addresse X in D und incrementiere die Addresse in X um 1.
; In D ist nun der Char "H" und X zeigt auf "e"

; export Symbols
  XDEF to_upper;
  XDEF copy_string;
  XDEF copy_string_stack;

.init: Section

 ; X : Addresse des ersten Elements des Strings
string_durchlauf:
  LDAB 1,X+ ; Laden den Wert an der Addresse X in das B Register und Incrementieren X um 1;
  CMPB #$00; Vergleichen den Wert in B mit 0;
  BNE string_durchlauf; Wir springen zum Anfang wenn der Wert in B nicht 0 ist.
 
 ;Hier wissen wir, der String ist zuende, bzw. X zeigt auf das Ende des Strings.
  RTS
 ; X : Addresse des ersten Elements des Strings
string_durchlauf2:
  LDAB 1,X+ ; Laden den Wert an der Addresse X in das B Register und Incrementieren X um 1;
  CMPB #$00; Vergleichen den Wert in B mit 0;
  BEQ return; Wir beenden die Subroutine, wenn der Wert 0 ist.
  ; Hier wissen wir, dass der Char in B nicht 0 ist.
  ; Hier können wir jetzt tatsächlich etwas sinnvolles mit dem Char machen
  
 
 
  BRA string_durchlauf2;
return:
  RTS 


to_upper:
  LDAB 1,X+ ; Laden den Wert an der Addresse X in das B Register und Incrementieren X um 1;
  ;Guard Condition Starts here
  CMPB #$00; Vergleichen den Wert in B mit 0;
  BEQ return; Wir beenden die Subroutine, wenn der Wert 0 ist.
  ;Guard Condition Ends here
  ; Hier wissen wir, dass der Char in B nicht 0 ist.
  ; Hier können wir jetzt tatsächlich etwas sinnvolles mit dem Char machen
  ; Hier möchte ich prüfen ob es sich um einen Kleinbuchstaben handelt;
  CMPB #'a'; Muss # sein weil literal #
  BLT to_upper; Branch if lower. Signed. Also wenn der Wert in B kleiner ist als 'a'
  CMPB #'z'; Muss # sein weil literal #
  BGT to_upper; Branch if Higher. Signed. Also wenn der Wert in B größer ist als 'z'
  ; Hier haben wir einen Kleinbuchstaben im Register B
  ; Um aus dem Kleinbuchstaben einen Großbuchstaben zu machen, muss der Wert in B um 32 verkleinert werden
  ;1. Möglichkeit: Direkt abziehen
  SUBB #$20;
  ; SUBB #32
  ;2. Möglichkeit : Bit Flip durch XOR
  ;EORB %00100000
  ; EORB #$20
  ; Um an die Stelle X-1 speichern zu können
  ;STAB X-1; Theoretisch speichert das den Character an die Originale Stelle im Array (Does not work)
  DEX ; Decrementieren des X Registers um 1
  STAB X;
  INX; Incrementieren des X Registers um 1
  
  
 
 
  BRA to_upper; Wir springen immer zum Anfang unsere Funktion zurück
;return: Error: Dublicate Label
;  RTS

; X Register den Pointer auf den SRC String
; Y Register den Pointer auf den Target String
copy_string:
  LDAB X ; Laden den Wert an der Addresse X in das B Register
  CMPB #$00; Vergleichen den Wert in B mit 0;
  ; Ist der Wert Null haben wir das Ende des Strings erreicht.
  BEQ return_copy; Wir beenden die Subroutine, wenn der Wert 0 ist.
  
  MOVB 1,X+,1,Y+; IDX-IDX
  ; MOVB X,Y
  ; INX
  ; INY
  
  ; Gehen wieder zum Anfang um den nächsten Buchstaben zu kopieren
  BRA copy_string; 

; Function Tail  
return_copy:
; Dann steht unser x Register auf der 0. z.B. bei X+10, y Register steht bei Y+10
  MOVB X,Y; Kopieren der Null terminierung
  RTS

; Both Registers are de facto empty and we need to get our Variables from the Stack 
copy_string_stack:
; Function Head  
  ; Increased the SP by 2
  LEAS 2,+SP
  ;Load the Y Register Value from the Stack
  PULY;
  ;Load the X Register Value from the Stack
  PULX;
; Function Body  
loop:    
  LDAB X ; Laden den Wert an der Addresse X in das B Register
  CMPB #$00; Vergleichen den Wert in B mit 0;
  ; Ist der Wert Null haben wir das Ende des Strings erreicht.
  BEQ return_copy_stack; Wir beenden die Subroutine, wenn der Wert 0 ist.
  
  MOVB 1,X+,1,Y+; IDX-IDX
  ; MOVB X,Y
  ; INX
  ; INY
  
  ; Gehen wieder zum Anfang um den nächsten Buchstaben zu kopieren
  BRA loop; 

; Function Tail  
return_copy_stack:
; Dann steht unser x Register auf der 0. z.B. bei X+10, y Register steht bei Y+10
  MOVB X,Y; Kopieren der Null terminierung
  ; Before we can Return, we need to set the SP to the correct Value
  ; Because we pulled 2times and increased by 2, the SP needs to be decremented by 6;
  LEAS 6,-SP;
  RTS
  
  
  
 
 
 
 