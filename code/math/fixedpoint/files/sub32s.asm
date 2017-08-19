;--------------------------------------------------------------;
; This routine takes a signed 32-bit signed value pointed      ;
; to by r0 and subtracts the 32-bit value pointed to by r1.    ;
;                                                              ;
; INPUT:    R0       Points to 32-bit in RAM,                  ;
;                    R0->MSB,,,(R0+3)->LSB.                    ;
;           R1       Points to 32-bit in RAM,                  ;
;                    R1->MSB,,,(R1+3)->LSB.                    ;
;                                                              ;
; OUTPUT:   R0       Points to MSB byte of 32-bit result.      ;
; USES:     add32                                              ;
; DESTROYS: None.                                              ;
;                                                              ;
; NOTES:    This function can be used with signed and unsigned ;
;           32-bit values as well as 32-bit signed or          ;
;           unsigned fixed point fixed point values,           ;
;           ie 16.16, 8.24, etc.                               ;
;                                                              ;
;           R0 and R1 are accessed using indirect addressing,  ;
;           so these values most be located in RAM 80h or      ;
;           higher.                                            ;
;                                                              ;
;           There are only two cases to consider:              ;
;                                                              ;
;              1. R1 is postive                                ;
;              2. R1 is negative ie in 2's complement.         ;
;                                                              ;
;           In both cases we want to get the complement of R1  ;
;           and add it to R0.                                  ;                                                               ;         
;--------------------------------------------------------------;
sub32s:
   push  acc
   
   mov   a,r0           ; Save copy of R0 in ACC
   mov   r0,0x001       ; R1->R0
   lcall bin32cpl       ; Get complement of 2nd value
   mov   r0,a           ; Get R0 back
   lcall add32          ; Add two values
   
; Restore 2nd value
   mov   a,r0           ; Save copy of R0 in ACC
   mov   r0,0x001       ; R1->R0
   lcall bin32cpl       ; Get complement of 2nd value
   mov   r0,a           ; Restore R0
   
   pop   acc
   ret