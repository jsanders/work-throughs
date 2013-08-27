; Template for playing around with stuff easily

SECTION .bss
SECTION .data

SECTION .text			; Code section
global _start			; Entry point for ld

_start:
	; Stuff begins
	; Stuff ends

	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit
