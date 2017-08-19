;--------------------------------------------------------------;
; This function adds the 32-bit value pointed to by r1 to the  ;
; 32-bit value pointed to by r0.                               ;
;                                                              ;
; INPUT:    R0       Points to 32-bit in RAM,                  ;
;                    R0->MSB,,,(R0+3)->LSB.                    ;
;           R1       Points to 32-bit in RAM,                  ;
;                    R1->MSB,,,(R1+3)->LSB.                    ;
;                                                              ;
; OUTPUT:   R0       Points to MSB byte of 32-bit result.      ;
;                                                              ;
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
;--------------------------------------------------------------;
add32:
   push  0x000
   push  0x001
   push  0x002
   push  psw
   push  acc

   inc   r0
   inc   r0             ; Point to LSB R0 value
   inc   r0
   
   inc   r1
   inc   r1             ; Point to LSB R1 value
   inc   r1 
   
; Loop though bytes from LSB to MSB

   mov   r2,#4           
   clr   c              ; Clear Carry for addc
add32_loop:
   mov   a,@r0          ; Fetch byte from R0
   addc  a,@r1          ; Add byte from R1
   mov   @r0,a          ; Save byte back
   dec   r0             ; Point to next highest R0 byte
   dec   r1             ; Point to next highest R1 byte
   djnz  r2,add32_loop

   pop   acc
   pop   psw
   pop   0x002
   pop   0x001
   pop   0x000
   ret