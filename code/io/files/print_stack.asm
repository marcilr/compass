;--------------------------------------;
; This routine prints out the          ;
; contents of the stack.               ;
; MODIFIES:    NONE                    ;
;--------------------------------------;
print_stack:
   push  acc
   
   mov   a,sp
   dec   a
   lcall send_crlf
   lcall phex
   lcall write_prompt
   
   pop   acc
   ret