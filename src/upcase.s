; Upcase standard in and output to standard out
; upcase < file > upcased

section .bss
	Buffer: resb 1		; byte buffer

section .data

section .text
	global _start

_start:
Read:	
	mov eax, 3		; `sys_read` syscall
	mov ebx, 0		; Use stdin
	mov ecx, Buffer		; Read into buffer
	mov edx, 1		; Only read one byte
	int 0x80		; Make syscall

	cmp eax, 0		; Have we reached the end of the file?
	je Exit			; If so, exit

	cmp byte [Buffer], 0x61	; Is char below 'a'?
	jb Write		; If so, don't upcase

	cmp byte [Buffer], 0x7A	; Is char above 'z'?
	ja Write		; If so, don't upcase

	sub byte [Buffer], 0x20	; Subtract 0x20 from current byte to upcase it

Write:
	mov eax, 4		; `sys_read` syscall
	mov ebx, 1		; Use stdout
	mov ecx, Buffer		; Write byte from buffer
	mov edx, 1		; Only write one byte
	int 0x80		; Make syscall

	jmp Read		; Read next byte

Exit:
	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit
