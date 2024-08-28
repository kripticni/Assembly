section .data
  text1 db "What is your name? " ; db = define bytes
  text2 db "Hello, "

section .bss
  name resb 16 ; resb is reserve bytes

section .text
  global _start ; obj file will contain a link to every var declared as global, and it always starts with _start 

_start:
  call _print1
  call _scanName
  call _print2
  call _printName

  mov rax, 60
  mov rdi, 0
  syscall

_print1:
  mov rax, 1
  mov rdi, 1
  mov rsi, text1
  mov rdx, 19
  syscall
  ret

_print2:
  mov rax, 1
  mov rdi, 1
  mov rsi, text2
  mov rdx, 7
  syscall
  ret

_scanName:
  mov rax, 0
  mov rdi, 0
  mov rsi, name
  mov rdx, 16
  syscall
  ret


_printName:
  mov rax, 1
  mov rdi, 1
  mov rsi, name
  mov rdx, 16
  syscall
  ret
