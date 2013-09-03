; Utility procedures for hexdump program

SECTION .bss
	BufLen equ 16
	Buf resb BufLen

SECTION .data
	HexStr db "00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00"
	HexLen equ $-HexStr
	AsciiStr db " |................|", 0x0A
	AsciiLen equ $-AsciiStr
	FullLen equ $-HexStr
	Digits db "0123456789ABCDEF"

SECTION .text

GLOBAL ReadBuf, WriteBuf, PrintCurrentOffset

; ReadBuf: Reads BufLen bytes from stdin into Buf
; Returns: Number of bytes read in esi
; Modfies: esi, Buf
ReadBuf:	
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 3		; `sys_read` syscall
	mov ebx, 0		; Use stdin
	mov ecx, Buf		; Read into buffer
	mov edx, BufLen		; Read BufferSize bytes
	int 0x80		; Make syscall

	mov esi, eax		; Return number of characters read in esi

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

; WriteBuf: Write current line to console
WriteBuf:
	pusha

	mov eax, 4		; `sys_write` syscall
	mov ebx, 1		; Use stdout
	mov ecx, HexStr		; Write byte from buffer
	mov edx, FullLen	; Write number of characters that were read
	int 0x80		; Make syscall

	popa
	ret

; PrintCurrentHex: Print hex of character at offset into HexStr
; Input: offset in ecx
; Modifies: HexStr
PrintCurrentHex:
	pusha

	; Put current character in eax and ebx
	xor eax, eax		; First, clear eax
	mov al, byte [Buf+ecx]	; Now, get byte in al (thus eax)
	mov ebx, eax		; Copy to ebx

	; Isolate high nybble
	shr bl, 4			; Shift high nybble into low bits
	mov bl, byte [Digits+ebx]	; Look up the current char in Digits

	; Isolate low nybble
	and al, 0x0F			; Mask out low nybble
	mov al, byte [Digits+eax]	; Look up the current char in Digits

	; Offset into HexStr for high nybble should be ecx * 3:
	; 00 00 00
	; ^ byte 0, offset 0
	;    ^ byte 1, offset 3
	;       ^ byte 2, offset 6
	mov edx, ecx		; Copy current character count into edx
	shl edx, 1		; Multiply by 2
	add edx, ecx		; Complete multiplication by 3

	; Insert high and low nybbles at offset and offset+1 respectively
	mov byte [HexStr+edx], bl	; Write high nybble char
	mov byte [HexStr+edx+1], al	; Write low nybble char

	popa
	ret

; PrintCurrentAscii: Put char or period in AsciiStr
; Input: offset in ecx
; Modifies: AsciiStr
PrintCurrentAscii:
	pusha

	; Get byte from Buf
	xor eax, eax		; First, clear eax
	mov al, byte [Buf+ecx]	; Now, get byte in al (thus eax)

	cmp eax, 0x20		; Is char below 0x20?
	jb .replace		; If so, replace

	cmp eax, 0x7A		; Is char above 0x7E?
	ja .replace		; If so, replace

	jmp .update		; Otherwise, just print it

.replace:
	mov al, 0x2E		; Put a period character in al

.update:
	mov byte [AsciiStr+ecx+2], al	; Print char into AsciiStr

	popa
	ret

; PrintCurrentOffset: Print byte at given offset 
; Input: Offset in ecx
; Modifies: HexStr, AsciiStr
PrintCurrentOffset:
	pusha

	call PrintCurrentHex
	call PrintCurrentAscii

	popa
	ret
