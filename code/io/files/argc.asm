;-----------------------------------------------------------------------------;
; This routine scans an ASCII 0 terminated string and returns the number      ; 
; of arguments in it. Arguments can be composed of any ASCII value            ;
; from 33-126, delimators can be any character not in this range.             ;                    
;                                                                             ;
; INPUT:       COMPTR               Pointer to command string with arguments. ;
; RETURNS:     ACC                  Number of arguments.                      ;
; MODIFIES:    Carry Flag                                                     ;              
;-----------------------------------------------------------------------------;
argc:
   push  b
   push  0x0000 
   
   mov   r0,comptr
   
   mov   b,#0x000          ; Set initial argument count=0 
argc1:
   mov   a,@r0             ; Get first character
   jz    argc_exit
   cjne  a,#32,argc2       ; Is character a space?, Yes then get next char
   sjmp  argc3
argc2:
   lcall isascii           ; Is character a printable ASCII character
   jc    argc4             ; Yes, then increment arg counter
argc3:
   mov   a,r0
   inc   a                 ; No, then point to next character
   mov   r0,a
   sjmp  argc1             ; And loop again.
   
argc4:
   mov   a,b
   inc   a                 ; Increment argument count
   mov   b,a
   
argc5:
   mov   a,r0              
   inc   a                 ; Increment to next character
   mov   r0,a
   mov   a,@r0             ; Get character
   jz    argc_exit         ; ASCII 0? Yes, then exit
   cjne  a,#32,argc6       ; Character a space?
   sjmp  argc1             ; Yes, then look for next printable char.
argc6:
   lcall isascii           ; Is character printable ASCII?
   jnc   argc1             ; No, then find next printable char.
   sjmp  argc5             ; Yes, look for next non-printable char

argc_exit:
   mov   a,b              ; Return argument count 
   
   pop   0x0000
   pop   b
   ret