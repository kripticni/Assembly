section .bss
  digitSpace resb 100
  digitSpacePos resb 8 ; so it can store an adress

section .text
  global _start

%macro exit 0 
  mov rax, 60
  mov rdi, 0
  syscall
%endmacro

_start:
  mov rax, 69420
  call _printRAX

  exit

_printRAX:
  mov rcx, digitSpace
  mov rbx, 10 ; new line
  mov [rcx], rbx ; so we have loaded 10 into digitSpace
  inc rcx
  mov [digitSpacePos], rcx ; loads the value of digitSpace into
                           ; digit space position but without
                           ; the new line, so the start of
                           ; the integer
_printRAXLoop:
  xor rdx, rdx
  mov rbx, 10
  div rbx
  push rax
  add rdx, 48 ; since rdx stores the remainder after dividing
  mov rcx, [digitSpacePos]
  mov [rcx], dl

  inc rcx
  mov [digitSpacePos], rcx

  pop rax
  cmp rax, 0
  jne _printRAXLoop

_printRAXLoop2:
  mov rcx, [digitSpacePos]
  
  mov rax, 1
  mov rdi, 1
  mov rsi, rcx
  mov rdx, 1
  syscall

  mov rcx, [digitSpacePos]
  dec rcx
  mov [digitSpacePos], rcx

  cmp rcx, digitSpace
  jge _printRAXLoop2

  ret
