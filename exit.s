;   Program: exit
;

segment .text
global _main
extern _exit

_main:
        mov eax,1
        xor edi,edi
        call _exit
       
