title Base Converter
; Author: Josue C.
; Class: MAC-286
; Date 12/10/2016
.model small
.stack 4096
.386

.data
welcomeMsg 		db 09h, "Welcome to our base converter app, created by (Josue C)", 0dh, 0ah, "-> Insert the number (.) to quit: $"
baseMessage 	db 	" [+] base #$"
colon			db	": $"
maxInputCount 	dw ?
completeDigit 	dd 0
convertedBase 	dw ?
baseToConvert 	dw 2
digitCounter	db ?
currentDigitPosition dw ?

.code
extrn clrscr:proc

main proc

	mov		ax,	@data
	mov		ds,	ax
	
	call	clrscr
	
	mov		ah, 9h
	mov		dx, offset welcomeMsg
	int		21h

	mov		bx, 1				;	size of digits to enter
	mov		maxInputCount, 0	; initialize max input count
	whileInputLoop:	
		call	keyIn
		cmp 	bx, 0
		jz		breakFlag		; Breaks if bx is 0 which mean true
		
		inc		maxInputCount	; increment the digits inputed
		push 	dx
		breakFlag:
			cmp		bx, 0
	jnz	whileInputLoop
	
	call	newLine
	call 	newLine
	
	;		CONVERTS INPUT INTO NUMBER ###############################################
	;		NEEDS TO BE FIXED WHEN ENTERING MORE THAN 4 DIGITS
	mov		cx,	0
	stackIsNotEmpty:
		pop		dx
		call	inputToNumber
		inc		cx						; increment cx counter
		cmp 	cx, maxInputCount		; check if our cx counter is equal to max number
	jnz	stackIsNotEmpty
	
	;	COMPLETEDIGIT: digit inputed from keyboard
	
	; convert here
	loopBase:
		mov		ah, 9h
		mov		dx, offset baseMessage
		int		21h
		
		mov		ebx, completeDigit	
		mov		digitCounter, 0		; initializing digitCounter
		
		;mov		baseToConvert, 2	; to base 2
		
		;		PRINT BASE NUMBER ###############################################
		mov		dx, baseToConvert
		call	displayDigit

		;		PRINT COLON ###############################################
		mov		ah, 9h
		mov		dx,	offset colon
		int		21h
		
		;		PRINT NUMBER INTO BASE ###############################################
		whileConvertingBase:
			call	baseConverter
			push 	dx
			inc 	digitCounter
			cmp		eax, 0
		jnz whileConvertingBase
		
		mov		bx,	digitCounter
		mov		maxInputCount, bx
		
		mov		ecx, 0
		

		mov		currentDigitPosition, 0
		mov		cx, maxInputCount
		add		currentDigitPosition, cx		;	size of digits to print
		whileDigitsLoop:	
			pop		dx
			call	displayDigit
			
			dec		currentDigitPosition
			cmp		currentDigitPosition, 0
		jnz	whileDigitsLoop
		
		call	newLine
		;	INCREMENT BASE
		
		inc		baseToConvert
		cmp		baseToConvert, 10
	jnz	loopBase
	mov		ax, 4c00h
	int		21h
main endp

; ########################################
baseConverter proc
	mov 	edx, 0
	
	mov		eax, ebx
	mov		ecx, baseToConvert
	div		ecx
	
	
	mov		ebx, eax

	ret
baseConverter endp


; ########################################
displayDigit proc
	mov		ah, 6h
	add		dl, 30h			; Convert number into character
	int		21h
	
	ret
displayDigit endp

; ########################################
keyIn proc
	mov		ah, 1h
	int		21h
	sub 	al,	30h			; Convert ascii into decimal nunmber
	
	cmp		al,	-2
	jnz		continueFlag
	
	mov		bx, 0					; if it is equal to -2 which is '.' then break
	
	continueFlag:
		mov		dl,	al			; Move value to dl
	ret
keyIn endp

; ########################################
newLine proc
	mov		dl, 0ah			; Print new line
	mov		ah,	2h
	int		21h

	mov		dl, 0dh			; Print return carrie
	mov		ah,	2h
	int		21h	
	
	ret
newLine endp

; ########################################
invertDigits proc
	mov 	edx, 0
	
	mov		eax, ebx
	mov		ecx, 10
	div		ecx
	
	mov		ebx, eax
	ret
invertDigits endp


; ########################################
inputToNumber proc	
	mov		currentDigitPosition, cx	; initializing temp
	
	mov		al, 10
	mov		bl, dl
	
	cmp		cx, 0
	jz		firstDigit
	
	digitPositionLoop:
		mov		ax, 10
		mul		bx
		mov		ebx, eax
		dec		currentDigitPosition
		cmp		currentDigitPosition, 0
	jnz	digitPositionLoop
	
	inc		cx						;	decrement when multiplication
	cmp		cx, 0					; 	will always make it jump when it is not first digit
	jnz		afterFirstDigit
	
	firstDigit:
		inc		cx					;	decrement so it will be equalize
		mov		ax,	bx
		
	afterFirstDigit:
		add		completeDigit, eax
		dec		cx					;	increment
	
	ret
inputToNumber endp



end main
