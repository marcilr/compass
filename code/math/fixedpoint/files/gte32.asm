;-----------------------------------------------------;
; This routine compares two unsigned 32-bit values.   ;
; It returns 1 if R0 is greater than or equal to R1,  ;
; and 0 otherwise.                                    ;
;                                                     ;
; INPUT:    R0       Points to 1st value.             ;
;           R1       Points to 2nd value.             ;
;                                                     ;
; OUTPUT:   ACC=1    R0>=R1                           ;
;           ACC=0    R0<R1                            ;
;-----------------------------------------------------;
gte32:
   push  psw
   push  b
   
   inc   r0
   inc   r0             ; Point to LSB R0
   inc   r0
   inc   r1
   inc   r1             ; Point to LSB R1
   inc   r1
   
   clr   c
   mov   b,#4
gte321:
   mov   a,@r0          ; Fetch byte from R0
   subb  a,@r1          ; Subtract byte from R1
   dec   r0             ; Point to next bytes
   dec   r1
   djnz  b,gte321

   inc   r0             ; Restore R0
   inc   r1             ; Restore R1

   cpl   c              ; Complement flag
   clr   a              ; Clear ACC
   mov   acc.0,c        ; Return value
   
   pop   b
   pop   psw
   ret
