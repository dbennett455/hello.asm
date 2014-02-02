; Hello World in linux assembly - David H. Bennett - dbennett@bensoft.com
; Feb 1st, 2014 - for fun

section  .data  ; pre-initialized data

        ; our name prompt
        yourNameMsg     db      'What is your name: '
        lenYourNameMsg  equ     $-yourNameMsg

        ; our hello message
        helloMsg        db      'Hello, '
        lenHelloMsg     equ     $-helloMsg

	; suffix
	afterNameMsg	db	'!'
	lenAfterNameMsg	equ	$-afterNameMsg

        ; a newline
        newLine         db      0xa

section  .bss   ; empty data block space

        yourName        resb    256		; Reserved bytes for name
        blenYourName	equ     $-yourName      ; Length of our name space

section  .text	; this is our program code

	global _start	; a global symbol
_start:			; tell linker where to start

	; linux sys_write (user input prompt)
	mov ecx, yourNameMsg	; pointer to message into counter
	mov edx, lenYourNameMsg ; length into data register
	call sys_write		; see function below

        ; read input from the user into our defined empty block space
        mov ecx, yourName       ; ptr to our block space into counter
        mov edx, blenYourName   ; length of empty space into data reg
        call sys_read		; see function below

	; write our greeting 
	mov ecx, helloMsg	; our greeting
	mov edx, lenHelloMsg	; length
	call sys_write

        ; line length (newline is delimeter)
        ; search for the newLine at the end of the input and place in edx
	cld			; clear the direction flag
	mov edi, yourName	; load dest idx with our collected data
        mov ecx, blenYourName	; length of input buffer into to counter
	mov al, [newLine]	; move  newline into 8-bit accumulator
        repne scasb		; repeat scan until ecx==0 or al found
        mov edx, blenYourName   ; load edx with the size of input buffer
        sub edx, ecx		; sub ecx remainder and we have line length
        sub edx, 1		; don't include the newline in length

	; write collected name
	; edx is computed length above
	mov ecx, yourName	; ptr to our block space
	call sys_write
	
	; write suffix
	mov ecx, afterNameMsg	; exclamation pt
	mov edx, lenAfterNameMsg
	call sys_write

	; final new line
	mov ecx, newLine
	mov edx, 1
	call sys_write

	jmp sys_exit

sys_read:
	; read input from the user into our defined block space
	; ecx should be loaded with data ptr
	; edx should be loaded with length
	mov eax, 0x3		; sys_read into accumulator
	mov ebx, 0x2		; stdin fd
	int 0x80		; linux syscall
	ret

sys_write:
	; write data to standard output
	; ecx should be loaded with data ptr
	; edx should be loaded with length
	mov eax, 0x4		; sys_write into accumulator
	mov ebx, 0x1		; file descriptor (stdout) into base
	int 0x80		; soft interrupt 80h makes linux syscall
	ret

sys_exit:
	; exit
	mov eax, 1		; sys_exit
	mov ebx, 0		; exit level
	int 0x80
