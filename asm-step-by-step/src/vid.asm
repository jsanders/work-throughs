; Simple text-based video using a buffer and `write` syscall

SECTION .data
	EOL		equ 0x0a
	SPACE	equ 0x20
	HBAR	equ 0xc4				; Replacement for unprintable characters

	Reset db 27,"[2J",27,"[01;01H"	; Escape sequence for clearing screen
	ResetLen equ $-Clear
	
SECTION .bss
	COLS	equ 81					; Line length + 1 for EOL
	ROWS	equ 25					; Number of lines
	VidBuf	resb COLS*ROWS			; Buffer for our screen

SECTION .text
GLOBAL _start

%macro WriteStdout 2	; %1 = Address of buffer to write; %2 = Length of buffer
	pushad
	mov eax, 4			; `write`
	mov ecx, %1			; the buffer
	mov edx, %2			; of this length
	mov ebx, 1			; to stdout
	int 0x80
	popad

; Clear the text buffer with spaces
; In: Nothing
; Returns: Nothing
; Modifies: VidBuf, DF
ClearVid:
	push eax
	push ecx
	push edi
	cld					; Clear DF
	mov al, SPACE		; Space char to "clear" buf with
	mov edi, VidBuf		; Destination is the video buffer
	mov ecx, COLS*ROWS	; Amount to clear
	rep stosb			; Print chars into the buffer

	; Buffer is full of spaces, re-insert newlines
	mov edi, VidBuf		; Point destination back to buffer
	mov ecx, ROWS		; Repeat for each row
.printEol:
	add edi, COLS-1		; Move to end of current row
	mov byte [edi], EOL	; Replace with EOL character
	loop .printEol

	pop edi
	pop ecx
	pop eax
	ret

; Write a string into a text buffer aat 1-based x,y position
; In: Address of string in esi
;	  X-position in ebx
;	  Y-position in eax
;	  Number of chars in ecx
; Returns: Nothing
; Modifies: VidBuf, DF
WriteStr:
	push eax
	push ebx
	push ecx
	push edi
	cld				; Clear DF
	mov edi, VidBuf	; Write to VidBuf

	; Adjustments to make up for 1-based positions
	dec eax
	dec ebx

	; Determine Y offset
	mov ah, COLS
	mul ah			; Multiply al by ah
