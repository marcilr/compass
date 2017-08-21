;-----------------------------------------------------------;
; Given an angle -90.0 to +90.0 this routine calculates     ;
; a the 16-bit ATAN.  All the math in this routine uses     ;
; signed 16.16 fixed pointnotation to simply calculations.  ;
; The high byte is wasted in most calculations, including   ;
; the table for atan(1/2^i), but I think it is a good       ;
; tradeoff.                                                 ;
;                                                           ; 
; INPUT:       R0+4  Points to 32-bit X-position in RAM     ; 
;              R0+8  Points to 32-bit Y-position in RAM     ;
;                                                           ;
; OUTPUT:      R0    Points to 32-bit in RAM,               ;
;                    R0->MSB,,,(R0+3)->LSB.                 ;
;              R0+4  X = sqrt(X^2+Y^2)                      ;
;              R0+8  Y=0                                    ;
;                                                           ;
; DESTROYS:    None.                                        ;
;                                                           ;
; Register Usage:                                           ;
;     R2       Points to Angle                              ;
;     R2+4     Points to X                                  ;
;     R2+8     Points to Y                                  ;
;     R3       Points to DA                                 ;
;     R3+4     Points to DX                                 ;
;     R3+8     Points to DY                                 ;
;     R3+12    Points to Z                                  ;
;     R6       Loop counter                                 ;
;-----------------------------------------------------------;
atan:
   push  0x000
   push  0x001                ; Save registers
   push  0x002
   push  0x003
   push  0x006
   push  psw
   push  dpl
   push  dph
   push  acc
   push  b

   mov   a,r0
   mov   r2,a                 ; Save copy of R0 pointer in R2

; Allocate space on stack for DA, DX, DY
; and save pointer in R1
   mov   a,sp                 ; Get copy of stack pointer
   mov   r3,a                 ; Save pointer in R1
   inc   r3                   ; Point to next free location
   add   a,#16                ; Make room for 4 variables
   mov   sp,a                 ; Adjust stack

; Intialize Z=0
   mov   a,r3                 
   add   a,#12                ; Get pointer to Z in R0
   mov   r0,a                 
   
   mov   @r0,#0
   inc   r0
   mov   @r0,#0
   inc   r0                   ; Z=0
   mov   @r0,#0
   inc   r0
   mov   @r0,#0

; Main Loop

   lcall send_crlf
   mov   r6,#0                ; Initialize counter
atan1:      

; DX:=X/2^i
   lcall cordicdx

; Get DY:=Y/2^i
   lcall cordicdy
   
; Get DA:=ATAN(1/2^i)
   mov   a,r6                 ; Get current count
   mov   b,#4                 ; Four bytes per value
   mul   ab                   ; Get position in ACC
   mov   dptr,#cordic_tbl     ; Get pointer to atan(1/2^i) lookup table
   lcall util_adcbad          ; DPTR:=DPTR+AB
   mov   a,r3
   mov   r0,a                 ; Get pointer to DA in R0
   lcall copy32p              ; DA:=ATAN(1/2^i)

; Check sign of Y

   mov   a,r3
   add   a,#8                 ; Get pointer to Y
   mov   r0,a
   mov   a,@r0                ; Fetch MSB of Y
   jb    acc.7,atan2          ; Jump if Y is negative
   
; X:=X+DY
   mov   a,r2
   add   a,#4                 ; Get pointer to X in R0
   mov   r0,a
   mov   a,r3                 
   add   a,#8                 ; Get pointer to DY in R1
   mov   r1,a
   lcall add32                ; X:=X+DY
   
; Y:=Y-DX
   mov   a,r2
   add   a,#8                 ; Get pointer to Y in R0
   mov   r0,a
   mov   a,r3
   add   a,#4                 ; Get pointer to DX in R1
   mov   r1,a
   lcall sub32s               ; Y:=Y-DX

; Z:=Z+DA
   mov   a,r3
   add   a,#12                ; Get pointer to Z
   mov   r0,a
   mov   a,r3
   mov   r1,a                 ; Get pointer to DA
   lcall add32                ; Z:=Z+DA
   
   sjmp  atan3                ; Loop again
atan2:

; X:=X-DY
   mov   a,r2
   add   a,#4                 ; Get pointer to X in R0
   mov   r0,a
   mov   a,r3                 
   add   a,#8                 ; Get pointer to DY in R1
   mov   r1,a
   lcall sub32s               ; X:=X-DY

; Y:=Y+DX
   mov   a,r2
   add   a,#8                 ; Get pointer to Y in R0
   mov   r0,a
   mov   a,r3
   add   a,#4                 ; Get pointer to DX in R1
   mov   r1,a
   lcall add32                ; Y:=Y+DX

; Z:=Z-DA
   mov   a,r3
   add   a,#12                ; Get pointer to Z
   mov   r0,a
   mov   a,r3
   mov   r1,a                 ; Get pointer to DA
   lcall sub32s               ; Z:=Z-DA
      
atan3:

   inc   r6                   ; Increment count
   cjne  r6,#16,atan20
   sjmp  atan_exit

atan20:
   ljmp  atan1

atan_exit:

; Copy Z to A for return
   mov   a,r3
   add   a,#12                ; Get pointer to Z
   mov   r0,a
   mov   a,r2                 ; Get pointer to A in R1
   mov   r1,a
   lcall copy32               ; A:=Z

; Deallocate stack space for DA, DX, DY
   mov   a,sp                 ; Get stack pointer
   clr   c                    ; Clear for subb
   subb  a,#16                ; Adjust stack
   mov   sp,a                 ; Save back

   pop   b
   pop   acc
   pop   dph
   pop   dpl
   pop   psw
   pop   0x006
   pop   0x003
   pop   0x002                ; Restore registers
   pop   0x001
   pop   0x000
   ret

; This subroutine calculates DX:=X/2^i
cordicdx:
   mov   a,r2
   add   a,#4                 ; Get pointer to X in R0
   mov   r0,a
   mov   a,r3
   add   a,#4                 ; Get pointer to DX in R1
   mov   r1,a                 
   lcall copy32               ; DX:=X
   mov   a,r1                 
   mov   r0,a                 ; Get pointer to DX in R0
   mov   a,r6                 ; Get count in ACC
   cpl   a                    ; Get 2's complement
   inc   a   
   lcall shift32s             ; DX:=X/2^i           
   ret


; This subroutine calculates DY:=Y/2^i
cordicdy:
   mov   a,r2
   add   a,#8                 ; Get pointer to Y in R0
   mov   r0,a
   mov   a,r3
   add   a,#8                 ; Get pointer to DY in R1
   mov   r1,a                 
   lcall copy32               ; DY:=Y
   mov   a,r1                 
   mov   r0,a                 ; Get pointer to DY in R0
   mov   a,r6                 ; Get count in ACC
   cpl   a                    ; Get 2's complement
   inc   a   
   lcall shift32s             ; DY:=Y/2^i         
   ret

