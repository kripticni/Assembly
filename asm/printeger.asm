;credit to this stackoverflow thread https://stackoverflow.com/questions/17862664/printing-a-number-in-x86-64-assembly

section .data

section .bss
  letter: resb 1
  number: resb 19

section .text
  global _start

;printchar
; mov [letter], rax
;  
; mov rax, 1
; mov rdi, 1
; mov rsi, letter
; mov rdx, 1
; syscall
; ret

%macro print_int 1
 lea r9, [%1 + 18] ; last character of buffer
 mov r10, r9           ; copy the last character address
 mov rbx, 10           ; base10 divisor

 %%div:

 xor rdx, rdx          ; zero rdx, because it can influence the div
 div rbx
 add rdx, '0'          ; turns a digit to a char, '0' is 48 and when you add it turns to ascii
 test rax,rax          ; if rax is 0, we are done, so we exit the loop
 jz %%last_remainder
 mov byte [r9], dl     ; save remainder from rdx
 sub r9, 1             ; decrement the buffer address, this is better than using dec
 jmp %%div              ; its better than dec because that can lead to stalling

 %%last_remainder:

 test dl, dl       ; if dl (last remainder) != 0 add it to the buffer
 jz %%check_buffer
 mov byte [r9], dl ; save remainder
 sub r9, 1         ; decrement the buffer address

 %%check_buffer:

 cmp r9, r10       ; if the buffer has data print it
 jne %%print_buffer 
 mov byte [r9], '0'; place the default zero into the empty buffer
 sub r9, 1

 %%print_buffer:

 add r9, 1          ; address of last digit saved to buffer
 sub r10, r9        ; end address minus start address
 add r10, 1         ; r10 = length of number
 mov rax, 1         ; nr_write
 mov rdi, 1         ; stdout
 mov rsi, r9        ; number buffer address
 mov rdx, r10       ; string length
 syscall
%endmacro

_start:
 mov rax, 7546543
 print_int number
 

 mov rax,60
 mov rdi,0
 syscall

