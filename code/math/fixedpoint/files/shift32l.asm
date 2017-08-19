;-----------------------------------------------------------------;
; This routine shifts the 32-bit pointed to by R0 left once,      ;
; returning the high bit in C.                                    ;
;                                                                 ;
;  INPUT:      R0       Point to 32-bit value, MSB first.         ;
;  OUPUT:      R0       32-bits rotated left.                     ;
;              C        MSB bit.                                  ;
;  USES:       None.                                              ;
;-----------------------------------------------------------------;
shift32l:
   push  0x000
   push  acc
   push  b

   inc   r0
   inc   r0                ; Point to LSB 32-bit value
   inc   r0

   clr   c                 ; Clear high bit rotated in 
   mov   b,#4
shift32l1:
   mov   a,@r0             ; Fetch byte
   rlc   a                 ; Rotate right
   mov   @r0,a             ; Save back
   dec   r0                ; Point to next
   djnz  b,shift32l1       ; Loop as needed
   inc   r0                ; Restore R0

   pop   b
   pop   acc
   pop   0x000
   ret