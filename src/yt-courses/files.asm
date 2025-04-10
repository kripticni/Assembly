section .data
  filename db "testing.txt",0
  text db "Hello, World!",0

section .bss

section .text
  global _start

%macro exit 0
  mov rax, 60
  mov rdi, 0
  syscall
%endmacro

_start:
  mov rax, 2 ; SYS_OPEN
  mov rdi, filename ; a pointer to the filename which is a zero terminated string
  mov rsi, 64+1 ; for create and write
  mov rdx, 0644o ; this is the octal value for the permissions, the o declares it as octal
  syscall

  push rax
  mov rdi, rax ; saving the file descriptor

  mov rax, 1
  mov rsi, text
  mov rdx, 13
  syscall      ; we have written to the file 

  mov rax, 3   ; i should really make an include file because this is getting repetetive (looking up the ints)
  pop rdi
  syscall

  exit
