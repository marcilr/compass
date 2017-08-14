;--------------------------------------------------------------;
; This routine writes out a 32-bit signed 16.16 fixed          ;
; point value in decimal.                                      ;
;                                                              ;
; INPUT:       r0          Pointer to 32-bit value in 80h-FFh  ;
;                          r0=MSB,...,r0+3=LSB                 ;
;                                                              ;
; OUTPUT:      Writes signed 16.16 fixed point value				;
;              pointed to by R0.           							;
;                                                              ;
; MODIFIES:    None.                                           ;
;                                                              ;
; NOTES: This routine suffers from a +/-1 error in the         ;
; last decimal place.  This routine could be improved by       ;
; the use of a 32/32 division routine.                         ;
;                                                              ;
; Also the last part of this routine that pads out the         ;
; fractional result with zeros could certainly stand           ;
; improvement.                                                 ;
;--------------------------------------------------------------;
fouts:
   push  0x000
   push  0x001
   push  0x002
   push  0x003
   push  0x004
   push  0x005
   push  0x006
   push  0x007
   push  psw
   push  dpl
   push  dph
   push  acc

; Check for sign bit and handle as needed.
   mov   a,@r0             ; Get MSB
   jb    acc.7,fouts2  ; Negative?, continue
   lcall fouts3          ; Write value
   sjmp  fouts_exit    ; Done, so exit

; Negative so write minus sign, complement, then write value.
fouts2:
   mov   a,#45             ; ASCII for minus sign
   lcall cout              ; Write minus sign.
   lcall bin32cpl          ; complement value
   push  0x000             ; Save R0
   lcall fouts3
   pop   0x000             ; Restore R0
   lcall bin32cpl          ; Restore value

fouts_exit:
   pop   acc
   pop   dph
   pop   dpl
   pop   psw
   pop   0x007
   pop   0x006
   pop   0x005
   pop   0x004
   pop   0x003
   pop   0x002
   pop   0x001
   pop   0x000
   ret

fouts3:

; Write out whole value part.
   mov   a,@r0             ; Fetch MSB
   mov   dph,a
   inc   r0                ; Point to MSB-1
   mov   a,@r0 
   inc   r0                ; Point to first fractional byte
   mov   dpl,a
   lcall dec16out          ; Write whole value part

; Write decimal point
   mov   a,#46             ; Write a decimal point
   lcall cout

; This next section converts the fractional part of
; the signed 16.16 fixed point value to decimal.
;
; Register Usage:
;     R0       Pointer to fractional bytes
;     R1       Loop counter
;     ACC      Fractional value, this is swapped for the
;              low fractional byte halfway through the loop.
;     R2/R3    Dividend, this is reset to 10,000 every pass
;     R4/R5    Divisor, set 2,4,8,16,...
;     DPTR     Accumulator for quotients (R2/R3)/(R4/R5)
;     R6/R7    Accumular for remainder for rounding at 
;              the end of the loop.

   mov   a,@r0             ; ACC:=1st fractional byte
   inc   r0                ; Point next fractional byte
   
; Initialize DPTR Quotient Accumulator
   mov   dpl,#0
   mov   dph,#0
   
; Initialize DPTR Remainder Accumulator
   mov   r6,#0
   mov   r7,#0
   
; Initialize R4/R5=Divisor=2
   mov   r4,#0
   mov   r5,#2
   
   mov   r1,#13                  ; Loop for 13 bits
fouts4:
   jnb   acc.7,fouts5        ; If the bit isn't set don't bother dividing

; This section handles the case where the current bit 
; set.  In this case 10,000 is divided by 2^i, and
; the quotient is added to DPTR.  The remainder is added 
; added to R6/R7.

; Save divisor R4/R5
   push  0x0004
   push  0x0005

; R2/R3=Dividend=10,000=00100111 00010000b
 
   mov   r2,#00100111b           ; Set high byte
   mov   r3,#00010000b           ; Set low byte
   
; Dividend=R2/R3=10,000, Divisor=R4/R5=2^1 
; Divide (R2/R3)/(R4/R5)

   lcall divide      ; R2/R3=quotient, R4/R5=Remainder

; DPTR:=DPTR+R2/R3
   push  acc         ; Save ACC
   clr   c           ; Clear for addc
   mov   a,dpl       ; Get low byte Quotient Accumulator       
   add   a,r3        ; Add low byte of Quotient
   mov   dpl,a       ; Save back
   mov   a,dph       ; Get high byte Quotient Accumulator
   addc  a,r2        ; Add high byte of Quotient
   mov   dph,a       ; Save back
   pop   acc         ; Restore ACC

; (R6/R7):=(R6/R7)+(R4/R5)
   push  acc         ; Save ACC
   clr   c           ; Clear for addc
   mov   a,r7        ; Get low byte Remainder Accumulator
   add   a,r5        ; Add low byte of Remainder
   mov   r7,a        ; Save back
   mov   a,r6        ; Get high byte Remainder Accumulator
   addc  a,r4        ; Add high byte of Remainder
   mov   r6,a        ; Save back
   pop   acc         ; Restore ACC

; Restore divisor R4/R5
   pop   0x005
   pop   0x004
   
fouts5:
   rl    a                       ; Rotate next bit into position

; (R4/R5):=(R4/R5)*2
   push  acc
   clr   c                       ; Clear for rlc
   mov   a,r5                    ; Get low byte of divisor
   rlc   a                       ; Multiply by 2
   mov   r5,a                    ; Save R5 back
   mov   a,r4                    ; Get high byte of divisor
   rlc   a                       ; Multiply by 2
   mov   r4,a                    ; Save R4 back
   pop   acc

; If 8 bits done, then get next fractional byte
   cjne  r1,#6,fouts6        ; 13-8+1=6
      
   mov   a,@r0                   ; ACC:=2nd fractional byte
fouts6:
   djnz  r1,fouts4

; Check 14th bit=2^-14=1/16384=.000061035
; 6104=00010111 11011000
   jnb   acc.7,fouts9
   
   push  acc
   clr   c                       ; Clear for addc
   mov   a,r7                    ; Get low byte remainder
   add   a,#11011000b            ; Add low byte of 6104
   mov   r7,a                    ; Save back
   mov   a,r6                    ; Get high byte
   addc  a,#00010111b            ; Add high byte of 6104
   mov   r6,a                    ; Save back
   pop   acc

; Check 15th bit

fouts9:
   rl    a                       ; Get 15th bit

; Check 15th bit=2^-15=1/=.000030517
; 3052=00001011 11101100
   jnb   acc.7,fouts11
   
   push  acc
   clr   c                       ; Clear for addc
   mov   a,r7                    ; Get low byte remainder
   add   a,#11101100b            ; Add low byte of 3052
   mov   r7,a                    ; Save back
   mov   a,r6                    ; Get high byte
   addc  a,#00001011b            ; Add high byte of 3052
   mov   r6,a                    ; Save back
   pop   acc

; Check 16th bit

fouts11:
   rl    a                       ; Get 16th bit

; Check 16th bit=2^-16=1/65536=.000015258
; 1526=00000101 11110110
   jnb   acc.7,fouts12
   
   push  acc
   clr   c                       ; Clear for addc
   mov   a,r7                    ; Get low byte remainder
   add   a,#11110110b            ; Add low byte of 1526
   mov   r7,a                    ; Save back
   mov   a,r6                    ; Get high byte
   addc  a,#00000101b            ; Add high byte of 1526
   mov   r6,a                    ; Save back
   pop   acc

fouts12:

; Check if remainder is greater than 10,000.
; 10,000 = 00100111 00010000b

   mov   r2,0x006          ; Save a copy of R6/R7 in R2/R3
   mov   r3,0x007

   clr   c                 ; Clear for subb
   mov   a,r3              ; Get low byte Remainder in accumulator
   subb  a,#00010000b      ; Subtract low byte of 10,000
   mov   r3,a              ; Save back
   mov   a,r2              ; Get high byte of
   subb  a,#00100111b      ; Subtract high byte of 10,000
   mov   r2,a              ; Save back
   jc    fouts14
   
   inc   dptr              ; Remainder accumulator>=10,000 so
                           ; bump up quotient accumulator
   mov   r6,0x002          ; Save new high byte remainder acc.
   mov   r7,0x003          ; Save new low byte remainder acc.

; This last section checks the remainder accumulator.  
; If this accumulator is equal to or greater than
; 5000 the quotient remainder is rounded up by 1

fouts14:

   ; Check if remainder is greater than 5000.
   ; 5,000 = 00010011 10001000b

   clr   c                 ; Clear for subb
   mov   a,r7              ; Get low byte Remainder in accumulator
   subb  a,#10001000b      ; Subtract low byte of 5,000
   mov   a,r6              ; Get high byte of
   subb  a,#00010011b      ; Subtract high byte of 5,000
   jc    fouts15
   inc   dptr              ; Bump up Quotient remainder
   
fouts15:

   ; Check if result is greater than 999 so we 
   ; pad with a zero if needed.
   ; 999 = 00000011 11100111b

   clr   c                 ; Clear for subb
   mov   a,#11100111b      ; Get low byte 999
   subb  a,dpl             ; Subtract low byte result
   mov   a,#00000011b      ; get high byte 999
   subb  a,dph             ; Subtract high byte result
   jc    fouts18       ; If carry then result>999
   mov   a,#48             ; ASCII for "0"
   lcall cout
   
fouts16:
   ; Check if result is greater than 99 so we 
   ; pad with a zero if needed.
   ; 99 = 01100011b

   clr   c                 ; Clear for subb
   mov   a,#01100011b      ; Get low byte 99
   subb  a,dpl             ; Subtract low byte result
   jc    fouts18       ; If carry then result>99
   mov   a,#48             ; ASCII for "0"
   lcall cout

fouts17:
   ; Check if result is greater than 9 so we 
   ; pad with a zero if needed.
   ; 9 = 00001001b

   clr   c                 ; Clear for subb
   mov   a,#00001001b      ; Get low byte 9
   subb  a,dpl             ; Subtract low byte result
   jc    fouts18       ; If carry then result>9
   mov   a,#48             ; ASCII for "0"
   lcall cout
   
fouts18:

; Write out final quotient remainder
   lcall dec16out
   ret