;--------------------------------------------------------------;
; This function takes a 32-bit unsigned number number     		;
; and divides it by another 32-bit unsigned point number.      ;
;                                                              ;
; INPUT:    	R0       Points to MSB of 32-bit divisor        ;
;           	R0+4     Points to MSB of 32-bit dividend       ;
;                                                              ;      
; OUTPUT:   	R0       Points to MSB of 32-bit quotient       ;
;					R1			Points to MSB of 32-bit remainder.		;
;					ACC=0		No error.										;
; 					ACC=1    Error (division by zero).					;                           
;																					;
; USES:			NONE															;
; MODIFIES:		C			Carry Flag										;
;																					;
; NOTES:		This routine uses a basic restoring divison 			;
;				algorithm.														;
;--------------------------------------------------------------;
div32:
   push  0x000
   push	0x001
   push  0x002
   push  0x003
   push  0x006
   push	0x007
   push  b
            
   mov   r2,0x000          ; Get copy of R0 in R2
	
; Make room on stack for result
   mov   a,sp
   mov   r3,a
   inc   r3                ; Save ptr to result in R3
   add   a,#8
   mov   sp,a

; Check if division by 0
	mov	r0,0x002				; Get pointer to divisor
	clr	a						; Clear logical accumulator
	mov	b,#4					; Set count
DIV32_1:
	orl	a,@r0					; Add byte to logical sum
	inc	r0						; Point to next byte
	djnz	b,DIV32_1
	jnz	DIV32_2				; Not zero, then continue
	mov	b,#1					; Else, exit with error
	ljmp	div32_exit			
DIV32_2:

; Check if dividend=0
	mov	a,r2
	add	a,#4					; Get pointer to dividend
	mov	r0,a
	clr	a						; Clear logical sum
	mov	b,#4					; Get count
DIV32_3:
	orl	a,@r0
	inc	r0
	djnz	b,DIV32_3

; If dividend=0 then return 0
	jnz	DIV32_5				; Not zero, then continue
	mov	r0,0x002				; Get pointer to return value.
	mov	b,#4					; Get count
	clr	a						; Set to zero
DIV32_4:				
	mov	@r0,a					; Clear byte
	inc	r0						; Point to next byte
	djnz	b,DIV32_4
	ljmp	fdiv_exit			; Exit, no error
DIV32_5:
	
; Initialize 4 most significant bytes result=0
	mov	r0,0x003				; Get point to result
	mov	b,#4					; Get count
	mov	a,#0
DIV32_6:
	mov	@r0,a					; Clear byte
	inc	r0						; Point to next byte
	djnz	b,DIV32_6
		
; Load 4 least significant bytes result with dividend
	mov	a,0x002
	add	a,#4					; Get ptr to dividend in R0
	mov	r0,a
	mov	a,0x003
	add	a,#4					; Get ptr to low 4-bytes result in R1
	mov	r1,a
	mov	b,#4					; Get count
DIV32_7:
	mov	a,@r0					; Fetch byte
	mov	@r1,a					; Copy byte to result
	inc	r0						; Increment the pointers
	inc	r1
	djnz	b,DIV32_7
	
	mov	b,#32					; Loop 32 times
DIV32_8:

; Shift 64-bit result 1-bit left, LSB=0
	mov	a,0x003				
	add	a,#7					; Get pointer to LSB result in R0					
	mov	r0,a
	clr	c						; Clear for rotate
	mov	r6,#8					; Get count in r6
DIV32_9:
	mov	a,@r0					; Fetch byte
	rlc	a						; Shift 1-bit left
	mov	@r0,a					; Save back
	dec	r0						; Point to next byte
	djnz	r6,DIV32_9

; Subtract divisor from high 4 bytes result.
	mov	a,0x003				; Get pointer to LSB
	add	a,#3					; of high 4 bytes result in R0
	mov	r0,a
	mov	a,0x002
	add	a,#3					; Get ptr to LSB divisor in R1
	mov	r1,a  				
	clr	c						; Clear for subb
	mov	r6,#4
DIV32_10:
	mov	a,@r0					; Fetch byte from result
	subb	a,@r1					; Subtract byte from divisor
	mov	@r0,a					; Save back
	dec	r0						; Decrement ptrs
	dec	r1
	djnz	r6,DIV32_10			; Loop

; Check result of subtraction
	jc		DIV32_11				; If result negative then jump

; LSB result=1
	mov	a,0x003
	add	a,#7					; Get ptr to LSB 64-bit result in R0
	mov	r0,a					
	mov	a,@r0					; Fetch byte
	setb	acc.0					; Set LSB
	mov	@r0,a					; Save byte back
	sjmp  DIV32_13				; Continue
		
DIV32_11:
	
; Add divisor back to high 4 bytes result.

	mov	a,0x003				; Get pointer to LSB
	add	a,#3					; of high 4 bytes result in R0
	mov	r0,a
	mov	a,0x002
	add	a,#3					; Get ptr to LSB divisor in R1
	mov	r1,a				
	clr	c						; Clear for subb
	mov	r6,#4
DIV32_12:
	mov	a,@r0					; Fetch byte from result
	addc	a,@r1					; Subtract byte from divisor
	mov	@r0,a					; Save back
	dec	r0						; Decrement ptrs
	dec	r1
	djnz	r6,DIV32_12			

DIV32_13:
	djnz	b,DIV32_8			; Loop
	
; Return remainder
	mov	r0,0x003				; Get ptr to high part result in R0
	mov	a,0x002				
	add	a,#4					; Get ptr to remainder return
	mov	r1,a					
	mov	b,#4
DIV32_14:
	mov	a,@r0					; Fetch byte
	mov	@r1,a					; Put byte
	inc	r0						; Increment pointers
	inc	r1
	djnz	b,DIV32_14			; Loop
	
; Return quotient
	mov	a,0x003			
	add	a,#4					; Get ptr to low part result
	mov	r0,a
	mov	r1,0x002				; Get ptr to quotient return
	mov	b,#4					; Get count
DIV32_15:
	mov	a,@r0					; Fetch byte
	mov	@r1,a					; Put byte
	inc	r0
	inc	r1
	djnz	b,DIV32_15				; Loop
	
	clr	b						; Exit no error

div32_exit:

; Restore stack
   mov   a,sp
   clr   c
   subb  a,#8
   mov   sp,a

	mov	a,b			; Get error code

   pop   b
   pop	0x007
   pop   0x006
   pop   0x003
   pop   0x002
   pop	0x001
   pop   0x000
   ret