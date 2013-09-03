; Upcase standard in and output to standard out
; upcase < file > upcased

section .bss
	BufferSize: equ 1024
	Buffer: resb BufferSize	

section .data

section .text
	global _start

_start:
Read:	
	mov eax, 3		; `sys_read` syscall
	mov ebx, 0		; Use stdin
	mov ecx, Buffer		; Read into buffer
	mov edx, BufferSize	; Read BufferSize bytes
	int 0x80		; Make syscall
	mov esi, eax		; Number of characters read in esi, for later

	cmp eax, 0		; Have we reached the end of the file?
	je Exit			; If so, exit

	mov ecx, esi		; Number of characters read in ecx
	mov ebp, Buffer		; Address of Buffer

Scan:
	dec ecx			; Decrement ecx
	cmp byte [ebp+ecx], 0x61; Is char below 'a'?
	jb Next			; If so, don't upcase

	cmp byte [ebp+ecx], 0x7A; Is char above 'z'?
	ja Next			; If so, don't upcase

	sub byte [ebp+ecx], 0x20; Subtract 0x20 from current byte to upcase it

Next:
	cmp ecx, 0		; Is ecx 0?
	jne Scan		; If not, keep scanning

Write:
	mov eax, 4		; `sys_read` syscall
	mov ebx, 1		; Use stdout
	mov ecx, Buffer		; Write byte from buffer
	mov edx, esi		; Write number of characters that were read
	int 0x80		; Make syscall
	jmp Read		; Get another buffer

Exit:
	mov eax, 1		; `exit` syscall
	mov ebx, 0		; Exit code 0
	int 0x80		; Exit
