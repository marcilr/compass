;-----------------------------------------------------------------;
; This routine writes out the 16-bit value in DPTR                ;
; in binary.  DPL has the low 8-bits, and DPH the high            ;
; 8 bits.                                                         ;
; INPUT:          DPTR 16-bit value to write.                     ;
; OUTPUT:         Writes 16-bit binary value to standard output.  ;
; MODIFIES:       NONE                                            ;
; USES:           dec8out                                         ;
;-----------------------------------------------------------------;
bin16out:
   push  acc
   
   mov   a,dph          ; Get low bits in ACC
   lcall bin8out        ; Write low eight bits.
   mov   a,dpl          ; Get high bits in ACC
   lcall bin8out        ; Write low eight bits

   pop   acc
   ret
   