section .data
  newline db 10,0
  text_count db "The Argument count is: ",0
  text_path  db "The path is: ",0
  text_args  db "Argument[",0
  text_args2 db "]: ",0 

section .bss
  digit resb 1

section .text
  global _start

%macro exit 0
  mov rax, 60
  mov rdi, 0
  syscall
%endmacro

%macro print_digit 2 ;1 is the register, 2 is the str
  add %1, '0'
  mov [%2], %1

  mov rax, 1
  mov rdi, 1
  mov rsi, %2
  mov rdx, 1
  syscall
%endmacro

  ; improved puts macro that uses a single syscall to write
  ; the entire string
%macro puts 1
  ; we move %1 into rsi first incase the macro has %1 as rax
  mov rsi, %1      ; rsi points to the string, by default
  mov rax, 1
  mov rdi, 1
  xor rdx, rdx

  %%lenloop:
  cmp byte [rsi + rdx], byte 0 ; check if we've hit the null terminator
  jz %%endlen
  add rdx, 1
  jmp %%lenloop

  %%endlen:
  syscall    
%endmacro

%macro newline 0
  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall
%endmacro

_start:
  puts text_count
  pop rax
  mov r10, rax ; saving argc 
  sub r10, 48
  print_digit rax, digit
  newline


  puts text_path
  pop rax
  puts rax
  newline

  mov r9, 1
_argv_loop:
  puts text_args
  print_digit r9, digit
  sub r9, '0'
  puts text_args2

  pop rax
  puts rax
  newline

  add r9, 2
  cmp r9, r10
  sub r9, 1
  jg _argv_loop
  exit

