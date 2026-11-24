section .data
my_favorite_string: db "Here is an initialized value."
some_number: dd 42

section .bss
uninitialized_32byte_buffer: resb 32

section .text
global _start
_start:                      ; the first instruction to run
    mov [uninitialized_32byte_buffer], ah
