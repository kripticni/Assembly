section .data
section .bss

section .text
  global absoluteArray

absoluteArray:
  ;push rbp
  ;mov rbp, rsp
  pcmpeqd mm5, mm5 ; all 1s
  pcmpgtd mm6, mm6 ; all 0s

  mov al, 1
  and eax, 0ffh
  movd mm4, eax
  punpcklwd mm4, mm4
  punpcklwd mm4, mm4 ; all words are 1 and all zeroes

  movq mm0, qword [rdi] ; the pointer from the calling convention
  movq mm1, mm0
  pcmpgtw mm0, mm6 ; so now we know all positives and negatives

  movq mm7, mm0 ; copying to mm7 so we have the result after the next instruction
  pand mm0, mm1 ; so now mm0 has only positives and negatives are zeroes

  pxor mm7, mm5 ; complementing by xoring with all 1s
  pand mm7, mm1 ; now this stores all the negatives, now we need to undo II's complement
  pxor mm7, mm5 ; now we have undone the I's complement since this flips all the bits
  paddw mm7, mm4 ; this adds 1 so we undo II's complement

  por mm0, mm7 ; since mm0 had zeroes where negatives were, and mm7 had zeroes were positives were
               ; this is able to simply merge the two

  movq qword [rdi], mm0 ; store it back at the address

  ;mov rsp, rbp
  ;pop rbp
  ret




