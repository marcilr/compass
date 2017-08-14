;-----------------------------------------------------;
; This routine writes out the 8-bit value of          ;
; ACC in binary.                                      ;
; INPUT:       ACC                                    ;
; OUTPUT:      Writes ACC in binary to standard out.  ;
; MODIFIES:    None                                   ;
;-----------------------------------------------------;
bin8out:
   push  0x000
   push  0x001
   push  psw
   
   mov   r0,#8
bin8out1:   
   rl    a
   mov   r1,a              ; Save copy of ACC in R1
   
   anl   a,#00000001b      ; Mask off low bits
   add   a,#48             ; Convert to 0 or 1
   lcall cout
   
   mov   a,r1              ; Restore ACC  
   djnz  r0,bin8out1
   
   pop   psw
   pop   0x001
   pop   0x000
   ret