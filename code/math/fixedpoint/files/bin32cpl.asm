;-----------------------------------------------------------------;
; This routine returns the 2's complement of the                  ;
; 32-bit value pointed to by R0.                                  ;
;                                                                 ;
; INPUT:       R0       Points to 32-bit in RAM (above 80h).      ;
;                       R0->MSB,,,(R0+3)->LSB.                    ;
; OUTPUT:      R0       Points to 2's complement of 32-bit value. ;
; MODIFIES:    R0       Value pointed to by R0                    ;
; USES:        NONE.                                              ;
; NOTES:       This routine has been fully tested.                ;
;-----------------------------------------------------------------;
bin32cpl:
   push  psw
   push  acc   
   push  b                 

   inc   r0
   inc   r0                ; Point R0 to LSB
   inc   r0

   mov   b,#4
   setb  c
bin32cpl1:
   mov   a,@r0             ; Fetch byte
   cpl   a                 ; Get complement
   addc  a,#0              ; Inc. if needed
   mov   @r0,a             ; Save back
   dec   r0                ; Point to next byte
   djnz  b,bin32cpl1       ; Loop.
   inc   r0                ; Restore R0

   pop   b               
   pop   acc
   pop   psw
   ret