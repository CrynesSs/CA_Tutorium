
	XDEF test128bitFunctions;


.data: Section
 additionStorage: DS.W 8
 multiplicationStorage: DS.W 8
 multTemp: DS.W 2
 i: DC.B 1
 
.const: Section
	  arr1: DC.W $0111, $1111, $1111, $1111, $1111, $1111, $1111, $1111;
	  arr2: DC.W $0111, $1111, $1111, $1111, $1111, $1111, $1111, $1111;  

.init: Section

 test128bitFunctions:
	 LDX #arr1;
	 LDY #arr2;
	 JSR add128bit;
	 RTS; 	


 ; x = Pointer to first  128 bit number (stored as an Array of 8 Words)
 ; y = Pointer to second 128 bit number (stored as an Array of 8 Words)
 add128bit:
 	;Check if there is an Overflow
	 CLRA;
	 CLRB;
	 ADDD X;
	 ADDD Y;
	 PSHC;
	 PULB;
	 ANDB #$01;
	 BNE overflow;
	 ; Offset so the LSB is done first
	 LDAB #14;
	 ABX;
	 ABY;
	 LDAB #6;
	 STAB i;
	 
halfAdder: 
	 CLRA;
	 CLRB;
	 ADDD 2,-X;
	 ADDD 2,-Y;
	 PSHD;
	 PSHC;

fullAdder: 
	 CLRA;
	 CLRB;
	 ; Add with Carry to D;
	 PULB;
	 ANDB #$01;
	 ADDD 2,-X;
	 ADDD 2,-Y;
	 PSHD;
	 PSHC;
	 DEC i;
	 LDAB i;
	 BEQ ret;
	 BRA fullAdder;
ret:
	 PULB; 
	 LDX #additionStorage;
	 ; Load the 128bit Number in the Storage;  
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 MOVW 2,SP+,2,X+;
	 RTS; 
 
overflow:
	 LDAB #$5A
	 STAB additionStorage;
	 RTS; 

clearMultiplicationStorage:
	PSHX;
	PSHD;
	LDD #0;
	LDX #multiplicationStorage;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	STD 2,X+;
	PULD;
	PULX;
	RTS; 
 
 ;Result could be up to 128bit
 ; x - first 64 bit Number - 4 Words
 ; y - second 64 bit Number - 4 Words
mul64bit:
	JSR clearMultiplicationStorage;
	LDAB #6;
	; Start with the lower words
	ABY;
	ABX;
	PSHY;
	PSHX;
	; Load the 16 bit values into D and Y;
	LDD Y;
	XGDY;
	LDD X;
	EMUL;
	LDX #multTemp; 
	
	
	
	
	
	
	
	
			


	

 
