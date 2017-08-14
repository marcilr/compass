;--------------------------------------;   
; This routine writes a space.         ;
;--------------------------------------;
send_space:
   push  acc
   
   mov   acc,#32           ; Get space constant in ACC
   lcall cout
   
   pop   acc
   ret
   