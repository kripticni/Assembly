section .data
  filename db "testing.txt",0
  text db "Hello, World!",0
  string times 14 db 0

section .bss
  fd resb 1

section .text
  global _start

%macro exit 0
  mov rax, 60
  xor rdi, rdi
  syscall
%endmacro

_start:
  mov rax, 2 ; SYS_OPEN
  mov rdi, filename ; a pointer to the filename which is a zero terminated string
  mov rsi, 64+1 ; for create and write
  mov rdx, 0666o ; this is the octal value for the permissions, the o declares it as octal
  syscall

  ;push rax
  mov [fd], rax
  mov rdi, rax ; saving the file descriptor

  mov rax, 1
  mov rsi, text
  mov rdx, 13
  syscall      ; we have written to the file, "Hello, World!"

  mov rax, 3   ; i should really make an include file because this is getting repetetive (looking up the ints)
  ;mov rdi, [rsi]; just peeking from the stack 
  ;pop rdi
  mov rdi, [fd]
  syscall
  ; close the file for the first time

  ; open the file again, but for reading only
  mov rax, 2
  mov rdi, filename
  mov rsi, 0       ; read only mode
  mov rdx, 0666o
  syscall

  ;push rax
  mov [fd], rax

  ;mov rdi, rax ; the file descriptor
  mov rax, 0
  mov rdi, [fd]
  mov rsi, string
  mov rdx, 13
  syscall

  ;write to stdout
  mov rax, 1
  mov rdi, 1
  mov rsi, string
  mov rdx, 13
  syscall

  mov rax, 3
  mov rdi, [fd]
  ;pop rdi
  syscall

  exit
