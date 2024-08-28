; my hopefully more optimised implenetation of puts
; in relation to the one i saw in a course
; unless syscalls are really expensive, which could be true
; either way it was fun to minimize registry uses
section .data
  text db "Hello, World!",10,0 ; db = define bytes, added 0 at the end 
  ; so we can count the amount of characters until the NULL delimiter

section .text
  global _start ; obj file will contain a link to every var declared as global, and it always starts with _start 

  %macro exit 0
    mov rax, 60
    mov rdi, 0
    syscall
  %endmacro

  ; input, rax as pointer to our string
  ; output, printed string

  %macro puts 1
    mov rsi, %1

    mov rax, 1
    mov rdi, 1
    mov rdx, 1 ; since we are printing 1 char at a time

    %%putsloop:   
    mov cl, [rsi]
    cmp cl, 0 ; checking if first byte is NULL
    je %%skip  

    syscall ; printing the first character
    inc rsi
    jmp %%putsloop
  
    %%skip:
  %endmacro

_start:
  puts text

  exit
