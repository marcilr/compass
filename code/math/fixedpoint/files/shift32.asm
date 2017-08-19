;-----------------------------------------------------------------;
; This routine shifts the unsigned 32-bit value pointed to        ;
; by R0, right or left an arbitrary amount.                       ;
;                                                                 ;
; INPUT:    R0          Points to MSB of 32-bit value             ;
;           ACC         Amount to shift in 2's complement.        ;
;                       Positive values shift left,               ;
;                       Negative values shift right.              ;
;                                                                 ;
; OUTPUT:   Value pointed to by R0 shifted right or left as       ;
;           Needed.                                               ;
;                                                                 ;
; MODIFIES: None.                                                 ;
; USES:     None.                                                 ;
;-----------------------------------------------------------------;
shift32:
   push  0x006
   push  0x007
   push  psw
   push  acc
   
   jz    shift32_exit            ; If shift=0, then exit
   jb    acc.7,shift32_neg

   mov   r7,a                    ; Get count
   inc   r0
   inc   r0                      ; Point to LSB
   inc   r0

shift321:
   push  0x000                   ; Save R0
   clr   c                       ; Clear for first rotate
   mov   r6,#4
shift322:
   mov   a,@r0                   ; Get byte 
   rlc   a                       ; Shift left
   mov   @r0,a                   ; Save back
   dec   r0                      ; Point to next byte
   djnz  r6,shift322
   pop   0x000                   ; Restore R0
   djnz  r7,shift321
   dec   r0
   dec   r0                      ; Point to MSB  
   dec   r0
   sjmp  shift32_exit
   
shift32_neg:   
   cpl   a                       ; Get 2's complement ACC
   inc   a
   mov   r7,a                    ; Get count

shift323:
   push  0x000                   ; Save R0
   clr   c                       ; Clear for first rotate
   mov   r6,#4
shift324:
   mov   a,@r0                   ; Get next
   rrc   a                       ; Rotate right
   mov   @r0,a                   ; Save byte
   inc   r0                      ; Point to next byte
   djnz  r6,shift324
   pop   0x000                   ; Restore R0
   djnz  r7,shift323

shift32_exit:
   pop   acc
   pop   psw
   pop   0x007
   pop   0x006
   ret