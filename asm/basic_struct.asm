section .bss
  struc person
    str: resb 32
    age: resd 1
  endstruc
  
section .data
  text db "Age: ",0
  student:
    istruc person
      at str, db "Name, Surname",10
      at age, dd 9 ; for simplicity sake, a single digit
    iend

section .text
  global _start

_start:
  mov rax, 1
  mov rdi, 1
  lea rsi, [student + str]
  mov rdx, 15
  syscall

  mov rax, 1
  mov rdi, 1
  lea rsi, text
  mov rdx, 5
  syscall

  mov rax, 1
  mov rdi, 1
  add DWORD [student + age], 48
  lea rsi, [student + age]
  mov rdx, 1
  syscall

  sub DWORD [student+age], 48

  mov rax, 60
  mov rdi, 0
  syscall



  

  
