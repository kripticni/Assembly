section .data
  text db "Hello, World!",10,0 ; db = define bytes, added 0 at the end 
  ; so we can count the amount of characters until the NULL delimiter

section .text
  global _start ; obj file will contain a link to every var declared as global, and it always starts with _start 

  %macro exit 0
    mov rax, 60
    mov rdi, 0
    syscall
  %endmacro


  ; input, rax as pointer to our string
  ; output, printed string
_puts:
  push rax ; so we save the value of rax,
           ; which is a pointer to the beginning of the string
  mov rbx, 0 ; counter
  ; NO RET HERE, BECAUSE WE DONT WANNA CHANGE THE RIP
_putsloop:
  inc rax
  inc rbx
  ; important to mention that this does not check if the string
  ; is equal to NULL
  mov cl, [rax] ; cl is the 8bit version of rcx, just like al is for rax
                ; we are using [ ], because rax is now a pointer to a string
  cmp cl, 0     ; checking if the current character is zero
  jne _putsloop ; so if its not zero, this is a loop

  ; now since the last char is NULL, we go back to the beginning
  ; and print the amount of characters we counted

  mov rax, 1
  mov rdi, 1
  pop rsi ; so now in the rsi register, there is the pointer to the
          ; beginning of the string
  mov rdx, rbx ; rbx was our counter, and for this syscall rdx is the number
               ; of bytes to print, now that i think of it we could have just
               ; counted into rdx
  syscall
  ret


_start:
  mov rax, text
  call _puts

  exit
