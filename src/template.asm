; Template for playing around with stuff easily

SECTION .data			; Initialized data section
Snippet db "KANGAROO"

SECTION .text			; Code section

global _start			; Entry point for ld

_start:
	; Stuff begins
	mov eax, 0x1c71c4cb
	mov edx, 0x47
	mov ebx, 0x12345678
	div ebx
	; Stuff ends

	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit

SECTION .bss			; Uninitialized data section
