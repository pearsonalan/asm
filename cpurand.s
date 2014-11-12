; cpurand.s
;  Sample program to get random numbers from the cpu random number generator
;  64 bit version

;compile with:
;   yasm -f macho64 cpurand.s
;   ld -e main -arch x86_64 cpurand.o -o cpurand
;
; run via ./cpurand


	segment .data

msg:	db	"Hello World", 0xa, 0
len:	equ	$ - msg

	segment .text
	global main


;
; invoke the write system call
;
; input registers:
;	rsi   - string to write
;	rdx   - length of string
;
; registers clobbered:
;	rax
;	rdi
;

write:
	mov	rax, 0x2000004		; write call (see SYSCALL_CONSTRUCT_UNIX)
	mov	rdi, 1			; file descriptior (stdout)
	syscall				; call write
	ret


;
; convert the value in rax to text
;
; input registers:
;    rax - number to convert
;    rdi - pointer to buffer
;
; output registers:
;    rcx - length of output
;
; clobbered registers:
;    rbx
;    rdx
;

	global ltoa

ltoa:
	mov	rbx, 10			; rbx is base of division
	xor	rcx, rcx		; clear rcx this counts output bytes
.loop0:
	xor	rdx, rdx		; clear rdx.  dividend is rdx:rax
	idiv	rbx			; divide by rbx
	add	rdx, '0'		; rdx is remainder. convert to ascii by adding '0'
	mov	[rdi+rcx], rdx		; copy to destination
	inc	rcx			; increment count of outputs
	cmp	rax, 0			; test if rax is 0 now
	jnz	.loop0			; loop if not

	lea	rsi, [rdi+rcx]
	dec	rsi
.loop1:
	mov	al, [rsi]
	mov 	ah, [rdi]
	mov	[rdi], al
	mov	[rsi], ah
	dec	rsi
	inc	rdi
	cmp	rsi, rdi
	jg	.loop1

	ret


;
; invoke the exit system call
;
; input registers:
;	rdi   - exit code
;
; registers clobbered:
;	rax
;

exit:
	mov	rax, 0x2000001		; exit call
	syscall				; call exit
	ret


main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32

	rdrand	eax
	mov	rdi, rsp
	call	ltoa

	mov	rsi, rsp
	mov	byte [rsp+rcx], 0xa
	mov	rdx, rcx		; length of string
	inc	rdx
	call	write


	mov	rdi, 0			; return code
	call	exit

	leave
	ret
