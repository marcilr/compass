;--------------------------------------------------------------;
; This function takes an unsigned 16.16 fixed point number     ;
; and divides it by another 16.16 fixed point number.          ;
;                                                              ;
; INPUT:    R0       Points to MSB of 32-bit divisor           ;
;           R0+4     Points to MSB of 32-bit dividend          ;
;                                                              ;      
; OUTPUT:   R0       Points to MSB of 32-bit quotient          ;
;                                                              ;
; NOTES: This function works fine but there is a lot of        ;
; room for improvement.  It uses a standard restoring-division ;
; algorithm. It consumes a lot of stack space and CPU cycles.  ;
; I'd like to have a try at a non-restoring division algorithm ;
; sometime which are reportedly a bit more efficient.          ;
;                                                              ;
; Basic idea from:                                             ;
;  http://www.ednmag.com/reg/1997/050897/10df_05.htm           ;
;--------------------------------------------------------------;
fdiv:
   push  0x000
   push  0x001
   push  0x002
   push  0x003
   push  0x006
   push  0x007
   push  psw
   push  b
            
   mov   r2,0x000          ; Get copy of R0 in R2
   
; Make room on stack for result
   mov   a,sp
   mov   r3,a
   inc   r3                ; Save ptr to result in R3
   add   a,#12
   mov   sp,a

; Make room on stack for 6-byte divisor.
   mov   a,sp
   mov   r4,a              ; Save ptr to 6-byte divisor in R4
   inc   r4
   add   a,#6
   mov   sp,a

; Check if division by 0
   mov   r0,0x002          ; Get pointer to divisor
   clr   a                 ; Clear logical accumulator
   mov   b,#4              ; Set count
FD1:
   orl   a,@r0             ; Add byte to logical sum
   inc   r0                ; Point to next byte
   djnz  b,FD1
   jnz   FD2               ; Not zero, then continue
   mov   b,#1              ; Else, exit with error
   ljmp  fdiv_exit         
FD2:

; Check if dividend=0
   mov   a,r2
   add   a,#4              ; Get pointer to dividend
   mov   r0,a
   clr   a                 ; Clear logical sum
   mov   b,#4              ; Get count
FD3:
   orl   a,@r0
   inc   r0
   djnz  b,FD3

; If dividend=0 then return 0
   jnz   FD5               ; Not zero, then continue
   mov   r0,0x002          ; Get pointer to return value.
   mov   b,#4              ; Get count
   clr   a                 ; Set to zero
FD4:           
   mov   @r0,a             ; Clear byte
   inc   r0                ; Point to next byte
   djnz  b,FD4
   ljmp  fdiv_exit         ; Exit, no error
FD5:
   
; Initialize 6 most significant bytes result=0
   mov   r0,0x003          ; Get point to result
   mov   b,#6              ; Get count
   mov   a,#0
FD6:
   mov   @r0,a             ; Clear byte
   inc   r0                ; Point to next byte
   djnz  b,FD6
      
; Load low 6 bytes result with dividend*(2^16)
   mov   a,r2
   add   a,#4              ; Get ptr to dividend in R0
   mov   r0,a
   mov   a,r3
   add   a,#6              ; Get ptr to low 6-bytes result in R1
   mov   r1,a
   mov   b,#4              ; Get count
FD7:
   mov   a,@r0             ; Fetch byte
   mov   @r1,a             ; Copy byte to result
   inc   r0                ; Increment the pointers
   inc   r1
   djnz  b,FD7
   clr   a
   mov   @r1,a             ; Clear low two 2-byte result
   inc   r1
   mov   @r1,a
   
; Initialize 6-byte divisor
   mov   r0,0x004          ; Get pointer to temp 6-byte divisor
   clr   a
   mov   @r0,a             
   inc   r0                ; Clear high two bytes
   mov   @r0,a             
   inc   r0                ; Get pointer to low 4-bytes in R0
   mov   r1,0x002          ; Get pointer to divisor in R1
   mov   b,#4
FD75:
   mov   a,@r1             ; Fetch byte
   mov   @r0,a             ; Put byte
   inc   r0                ; Increment ptrs
   inc   r1
   djnz  b,FD75            ; Loop
   
   mov   b,#48             ; Loop 48 times
FD8:
   
; Shift 96-bit result 1-bit left, LSB=0
   mov   a,r3           
   add   a,#11             ; Get pointer to LSB result in R0               
   mov   r0,a
   clr   c                 ; Clear for rotate
   mov   r6,#12            ; Get count in r6
FD9:
   mov   a,@r0             ; Fetch byte
   rlc   a                 ; Shift 1-bit left
   mov   @r0,a             ; Save back
   dec   r0                ; Point to next byte
   djnz  r6,FD9

; Subtract divisor from high 6 bytes result.
   mov   a,r3              ; Get pointer to LSB
   add   a,#5              ; of high 6 bytes result in R0
   mov   r0,a
   mov   a,r4
   add   a,#5              ; Get ptr to LSB divisor in R1
   mov   r1,a              
   clr   c                 ; Clear for subb
   mov   r6,#6
FD10:
   mov   a,@r0             ; Fetch byte from result
   subb  a,@r1             ; Subtract byte from divisor
   mov   @r0,a             ; Save back
   dec   r0                ; Decrement ptrs
   dec   r1
   djnz  r6,FD10           ; Loop

; Check result of subtraction
   jc    FD11              ; If result negative then jump

; LSB result=1
   mov   a,r3
   add   a,#11             ; Get ptr to LSB 96-bit result in R0
   mov   r0,a              
   mov   a,@r0             ; Fetch byte
   setb  acc.0             ; Set LSB
   mov   @r0,a             ; Save byte back
   
   sjmp  FD13              ; Continue
      
FD11:
   
; Add divisor back to high 4 bytes result.   
   mov   a,r3              ; Get pointer to LSB
   add   a,#5              ; of high 6 bytes result in R0
   mov   r0,a
   mov   a,r4
   add   a,#5              ; Get ptr to LSB divisor in R1
   mov   r1,a           
   clr   c                 ; Clear for subb
   mov   r6,#6
FD12:
   mov   a,@r0             ; Fetch byte from result
   addc  a,@r1             ; Subtract byte from divisor
   mov   @r0,a             ; Save back
   dec   r0                ; Decrement ptrs
   dec   r1
   djnz  r6,FD12        

FD13:
   djnz  b,FD8             ; Loop
   
; Return quotient
   mov   a,r3              
   add   a,#8              ; Get ptr to low 4-bytes result
   mov   r0,a
   mov   r1,0x002          ; Get pointer to return 
   mov   b,#4
FD14:
   mov   a,@r0             ; Fetch byte
   mov   @r1,a             ; Put byte
   inc   r0
   inc   r1
   djnz  b,FD14
      
   clr   b              ; Exit no error

fdiv_exit:

; Restore stack
   mov   a,sp
   clr   c
   subb  a,#18
   mov   sp,a

   mov   a,b         ; Get error code

   pop   b
   pop   psw
   pop   0x007
   pop   0x006
   pop   0x003
   pop   0x002
   pop   0x001
   pop   0x000
   ret