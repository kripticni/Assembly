section .data
  text db "Hello, World!",10 ; db = define bytes

section .text
  global _start ; obj file will contain a link to every var declared as global, and it always starts with _start 

_start:
  call _printHW

  mov rax, 60
  mov rdi, 0
  syscall

_printHW: ; this does not need to be global since it
  mov rax, 1; does not need to be linked
  mov rdi, 1
  mov rsi, text
  mov rdx, 14
  syscall
  ret ; this costs a little bit since it is an operation
