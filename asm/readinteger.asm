section .data
  input_buffer db 0

section .bss

section .text
  global _start

%macro read_int 1
    ; macro to read an integer from user input and store the result in rax

    ; read user input
    mov rax, 0            
    mov rdi, 0           
    mov rsi, %1
    mov rdx, 20             ; buffer size
    syscall                

    ; convert input to 32-bit integer, preperations
    xor r8, r8            ; clear r8 (will store result)
    xor rcx, rcx            ; clear rcx (counter for input string)

parse_input:
    movzx rbx, byte [%1 + rcx] ; load one character
    cmp rbx, 10             ; check for newline
    je done_parsing           ; jump to done if newline

    sub rbx, '0'              ; convert ASCII to digit

    mov rax, 10
    mul r8

    mov r8, rax
    add r8, rbx

    inc rcx                   ; move to next character
    jmp parse_input           ; repeat loop
done_parsing:
    mov rax, r8              ; ensure result is in lower 32 bits of rax
%endmacro

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

%macro exit 0
  mov rax, 60
  mov rdi, 0

  syscall
%endmacro

_start: 
  read_int input_buffer
  print_int input_buffer

  exit

