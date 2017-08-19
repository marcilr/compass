;--------------------------------------------------------------;
; This routine multiplies two unsigned 16.16 fixed point       ;
; numbers returning a 16.16 fixed point result.                ;                                   ;
;                                                              ;
; INPUT:    R0       Points to 32-bit multiplicand.            ;
;           R0+4     Points to 32-bit multiplier.              ;
;                                                              ;
; OUTPUT:   R0       Point to high 32-bit word result          ;
;                                                              ;
; USES:     shift32r, shift32l                                 ;
;                                                              ;
; Register Usage:                                              ;
;   R2      Points to Multiplicand                             ;
;   R2+4    Points to Multiplier.                              ;
;   R3      Points to 3rd highest word result.                 ;
;   R3+4    Points to 2nd highest word result.                 ;
;                                                              ;
; NOTES:  This routine is based on the fact that the 32-bit    ;
; value composed of bytes (x1 x2 x3 x4) multiplied by a        ;
; 32-bit value (y1 y2 y3 y4) equals the 64-bit result          ;
; divided into four words as follows:                          ;
;                                                              ;
; (x1*y1) + (x1*y2) + (x1*y3) + (x1*y4)    High word           ;
; + (y1*x2) + (y1*x3) + (y1*x4)                                ;
;                                                              ;
; (x2*y2) + (x2*y3) + (x2*y4)              3rd highest word    ;
; + (y2*x3) + (y2*x4)                                          ;
; (x3*y3) + (x3*y4) + (y3*x4)              2nd highest word    ;
; (x4*y4)                                  Low word            ;
;                                                              ;
; Since we're only allowed to return a 16.16 fixed point       ;
; value, if any of the high 16-bit words are set this          ;
; indicates an overflow.  The 3rd and 2nd highest 16-bit       ;
; values is the actual 16.16 fixed point value returned. The   ;
; low 16-bits is used to round the 2nd highest 16-bits         ;
; (fractional part fixed point value) up by one if it is equal ; 
; to or greater than 32,768=1000000000000000, this is easily   ;
; accomplished by testing the high bit and rounding up if it   ;
; is a one.                                                    ;
;                                                              ;
; This routine uses logical testing to determine if an         ;
; overflow will occur.  This is a lot faster than multiplying  ;
; the high bits to catch an overflow. There are two cases      ;
; when an overflow can occur as follows:                       ;
;                                                              ;
;  1. (x1!=0)&&((y1!=0)||(y2!=0)||(y3!=0)||(y4!=0))            ;
;  2. (y1!=0)&&((x1!=0)||(x3!=0)||(x4!=0)||(x4!=0))            ;
;                                                              ;
; If either of these conditions is true then C is set to       ;
; indicate an error and the function is exited with no changes ;
; to the input values.                                         ;
;--------------------------------------------------------------;
fmul:
   push  0x000
   push  0x001
   push  0x002
   push  0x003
   push  0x004
   push  0x005
   push  0x006
   push  0x007
   push  dpl
   push  dph
   push  b

   mov   r2,0x000       ; Get copy of R0 in R2

; Make room on stack for 6 bytes
   mov   a,sp
   mov   r3,a
   inc   r3             ; Save point to allocated bytes in R3
   add   a,#6
   mov   sp,a
   

; Check high word for overflow
   mov   r0,0x002       ; Get ptr 1st byte multiplicand in R0
   mov   a,@r0          ; Fetch first byte
   jz    fmul2          ; Zero then continue
   mov   a,0x002
   add   a,#4           ; Get point to multiplier in R0
   mov   r0,a
   sjmp  fmul3          ; Check if multiplier=0
fmul2:
   mov   a,0x002
   add   a,#4           ; Get pointer to multiplier in R0           
   mov   r0,a
   mov   a,@r0          ; Fetch 1st byte of multiplier
   jz    fmul7          ; Zero then continue

   mov   r0,0x002       ; Get pointer to multiplicand in R0
fmul3:
   clr   a              ; Clear logical sum
   mov   b,#4           ; Get logical sum of multiplicand or multiplier
fmul4:
   orl   a,@r0          ; Add byte to logical sum
   inc   r0             ; Point to next byte
   djnz  b,fmul4        ; Loop
   jnz   fmul6

; Either multiplicand or multiplier=0 so return 0

   mov   r0,0x002       ; Get ptr to return value
   mov   b,#4
fmul5:
   mov   @r0,#0         ; Return 0
   inc   r0
   djnz  b,fmul5
   clr   b              ; Indicate no error
   ljmp  fmul_exit
fmul6:
   mov   b,#1           ; Indicate Error
   ljmp  fmul_exit      ; Exit

fmul7:

; Get and store x2,x3,x4,y2,y3,y4 in available registers

   mov   r0,0x002
   inc   r0             ; Get pointer to x2
   mov   a,@r0
   mov   dpl,a          ; x2->DPL
   
   inc   r0
   mov   a,@r0          
   mov   dph,a          ; x3->DPH
   
   inc   r0
   mov   a,@r0          ; x4->R4
   mov   r4,a
   
   inc   r0
   inc   r0
   mov   a,@r0    
   mov   r5,a           ; y2->R5
   
   inc   r0
   mov   a,@r0          ; y3->R6
   mov   r6,a
   
   inc   r0
   mov   a,@r0          ; y4->R7
   mov   r7,a
   
; Result=0
   mov   r0,0x003       ; Get pointer to result
   mov   b,#6
fmul8:
   mov   @r0,#0
   inc   r0
   djnz  b,fmul8
   
   mov   r0,0x003       ; Get ptr to result in R0
   
; Get (x2*y2)+(x2*y3)+(x2*y4)+(y2*x3)+(y2*x4) 
; in high word result.

   mov   a,dpl          ; Get x2
   mov   b,r5           ; Get y2
   mul   ab   
   lcall util_add16ab   ; High word result=x2*y2

   inc   r0
   
   mov   a,dpl          ; Get x2
   mov   b,r6           ; Get y3
   mul   ab
   lcall util_add16ab   ; High word result += x2*y3
   mov   a,r5           ; Get y2
   mov   b,dph          ; Get x3
   mul   ab
   lcall util_add16ab   ; High word result += y2*x3

   inc   r0

   mov   a,dpl          ; Get x2
   mov   b,r7           ; Get y4
   mul   ab
   lcall util_add16ab   ; High word result += x2*y4
   mov   a,r5           ; Get y2
   mov   b,r4           ; Get x4
   mul   ab
   lcall util_add16ab   ; High word result += y2*x4
   mov   a,dph          ; Get x3
   mov   b,r6           ; Get y3
   mul   ab
   lcall util_add16ab   ; Low word result += x3*y3

   inc   r0
   
   mov   a,dph          ; Get x3
   mov   b,r7           ; Get y7
   lcall util_add16ab   ; Low word result += x3*y4
   mov   a,r6           ; Get y3
   mov   b,r4           ; Get x4
   mul   ab
   lcall util_add16ab   ; Low word result += y3*x4

   inc   r0

   mov   a,r4           ; Get x4
   mov   b,r7           ; Get y4
   mul   ab
   lcall util_add16ab

   mov   a,@r0          ; Get high byte of low word
   jnb   acc.7,fmul10   ; High bit=0? Yes, then continue

   dec   r0             ; Point to last byte return value     
; Round up if needed.
   mov   b,#4
   setb  c              ; Increment by 1
fmul9:
   mov   a,@r0          ; Fetch byte
   addc  a,#0
   mov   @r0,a
   dec   r0             ; Point to next byte
   djnz  b,fmul9
  
fmul10:
   mov   r0,0x003       ; Get ptr to result in R0
   mov   r1,0x002       ; Get ptr to return value in R1
   lcall copy32         ; Return result

   clr   b              ; Indicate no error
   
fmul_exit:

; Deallocate space on stack
   mov   a,sp
   clr   c
   subb  a,#6
   mov   sp,a

   mov   a,b            ; Return error code

   pop   b
   pop   dph
   pop   dpl
   pop   0x007
   pop   0x006
   pop   0x005
   pop   0x004
   pop   0x003
   pop   0x002
   pop   0x001
   pop   0x000
   ret

;--------------------------------------------------------------;
; This routine adds the value in A/B to                        ;
; the 16-bit value pointed to by R0.                           ;
;                                                              ;
; INPUT:       R0    Pointe to 16-bit value, MSB=R0, LSB=R0+1  ;
;              A/B   16-bit value, B=high byte, ACC=low byte.  ;
; DESTROYS:    ACC, C                                          ;
;--------------------------------------------------------------;
util_add16ab:
   inc   r0             ; Get ptr to low byte
   add   a,@r0             
   mov   @r0,a          ; Save low byte
   dec   r0             ; Get ptr to high byte
   mov   a,b            ; Get byte to add
   addc  a,@r0          
   mov   @r0,a          ; Save high byte
   ret