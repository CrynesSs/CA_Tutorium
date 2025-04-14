; export symbols
  XDEF delay_500ms;
  XDEF add2zahlen;
; import symbols
  XREF IMAX
; RAM: Variable data section
.data: SECTION                          ; (Not used here, count variable i is put in register)

; ROM: Constant data
.const:SECTION                          ; (Not used here)

; ROM: Code section
.init: SECTION 

delay_500ms:
        LDX  #IMAX                      ; Delay loop to control toggle Frequency IMAX=2048
waitO:  LDY  #IMAX                      ; (Uses two nested counter loops with registers X and Y)
        ; DBNE braucht 3 CPU Cycles ausgeführt zu werden
waitI:  DBNE Y, waitI                   ; --- Decrement Y and branch to waitI if not equal to 0
        DBNE X, waitO                   ; --- Decrement X and branch to waitO if not equal to 0 
        RTS 

add2zahlen:
  NOP;
  RTS        
  
