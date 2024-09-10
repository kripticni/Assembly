section .data
  delay dq 6, 240000000

section .text
  global _start

_start:
  mov rax, 35
  mov rdi, delay
  mov rsi, 0
  syscall

  mov rax, 60
  xor rdi, rdi
  syscall

