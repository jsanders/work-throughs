; Dump file as 16-bytes of hex per line
; hexdump < <input file>

SECTION .bss

SECTION .data

SECTION .text

EXTERN ReadBuf, WriteBuf, PrintCurrentOffset
GLOBAL _start

_start:
ReadLine:
	call ReadBuf
	cmp esi, 0		; Have we reached the end of the file?
	je Exit			; If so, exit

	xor ecx, ecx		; Clear ecx
ScanLine:
	call PrintCurrentOffset

	; Go to next character and see if we're done
	inc ecx			; Increment line string pointer
	cmp ecx, esi		; Compare with number of chars
	jb ScanLine		; Loop back if ecx is <= number of chars

	call WriteBuf
	jmp ReadLine		; Get another buffer

Exit:
	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit
