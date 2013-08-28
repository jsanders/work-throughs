; SHA1 implementation

SECTION .bss
	Len equ 64		; 64-byte buffer or 64 32-bit extra words
	Buf resb Len		; Either 64 bytes or 16 32-bit words
	ExtraWords resd Len	; 64 more 32-bit words, for total of 80

	TempState resd 5	; Temporary state for chunk

	HexStrLen equ 41	; 20 bytes at 2-chars-per-byte, plus newline
	HexStr resb HexStrLen	; Output hex string

SECTION .data
	Words equ Buf		; Alias to region starting at Buf with 80 32-bit words
	State dd  0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0
	HexDigits db "0123456789abcdef"

SECTION .text			; Code section

; Read: Reads Len bytes from stdin into Buf
; Returns: Number of bytes read in esi
; Modfies: esi, Buf
Read:	
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 3		; `sys_read` syscall
	mov ebx, 0		; Use stdin
	mov ecx, Buf		; Read into buffer
	mov edx, Len		; Read BufferSize bytes
	int 0x80		; Make syscall

	mov esi, eax		; Return number of characters read in esi

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

; PopulateHexStrCurrent: Print hex of character at offset into HexStr
; Input: offset in ecx
; Modifies: HexStr
PopulateHexStrCurrent:
	push eax
	push ebx

	; Put current character in eax and ebx
	xor eax, eax		; First, clear eax
	mov al, byte [State+ecx]; Now, get byte in al (thus eax)
	mov ebx, eax		; Copy to ebx

	; Isolate high nybble
	shr bl, 4			; Shift high nybble into low bits
	mov bl, byte [HexDigits+ebx]	; Look up the current char in HexDigits

	; Isolate low nybble
	and al, 0x0F			; Mask out low nybble
	mov al, byte [HexDigits+eax]	; Look up the current char in HexDigits

	; Offset into HexStr for high nybble should be ecx * 4:
	; 000000...
	; ^ byte 0, offset 0
	;   ^ byte 1, offset 2
	;     ^ byte 2, offset 4
	; Insert high and low nybbles at offset and offset+1 respectively
	mov byte [HexStr+(ecx*2)], bl	; Write high nybble char
	mov byte [HexStr+(ecx*2)+1], al	; Write low nybble char

	pop ebx
	pop eax
	ret

; PopulateHexStr: Put State in HexStr
; Modifies: HexStr
PopulateHexStr:
	push ecx

	mov ecx, 0
.loop:
	call PopulateHexStrCurrent

	inc ecx
	cmp ecx, 20			; State has 20 bytes
	jb .loop

	mov byte [HexStr+HexStrLen-1], 0x0A	; Add newline

	pop ecx
	ret

; WriteState: Writes State to stdout
WriteState:	
	push eax
	push ebx
	push ecx
	push edx

	call PopulateHexStr

	mov eax, 4		; `sys_write` syscall
	mov ebx, 1		; Use stdout
	mov ecx, HexStr		; Write from State
	mov edx, HexStrLen	; State is 5 words, so 20 bytes
	int 0x80		; Make syscall

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

; Exit: Exit from the program
; Input: Exit code in esi
Exit:
	mov eax, 1		; `exit` syscall
	mov ebx, esi		; Exit code 0
	int 0x80		; Exit

; ConvertEndian: Convert Words to opposite endianness
; Input: Address of buffer to convert in ebp, size of buffer in words in esi
; Modifies: Words
ConvertEndian:
	push eax
	push ecx

	mov ecx, 0
.loop:
	mov eax, dword [ebp+(ecx*4)]	; Load current word
	bswap eax			; Convert to little-endian
	mov dword [ebp+(ecx*4)], eax	; Write little-endian value

	inc ecx
	cmp ecx, esi			; 16 words to process
	jb .loop

	pop ecx
	pop eax
	ret

; PopulateExtraWords: Populate words 16-79 based on values of words 0-15
; Modifies: ExtraWords
PopulateExtraWords:
	push eax
	push ecx

	xor ecx, ecx		; Clear ecx, will be used as counter
.loop:
	mov eax, dword [ExtraWords+(ecx*4)-12]	; Get value 3 words before current
	xor eax, dword [ExtraWords+(ecx*4)-32]	; Xor with value 8 words before current
	xor eax, dword [ExtraWords+(ecx*4)-56]	; Xor with value 14 words before current
	xor eax, dword [ExtraWords+(ecx*4)-64]	; Xor with value 16 words before current
	rol eax, 1
	mov dword [ExtraWords+(ecx*4)], eax		; Write the value to current index

	inc ecx
	cmp ecx, Len	; Handled 64 words?
	jb .loop	; If not, loop

	pop ecx
	pop eax
	ret

; PopulateTempState: Copy current State values into TempState
; Modifies: TempState
PopulateTempState:
	push eax

	mov eax, dword [State]
	mov dword [TempState], eax
	mov eax, dword [State+4]
	mov dword [TempState+4], eax
	mov eax, dword [State+8]
	mov dword [TempState+8], eax
	mov eax, dword [State+12]
	mov dword [TempState+12], eax
	mov eax, dword [State+16]
	mov dword [TempState+16], eax

	pop eax
	ret

; UpdateTempState: Update state memory based on current round values
; Input: Round permutation f in eax, round constant k in ebx, current word index in ecx
; Modfies: TempState
UpdateTempState:
	push eax
	push ebx
	push ecx
	push edx

	mov edx, dword [TempState]		; First word of state (h0)
	rol edx, 5			; temp = h0 leftrotate 5
	add edx, eax			; temp = (h0 leftrotate 5) + f
	add edx, dword [TempState+16]	; temp = (h0 leftrotate 5) + f + h4
	add edx, ebx			; temp = (h0 leftrotate 5) + f + h4 + k
	add edx, dword [Words+(ecx*4)]	; temp = (h0 leftrotate 5) + f + h4 + k + current word

	mov eax, dword [TempState+12]
	mov dword [TempState+16], eax	; h4 = h3

	mov eax, dword [TempState+8]
	mov dword [TempState+12], eax	; h3 = h2

	mov eax, dword [TempState+4]
	rol eax, 30			; h1 leftrotate 30
	mov dword [TempState+8], eax	; h2 = h1 leftrotate 30

	mov eax, dword [TempState]
	mov dword [TempState+4], eax	; h1 = h0

	mov dword [TempState], edx		; h0 = temp

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

Round1:
	push eax
	push ebx
	push ecx

	mov ecx, 0			; Use ecx as counter, start at 0 for round 1
.loop:
	mov eax, dword [TempState+4]	; Start with second word of State (h1)
	mov ebx, eax			; And copy it for later use

	and eax, dword [TempState+8]	; h1 & h2
	not ebx
	and ebx, dword [TempState+12]	; ~h1 & h3
	or eax, ebx			; f = (h1 & h2) | (~h1 & h3)
	mov ebx, 0x5A827999		; Round constant k
	call UpdateTempState

	inc ecx
	cmp ecx, 20			; Round 1 from 0 to 19 
	jb .loop

	pop ecx
	pop ebx
	pop eax
	ret

Round2:
	push eax
	push ebx
	push ecx

	mov ecx, 20			; Use ecx as counter, start at 20 for round 2
.loop:
	mov eax, dword [TempState+4]	; Start with second word of TempState (h1)

	xor eax, dword [TempState+8]	; h1 ^ h2
	xor eax, dword [TempState+12]	; h1 ^ h2 ^ h3
	mov ebx, 0x6ED9EBA1		; Round constant k
	call UpdateTempState

	inc ecx
	cmp ecx, 40			; Round 2 from 20 to 39 
	jb .loop

	pop ecx
	pop ebx
	pop eax
	ret

Round3:
	push eax
	push ebx
	push ecx

	mov ecx, 40			; Use ecx as counter, start at 40 for round 3
.loop:
	mov eax, dword [TempState+4]	; Start with second word of TempState (h1)
	mov ebx, eax			; And a copy of it
	mov edx, dword [TempState+8]	; Also get the third word of TempState (h2)
	mov ebp, dword [TempState+12]	; Also get the fourth word of TempState (h3)

	and eax, edx			; h1 & h2
	and ebx, ebp			; h1 & h3
	and edx, ebp			; h2 & h3 
	or eax, ebx			; (h1 & h2) | (h1 & h3)
	or eax, edx			; (h1 & h2) | (h1 & h3) | (h2 & h3)
	mov ebx, 0x8F1BBCDC		; Round constant k
	call UpdateTempState

	inc ecx
	cmp ecx, 60			; Round 3 from 40 to 59 
	jb .loop

	pop ecx
	pop ebx
	pop eax
	ret

Round4:
	push eax
	push ebx
	push ecx

	mov ecx, 60			; Use ecx as counter, start at 60 for round 4
.loop:
	mov eax, dword [TempState+4]	; Start with second word of TempState (h1)

	xor eax, dword [TempState+8]	; h1 ^ h2
	xor eax, dword [TempState+12]	; h1 ^ h2 ^ h3
	mov ebx, 0xCA62C1D6		; Round constant k
	call UpdateTempState

	inc ecx
	cmp ecx, 80			; Round 4 from 60 to 79 
	jb .loop

	pop ecx
	pop ebx
	pop eax
	ret

; UpdateState: Add current TempState into State
; Modifies: State
UpdateState:
	push eax

	mov eax, dword [TempState]
	add dword [State], eax
	mov eax, dword [TempState+4]
	add dword [State+4], eax
	mov eax, dword [TempState+8]
	add dword [State+8], eax
	mov eax, dword [TempState+12]
	add dword [State+12], eax
	mov eax, dword [TempState+16]
	add dword [State+16], eax

	pop eax
	ret

; HandleFinalChunk: Do the bookkeeping required of the final, partial, chunk
; Input: Chunk size in esi
; Modifies: Buf
HandleFinalChunk:
	push eax
	push ecx

	mov eax, esi			; Copy number of bytes read into eax
	
	; FIXME: There is an unhandled case right now, when the last chunk read
	; is more than 55 bytes. In this case, an entire blank chunk is needed,
	; to accomodate one pad byte and the 8 length bytes, and I don't want to
	; deal with that yet, so I just crash instead
	cmp eax, 55
	jbe .continue
	mov esi, 1
	call Exit

.continue:
	mov byte [Buf+eax], 0x80	; Initial pad byte

	; Determine how much zero-pad is needed for chunk
	; This is the 64-byte chunk size, minus 8 bytes for the length
	; minus the number of bytes read, minus 1, for the initial 0x80 pad
	mov ecx, 55
	sub ecx, eax	; Number of pad bytes
.padloop:
	cmp ecx, 0
	jz .padloopdone
	mov byte [Buf+eax+ecx+1], 0
	dec ecx
	jmp .padloop

.padloopdone:
	; FIXME: This should be the full message length and should be 8 bytes long.
	; This will only work if the whole message is only one chunk long.
	shl eax, 3	; Length in bits
	xchg ah, al	; Convert to big-endian
	mov word [Buf+62], ax

	pop ecx
	pop eax
	ret

GLOBAL _start			; Entry point for ld
_start:
	call Read

	cmp esi, Len		; Did we read a full chunk?
	je FullChunk		; If so, calculate its state immediately

	; If we didn't get a full chunk, this is the final chunk and we need to do some bookkeeping
	call HandleFinalChunk

FullChunk:
	; Convert Words to little-endian
	mov ebp, Words
	mov esi, 16
	call ConvertEndian

	call PopulateExtraWords
	call PopulateTempState
	call Round1
	call Round2
	call Round3
	call Round4
	call UpdateState

	; Convert State to big-endian
	mov ebp, State
	mov esi, 5
	call ConvertEndian

	call WriteState

	mov esi, 0
	call Exit
