;--------------------------------------------------;
; This routine copies a 32-bit value in program    ;
; memory to a location in RAM.                     ;
;                                                  ;
; INPUT:       R0       Points to destination      ;
;              DPTR     Point to source in PSTORE  ;
; OUTPUT:      32-bit value copied to dest.        ;
; USES:        None.                               ;
;                                                  ;
; NOTES:       R0 pointer must be above 80h        ;
;              as indirect addressing is used.     ;
;--------------------------------------------------;
copy32p:
   push  0x000
   push  0x006
   push  dpl
   push  dph
   push  acc

   mov   r6,#4
copy32p_loop:
   clr   a                    ; Offset=0
   movc  a,@a+dptr            ; Fetch value from PSTORE
   mov   @r0,a                ; Save value to RAM 
   inc   dptr                 ; Point to next PSTORE location
   inc   r0                   ; Point to next RAM location
   djnz  r6,copy32p_loop

   pop   acc
   pop   dph
   pop   dpl
   pop   0x006
   pop   0x000
   ret
