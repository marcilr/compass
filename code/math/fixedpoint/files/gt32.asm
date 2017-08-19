;-----------------------------------------------------;
; This routine compares two unsigned 32-bit values.   ;
; It returns 1 if R0 is greater than R1, and 0        ;
; otherwise.                                          ;
;                                                     ;
; INPUT:    R0       Points to 1st value.             ;
;           R1       Points to 2nd value.             ;
;                                                     ;
; OUTPUT:   ACC=1    R0>R1                            ;
;           ACC=0    R0<=R1                           ;
;-----------------------------------------------------;
gt32:
   push  psw
   push  b
   
   inc   r0
   inc   r0             ; Point to LSB R0
   inc   r0
   inc   r1
   inc   r1             ; Point to LSB R1
   inc   r1
   
   mov   a,@r0          ; Get byte from R0
   mov   b,@r1          ; Get byte from R1
   inc   b              ; Bump up by 1 to catch R0=R1
   clr   c              ; Clear for subbc
   subb  a,b
   
   dec   r0
   dec   r1
   
   mov   b,#3
gt321:
   mov   a,@r0          ; Fetch byte from R0
   subb  a,@r1          ; Subtract byte from R1
   dec   r0             ; Point to next bytes
   dec   r1
   djnz  b,gt321

   inc   r0             ; Restore R0
   inc   r1             ; Restore R1

   cpl   c              ; Complement flag
   clr   a              ; Clear ACC
   mov   acc.0,c        ; Return value
   
   pop   b
   pop   psw
   ret