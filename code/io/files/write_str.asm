;--------------------------------------------------;
; This routine prints a string in RAM.             ;
; INPUT:    r0       Points to string to print     ;
; OUTPUT:            Prints string to serial port. ;
; MODIFIES: None                                   ;
;--------------------------------------------------;
write_str:
   push  acc
   push  0x000                
   
write_str1:
   mov   a,@r0                ; Get character
   inc   r0
   jz    write_str2
   lcall cout                 ; Send character out
   sjmp  write_str1

write_str2:
   
   pop   0x000
   pop   acc
   ret