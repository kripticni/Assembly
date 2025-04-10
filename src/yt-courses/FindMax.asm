section .data

section .bss

;int FindMax(int *i, int count); to find 
;the max element in a given array

;so we pass the pointer to rdi, and size to rsi
;the return value should be in rax

section .text
  global FindMax

FindMax:
  ;push rbp
  ;mov rbp, rsp

  cmp rsi, 1
  ;cmovl eax, 80000000h this doesnt work with imm values
  mov rax, 80000000h
  jl finish

  mov eax, DWORD [rdi]
  je finish

  dec rsi

_loop:
  add rdi, 4
  cmp DWORD [rdi], eax
  cmovg eax, DWORD [rdi]

  dec rsi
  jnz _loop

finish:
  ;mov rsp, rbp
  ;pop rbp
  ret

