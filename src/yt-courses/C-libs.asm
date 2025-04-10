global main
extern printf, scanf

section .data
  msg1 db "Enter any number: ",0
  msg2 db "Looping from %i to %i.",10,0
  format db "%d",0

section .bss
  number resd 1

section .text

%macro exit 0
  mov rax, 60
  mov rdi, 0
%endmacro

main:
  ; stack reservation for int i
  push rbp
  mov rbp, rsp
  sub rsp, 16

  ; body for the calling convention
  xor eax, eax
  lea rdi, [msg1]
  call printf

  ; scanf here
  xor eax, eax
  lea rdi, [format]
  lea rsi, [number]
  call scanf

  mov DWORD [rbp-4],0

_loop:
  xor eax, eax
  mov edx, [number] ;since int32, scanf val
  mov rsi, [rbp - 4];local var i
  lea rdi, [msg2]
  call printf

  mov ecx, DWORD [number]
  add DWORD [rbp - 4], 1

  cmp [rbp-4], ecx   ; stack var, scanf var 
  jl _loop

  add rsp, 16
  leave
  ret
