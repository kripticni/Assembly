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
  mov rax, [%1]
  sub rax, 48
  mov [%1], rax
%endmacro

%macro printdigit_fromrax 1
  add rax, 48
  mov ah, 10 ; newline
  mov [%1], ax

  mov rax, 1
  mov rdi, 1
  mov rsi, %1
  mov rdx, 2
  syscall
%endmacro

%macro printdigit 1
  mov rax, [%1]
  add rax, 48
  mov ah, 10 ; also newline
  mov [%1], rax

  mov rax, 1
  mov rdi, 1
  mov rsi, %1
  mov rdx, 1
  syscall

  ascii_to_digit %1
%endmacro

_start:
  scan digit
  ascii_to_digit digit
  push qword [digit] ;qword is quad word, and means 64bit, since the stack works with 64 bits

  scan digit
  ascii_to_digit digit
  push qword [digit]

  scan digit
  ascii_to_digit digit
  push qword [digit]

  pop rax
  ; you could also just peek, by doing
  ; mov *register*, [rsp]
  pop rbx

  add rax, rbx
  pop rbx

  add rax, rbx
  mov [digit], rax
  printdigit_fromrax digit

  exit

