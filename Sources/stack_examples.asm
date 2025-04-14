
	XDEF exampleUsage;
	
	; From string_util.asm 
    XREF to_upper,copy_string, copy_string_stack;

; RAM: Variable data section
.data: SECTION                          ; (Not used here, count variable i is put in register)  
    string: DS.B 16  ; Test String             . Ist nicht Null terminiert
    copytarget: DS.B 16;
; ROM: Constant data
.const:SECTION                          ; (Not used here)
    rom_string: DC.B "Hello World!1!",0
; ROM: Code section
.init: SECTION  

exampleUsage:
		; Example Call copy_string
		; **********************************************
		PSHX; Push the X Register Content onto the Stack
        PSHY; Push the Y Register Content onto the Stack
        ; When using any Push, the Stackpointer decrements by that byte amount
        ; For Example if we push X, SP is decremented by 2.
        ; Source ist im X Register
        LDX #rom_string
        ; Target ist im Y Register
        LDY #string
        ; Aufruf der Subroutine
        JSR copy_string;
        ;Bring the Variables from before the function call back
        PULY; Pull the Y Register Value Back from the Stack;
        PULX; 
        ; **********************************************
        
        ;Example Call copy_string_stack
        ; **********************************************
        PSHX;
        PSHY;
        ; Source ist im X Register
        LDX #string
        ; Target ist im Y Register
        LDY #copytarget
        ; Push the Value in X to the Stack
        PSHX;
        ; Push the Value in Y to the Stack
        PSHY;
        ; Aufruf der Subroutine
        ; Return Address is written to the Stack
        JSR copy_string_stack;
        ;We will land here after Subroutine Returns.
        ; We need to reset the SP to the correct position to get our original Variables back
        LEAS 4,+SP;
        
        ;Bring the Variables from before the function call back
        PULY; Pull the Y Register Value Back from the Stack;
        PULX;
        ; **********************************************
        
        ; Example Call to_upper
        ; **********************************************
        ; Schreiben die Addresse des neu kopierten Strings in das X Register
        LDX #copytarget;
        ; Call the to_upper Function.
        JSR to_upper;
        ; **********************************************
        RTS