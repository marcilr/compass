;-----------------------------------------------------------------;
; This routine shifts the signed 32-bit value pointed to          ;
; by R0, right or left an arbitrary amount.                       ;
;                                                                 ;
; INPUT:    R0          Points to MSB of 32-bit signed value      ;
;           ACC         Amount to shift in 2's complement.        ;
;                       Positive values shift left,               ;
;                       Negative values shift right.              ;
;                                                                 ;
; OUTPUT:   Value pointed to by R0 shifted right or left as       ;
;           Needed.                                               ;
;                                                                 ;
; MODIFIES: None.                                                 ;
; USES:     shift32.                                              ;
;-----------------------------------------------------------------;
shift32s:
   push  b
   
   jz    shift32s_exit              ; If rotations=0 then exit

; Get sign bit and save high byte with 
; cleared sign bit

   mov   b,@r0                      ; Get high byte
   jnb   b.7,shift32s1              ; Sign bit set?
   lcall bin32cpl                   ; Get complement
   lcall shift32                    ; Shift
   lcall bin32cpl                   ; Complement back
   sjmp  shift32s_exit

shift32s1:
   lcall shift32                    ; Shift 

shift32s_exit:

   pop   b
   ret