; cpuid64.s
;  Sample program to extract the processor Vendor ID
;  64 bit version

;compile with:
;   yasm -f macho64 cpuid64.s
;   ld -e main -arch x86_64 cpuid64.o -o cpuid64
;
; run via ./cpuid


        segment .data

output:                 db      "The processor Vendor ID is 'xxxxxxxxxxxx'", 0xa, 0xa
                        db      "Output of CPUID(01h):", 0xa, 0
output_len:             equ     $ - output


rax_string:             db      "rax: ",0
rax_string_len:         equ     $ - rax_string

rbx_string:             db      "rbx: ",0
rbx_string_len:         equ     $ - rbx_string

rcx_string:             db      "rcx: ",0
rcx_string_len:         equ     $ - rcx_string

rdx_string:             db      "rdx: ",0
rdx_string_len:         equ     $ - rdx_string

        segment .text

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
        mov     rbx, 10                 ; rbx is base of division
        xor     rcx, rcx                ; clear rcx this counts output bytes
.loop0:
        xor     rdx, rdx                ; clear rdx.  dividend is rdx:rax
        idiv    rbx                     ; divide by rbx
        add     rdx, '0'                ; rdx is remainder. convert to ascii by adding '0'
        mov     [rdi+rcx], rdx          ; copy to destination
        inc     rcx                     ; increment count of outputs
        cmp     rax, 0                  ; test if rax is 0 now
        jnz     .loop0                  ; loop if not

        lea     rsi, [rdi+rcx]
        dec     rsi
.loop1:
        mov     al, [rsi]
        mov     ah, [rdi]
        mov     [rdi], al
        mov     [rsi], ah
        dec     rsi
        inc     rdi
        cmp     rsi, rdi
        jg      .loop1

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
;    rax
;    rbx
;    rdx
;    rdi
;

        global ltoah
ltoah:
        mov     rbx, 16                 ; rbx is base of division
        xor     rcx, rcx                ; clear rcx this counts output bytes
.loop0:
        xor     rdx, rdx                ; clear rdx.  dividend is rdx:rax
        idiv    rbx                     ; divide by rbx
        cmp     rdx, 10
        jge     .over_ten
        add     rdx, '0'                ; rdx is remainder. convert to ascii by adding '0'
        jmp     .done
.over_ten:
        add     rdx, 55                 ; rdx is remainder. convert to ascii by adding 'A'
.done:
        mov     [rdi+rcx], rdx          ; copy to destination
        inc     rcx                     ; increment count of outputs
        cmp     rax, 0                  ; test if rax is 0 now
        jnz     .loop0                  ; loop if not

        lea     rsi, [rdi+rcx]
        dec     rsi
.loop1:
        mov     al, [rsi]
        mov     ah, [rdi]
        mov     [rdi], al
        mov     [rsi], ah
        dec     rsi
        inc     rdi
        cmp     rsi, rdi
        jg      .loop1

        ret



;
; rsi - label text
; rdx - label length
; rax - value to print
;

print_with_label:
        ; save value in rax
        push    rax

        ; write prefix
        lea     rsi, [rax_string wrt rip]
        mov     rdx, rax_string_len     ; length of string
        call    write_string            ; call write

        ; restore rax
        pop     rax

        ; convert value in rax to string
        mov     rdi, r8
        call    ltoah

        ; append newline
        mov     byte [r8+rcx], 0x0A

        ; write it
        mov     rsi, r8                 ; r8 contained the buffer address. move to rsi
        mov     rdx, rcx                ; rcx contains the length of string
        inc     rdx
        call    write_string            ; call write

        ret


;
; write a string to standard out
;
; input registers:
;    rsi - pointer to buffer
;    rdx - buffer length
;
; clobbered registers:
;    rax
;    rdi
;

write_string:
        mov     rax, 0x2000004          ; write call (see SYSCALL_CONSTRUCT_UNIX)
        mov     rdi, 1                  ; file descriptior (stdout)
        syscall                         ; call write
        ret


        global main
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32

        ; get the pointer to the buffer, store in r8
        mov     r8, rbp
        sub     r8, 32

        mov     rax, 0x00               ; define cpuid output option
        cpuid

        ; put values in the string
        lea     rdi, [output wrt rip]
        mov     [28 + rdi], ebx
        mov     [32 + rdi], edx
        mov     [36 + rdi], ecx

        ; write the string
        mov     rsi, rdi
        mov     rdx, output_len         ; length of string
        call    write_string            ; call write

        mov     rax, 0x01               ; define cpuid output option
        cpuid

        ; save registers
        push    rdx
        push    rcx
        push    rbx
        push    rax

        ; write rax value plus label
        lea     rsi, [rax_string wrt rip]
        mov     rdx, rax_string_len
        pop     rax
        call    print_with_label

        ; write rbx value plus label
        lea     rsi, [rbx_string wrt rip]
        mov     rdx, rbx_string_len
        pop     rax
        call    print_with_label

        ; write rcx value plus label
        lea     rsi, [rcx_string wrt rip]
        mov     rdx, rcx_string_len
        pop     rax
        call    print_with_label

        ; write rdx value plus label
        lea     rsi, [rdx_string wrt rip]
        mov     rdx, rdx_string_len
        pop     rax
        call    print_with_label

        mov rax, 0x2000001              ; exit call
        mov rdi, 0                      ; return code
        syscall                         ; call exit

        leave
        ret
