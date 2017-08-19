;--------------------------------------------------;
; This routine copies the 32-bit value pointed     ;
; to by r0 to the location pointed to by r1.       ;
;                                                  ;
; INPUT:       R0       Points to source.          ;
;              R1       Points to destination.     ;
;                                                  ;
; NOTES:       Assumes MSB is first LSB is last.   ;
;              Both 4 byte values are above 80h    ;
;              in RAM since indirect addressing    ;
;              is used.                            ;
;--------------------------------------------------;
copy32:
   push  0x000
   push  0x001
   push  0x006
   push  acc

   mov   r6,#4          ; Loop 4 times
copy32_loop:
   mov   a,@r0          ; Fetch byte from R0
   mov   @r1,a          ; Save to R1
   inc   r0             ; Increment pointers
   inc   r1
   djnz  r6,copy32_loop

   pop   acc
   pop   0x006
   pop   0x001
   pop   0x000
   ret