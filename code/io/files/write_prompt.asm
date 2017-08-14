;--------------------------------------;
; This short routine writes out the    ;
; Raymon> prompt.                      ;
;--------------------------------------;
write_prompt:
   push  dpl
   push  dph
   
   lcall send_crlf
   mov   dptr,#prompt
   lcall pstr
   
   pop   dph
   pop   dpl
   ret