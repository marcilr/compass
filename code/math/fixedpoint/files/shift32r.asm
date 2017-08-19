;-----------------------------------------------------------------;
; This routine shifts the 32-bit pointed to by R0 right once,     ;
; returning the low bit in C.                                     ;
;                                                                 ;
;  INPUT:      R0       Point to 32-bit value, MSB first.         ;
;  OUPUT:      R0       32-bits rotated right.                    ;
;              C        LSB bit.                                  ;
;  USES:       None.                                              ;
;-----------------------------------------------------------------;
shift32r:
   push  0x000
   push  acc
   push  b

   clr   c                 ; Clear high bit rotated in 
   mov   b,#4
shift32r1:
   mov   a,@r0             ; Fetch byte
   rrc   a                 ; Rotate right
   mov   @r0,a             ; Save back
   inc   r0                ; Point to next
   djnz  b,shift32r1       ; Loop as needed

   pop   b
   pop   acc
   pop   0x000
   ret