;--------------------------------------------------------;
; This routine writes out the unsigned 32-bit value      ;
; pointed to by R0.                                      ;
;                                                        ;
; INPUT:       R0       Point to 32-bit value to write.  ;
;                       R0->MSB,...R0+3->LSB             ;
; OUTPUT:      Writes 32-bit value to standard output.   ;
; USES:        bin8out, send_space                       ;
; MODIFIES:    NONE.                                     ;
;--------------------------------------------------------;
bin32out:
   push  0x000
   push  0x007
   push  psw
   push  acc
   
   mov   r7,#4
bin32out1:
   mov   a,@r0
   lcall bin8out
   lcall send_space
   inc   r0
   djnz  r7,bin32out1
   
   pop   acc
   pop   psw
   pop   0x007
   pop   0x000
   ret