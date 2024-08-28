section .data
  text db "Hello, World!",10,0 

section .text
  global _start

  %macro exit 0
    mov rax, 60
    xor rdi, rdi  ; apparently doing xor with 2 of the same 
    syscall       ; registries is faster than mov 0, since
  %endmacro       ; that is a 7 byte instruction compared to
                  ; 2 bytes of xor

  ; improved puts macro that uses a single syscall to write
  ; the entire string
  %macro puts 1
    mov rax, 1
    mov rdi, 1
    mov rsi, %1      ; rsi points to the string, by default
    xor rdx, rdx
    
    %%lenloop:
    cmp byte [rsi + rdx], 0  ; check if we've hit the null terminator
    je %%endlen
    inc rdx
    jmp %%lenloop
    
    %%endlen:
    syscall    
  %endmacro

_start:
  puts text   
  exit       

