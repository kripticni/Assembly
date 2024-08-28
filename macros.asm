section .bss
  digit resb 2

section .text
  global _start

%macro exit 0
  mov rax, 60
  mov rdi, 0
  syscall
%endmacro

%macro scan 1
  mov rax, 0
  mov rdi, 0
  mov rsi, %1
  mov rdx, 2
  syscall
%endmacro

%macro ascii_to_digit 1
  mov al, [%1]
  sub al, 48
  mov [%1], al
%endmacro

%macro printdigit_fromrax 1
  add al, 48
  mov ah, 10 ; newline
  mov [%1], ax

  mov rax, 1
  mov rdi, 1
  mov rsi, %1
  mov rdx, 2
  syscall
%endmacro

%macro printdigit 1
  mov al, [%1]
  add al, 48
  mov [%1], rax
  mov byte [%1+1], 10

  mov rax, 1
  mov rdi, 1
  mov rsi, %1
  mov rdx, 2
  syscall

  ascii_to_digit %1
%endmacro

_start:
  scan digit
  ascii_to_digit digit
  printdigit digit
  exit


