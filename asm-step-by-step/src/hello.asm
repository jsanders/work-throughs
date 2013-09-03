; Simple program demonstrating INT 80H syscalls
;
; nasm -f elf -g -F stabs hello.asm
; ld -o hello hello.o

SECTION .data			; Initialized data section
Message: db "Hello, World", 0x0A
MessageLen: equ $-Message

SECTION .bss			; Uninitialized data section

SECTION .text			; Code section

global _start			; Entry point for ld

_start:
	mov eax, 4		; `sys_write` syscall
	mov ebx, 1		; FD 1 - stdout
	mov ecx, Message	; Message location
	mov edx, MessageLen	; Message length location
	int 0x80		; Make syscall

	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit
