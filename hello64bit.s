
; yasm -f macho64 hello64bit.s
; ld -e _start -arch x86_64 hello64bit.o -o hello64bit
;as -arch x86_64 hello64bit.s -o hello64bit.o
;ld -e _start -arch x86_64 hello64bit.o -o hello64bit

        segment .data
msg:    db "Hello, there world!",0xa,0    ; ascii string to be printed
len:    equ $-msg

        segment .text           ; text section
        global  start          ; declare _start as global symbol for the linker to find

start:
        mov rax, 0x2000004      ; write call (see SYSCALL_CONSTRUCT_UNIX)
        mov rdi, 1          ; file descriptior (stdout)
        lea rsi, [msg wrt rip]  ; string to print
        mov rdx, len        ; length of string
        syscall             ; call write

        mov rax, 0x2000001          ; exit call
        mov rdi, 0          ; return code
        syscall             ; call exit


