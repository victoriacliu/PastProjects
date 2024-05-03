; String Primitives and Macros     (proj6_liuv.asm)

; Author: Victoria Liu
; Last Modified: 12/7/2023
; OSU email address: liuv@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   6              Due Date: 12/10/2023
; Description: This program will implement macros for string processing. 
;				The program will read an input as string and convert to numeric form for 10 valid integers. There will be an error message
;				if the user enters nothing, enter a nnumber too large, or enters a non-digit. Then the program will display the integers, 
;				sum, and their truncated average. 

INCLUDE Irvine32.INC
MAX				= 32
INPUTLIMIT		= 10

;--------------------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Prompts the user to enter an integer and puts integer into memory.  
;
; Receives:
; prompt = prompt message
; string = empty string
; len = string length
; byte = bytes in string
;
; returns: 
; String with user entered integers and number of bytes in the string.
;--------------------------------------------------------------------------------------------------------------------------
mGetString		MACRO prompt, string, len, bytes
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
  
	MOV		EDX, prompt
	CALL	WriteString
	MOV		ECX, len
	MOV		EDX, string
	CALL	ReadString
	MOV		EDI, bytes
	MOV		[EDI], EAX

	POP		EDI
	POP		EDX
	POP		ECX
	POP		EAX
ENDM

;--------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints the string

; Receives:
; string = string that is to be printed
;
; returns: 
; Displays the string.
;--------------------------------------------------------------------------------------------------------------------------

mDisplayString		MACRO string
	PUSH	EAX
	PUSH	EDX

	MOV		EDX, string
	CALL	WriteString

	POP		EDX
	POP		EAX
ENDM


.data

inputString		BYTE	?
outputString	BYTE	100 DUP(?)
numList			SBYTE	100 DUP(?)
sLength			DWORD	?
changedInt		SDWORD	?
counter			DWORD	?
numSum			SDWORD	?
numAvg			SDWORD  ?

;prompts and messages
prompt			BYTE	"Please enter a signed number: ", 0
errorMsg		BYTE	"ERROR: You did not enter a signed number or your number was too big.",13,10, "Please try again: ", 13, 10, 0
NumListMsg		BYTE	"You entered the following numbers: ",13,10,0
SumMsg			BYTE	"The sum of these numbers is: ",0
AvgMsg			BYTE	"The truncated average is: ",0
spacer			BYTE	" ", 13, 10, 10, 0
intro1			BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 13, 10, "Written By: Victoria Liu", 13, 10, 10, 0
intro2			BYTE	"This program will implement macros for string processing.", 13, 10
				BYTE	"The program will read an input as string and convert to numeric form for 10 valid integers.", 13, 10
				BYTE	"There will be an error message if the user enters nothing, enter a number too large, or enters a non-digit.", 13, 10
				BYTE	"Then the program will dislpay the integers, sum, and their truncated average.", 13, 10, 10, 0
goodBye			BYTE	"Thanks for playing!",13,10,0


.code
main PROC

;title and instructions
	mDisplayString		OFFSET intro1
	mDisplayString		OFFSET intro2
  
;user enters numbers  
	MOV		counter, INPUTLIMIT
	MOV		EDI, OFFSET numList
_promptNum:
	PUSH	OFFSET errorMsg		;28
	PUSH	OFFSET changedInt	;24
	PUSH	OFFSET prompt		;20
	PUSH	OFFSET inputString	;16
	PUSH	MAX					;12
	PUSH	OFFSET sLength		;8
	CALL	ReadVal
; put int in list 
	MOV		EAX, changedInt
	MOV		[EDI], EAX
	ADD		EDI, 4
	DEC		counter
	CMP		counter, 0
	JG		_promptNum
	mDisplayString		OFFSET spacer

;display the integers and convert int to string 
	mDisplayString		OFFSET NumListMsg
	MOV		ESI, OFFSET numList
	MOV		counter, 10
_displayAllNums:
	MOV		EAX, [ESI]
	MOV		changedInt, EAX		
	PUSH	OFFSET	outputString	
	PUSH	changedInt				
	CALL	WriteVal
	MOV		AL, 32
	CALL	WriteChar
	ADD		ESI, 4
	DEC		counter
	CMP		counter, 0
	JG		_displayAllNums
	mDisplayString		OFFSET spacer

;calculate and display the sum
	MOV		ESI, OFFSET numList
	MOV		EDI, OFFSET numSum
	MOV		counter, 9
	MOV		EAX, [ESI]
_Sum:
	ADD		ESI, 4
	MOV		EBX, [ESI]
	ADD		EAX, EBX
	DEC		counter
	CMP		counter, 0
	JG		_Sum
	MOV		[EDI], EAX
	mDisplayString		OFFSET SumMsg
	PUSH	OFFSET outputString
	PUSH	numSum
	CALL	WriteVal
	mDisplayString		OFFSET spacer

;calculate and display the average
	MOV		EAX, numSum
	CDQ
	MOV		EBX, 10
	IDIV	EBX
	MOV		numAvg, EAX
	mDisplayString		OFFSET AvgMsg
	PUSH	OFFSET outputString
	PUSH	numAvg
	CALL	WriteVal
	mDisplayString		OFFSET spacer

;farewell
	mDisplayString		OFFSET goodBye

	Invoke ExitProcess, 0	; exit to operating system
main ENDP

;---------------------------------------------------------------------------------
; Name: ReadVal
;
; Invokes the mGetString to get user input in form of string 
; and converts to numeric value SDWORD and validates user input
; (no letters, symbols, etc.) It will store one value in a memory variable.
;
; Receives:
; [EBP + 28] = errorMsg
; [EBP + 24] = changedInt
; [EBP + 20] = prompt
; [EBP + 16] = inputString
; [EBP + 12] = MAX
; [EBP + 8] = sLength
; 
; returns: 
; changedInt with new integer value (output parameter, by reference)
; ---------------------------------------------------------------------------------

ReadVal PROC
	LOCAL	signFlag: DWORD, multiply: DWORD			
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	MOV		signFlag, 0
	MOV		multiply, 1									
	mGetString		[EBP + 20], [EBP + 16], [EBP + 12], [EBP + 8]
 
; restarts and clears flags & new int
_outerloop:				
	MOV		multiply, 1
	MOV		signFlag, 0
	MOV		EDX, [EBP + 8]
	MOV		ECX, [EDX]
	MOV		ESI, [EBP + 16]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP + 24]
	MOV		EAX, 0
	MOV		[EDI], EAX
	MOV		EBX, multiply

;convert ASCII to numeric value
_innerloop:
	STD
	LODSB
	CMP		AL, 48				;48 ascii = 0 any lower is operator signs
	JL		_is_neg_sign
	CMP		AL, 57				;57 ascii = 9, any greater is invalid characters
	JG		_invalid
	sub		AL, 48				
	MOV		BL, AL
	MOV		EAX, 0			
	MOVSX	EAX, BL
	MOV		EBX, multiply		
	MUL		EBX
	JC		_invalid				
	ADD		EAX, [EDI]			
	MOV		[EDI], EAX
 _proceed:
	DEC		ECX
	CMP		ECX, 0
	JE		_sign
	MOV		EAX, multiply
	MOV		EBX, 10
	MUL		EBX
	MOV		multiply, EAX
	JMP		_innerloop

  ; check if there is neg sign
_is_neg_sign:
	CMP		ECX, 1
	JNE		_invalid
	CMP		AL, 45
	JNE		_is_pos_sign
	MOV		signFlag, 1
	JMP		_proceed

  ;check if there is pos sign
_is_pos_sign:
	CMP		AL, 43
	JNE		_invalid
	MOV		signFlag, 0
	JMP		_proceed

;checks if it's min and restarts loop if not
_invalid:
	CMP		EAX, -2147483648			
	JE		_is_min													;minimum num in range is  -2147483648
	mGetString		[EBP + 28], [EBP + 16], [EBP + 12], [EBP + 8]
	JMP		_outerloop

_sign:
	CMP		signFlag, 0
	JE		_done
	MOV		EAX, [EDI]
	neg		EAX
	MOV		[EDI], EAX
	JMP		_done
  
_is_min:
	MOV		[EDI], EAX

; end proc
_done:
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		24
ReadVal ENDP

;---------------------------------------------------------------------------------
; Name: WriteVal
;
; Converts a numeric SDWORD to a string of ASCII digits and 
; invokes mDisplayString to print the ASCII representation.
;
; Receives: 
; [EBP + 8] = numList
; [EBP + 12] = outputString
; 
; returns: 
; Displays numeric values as ASCII in string
; ---------------------------------------------------------------------------------

WriteVal PROC
	LOCAL	divide: DWORD, quotient: DWORD, signFlag: DWORD 		
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	;set local variables
	MOV		signFlag, 0
	MOV		divide, 10
	MOV		ESI, [EBP + 8]
	MOV		EDI, [EBP + 12]
	MOV		quotient, ESI
	MOV		ECX, 1   
	CLD

; push a null byte so string will end after correct number of values stored
	MOV		EAX, 0
	PUSH	EAX

_saveSign:
	MOV		EAX, ESI
	CMP		EAX, 0
	JGE		_convertInt

; check if int is neg, set signFlag
	MOV		signFlag, 1

; convert integer to string by dividing integer by 10, storing remainder in a string. When value is 0, print string in reverse order.
_convertInt:
	MOV		EAX, quotient
	CDQ
	MOV		EBX, divide
	IDIV	EBX

;save quotient
	MOV		quotient, EAX

;check if remainder is neg
	MOV		EAX, EDX
	CMP		EAX, 0
	JGE		_Ascii
	NEG		EAX

;ADD 0 ascii (48) to change to ascii
_Ascii:
	ADD		EAX, 48
	PUSH	EAX			
	INC		ECX

;check if value is 0
	MOV		EAX, quotient
	CMP		EAX, 0
	JNE		_convertInt

;check neg sign to ADD
	CMP		signFlag, 1
	JNE		_storeAscii
	MOV		EAX, 45
	STOSB
  
;Add ascii values to string list
_storeAscii:  
	POP		EAX
	STOSB
	DEC		ECX
	CMP		ECX, 0
	JG		_storeAscii
	mDisplayString		[EBP + 12]
	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	RET		8
WriteVal ENDP

END main