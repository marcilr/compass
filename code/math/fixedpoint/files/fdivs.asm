;--------------------------------------------------------------;
; This function takes a signed 16.16 fixed point number			;
; and divides it by another signed 16.16 fixed point number.	;
;																					;
; INPUT:			R0		Points to MSB of 32-bit divisor				;
; 					R0+4	Points to MSB of 32-bit dividend.			;
; OUTPUT:		R0		Points to MSB of 32-bit result.				;
;																					;
;																					;
; USES:			FDIV	Unsigned 16.16 by 16.16 divide.				;
;																					;
; NOTES:			This function is a wrapper for fdiv					;
;--------------------------------------------------------------;
fdivs:
	push	0x000
	push	0x001
	push	psw
	push	b
	
	mov	a,r0
	mov	b,@r0					; Fetch high byte divisor
	add	a,#4
	mov	r1,a
	mov	a,@r1					; Fetch high byte dividend
	push	acc					; Save high byte dividend on stack

; Get XOR of sign bits

   mov   c,acc.7
   anl   c,/b.7            ; C:=A & !B
   mov   ov,c              ; Save result in OV (overflow flag)

   mov   c,b.7
   anl   c,/acc.7          ; C:=!A & B

   orl   c,ov              ; C:=(A & !B) OR (!A & B) = A XOR B
   mov	ov,c					; Save in OV
   
   jnb	b.7,fdivs1			; Check sign of divisor
   lcall	bin32cpl				; If negative get 2's complement
   
fdivs1:
	clr	c						; Clear Carry
	jnb	acc.7,fdivs2		; Check sign of dividend
	push	0x000					; Save R0
   mov	r0,0x001				
   lcall	bin32cpl				; If negative get 2's complement
   pop	0x000					; Restore R0
   setb	c						; Indicate dividend was negative
   
fdivs2:
	lcall	fdiv					; Unsigned result, so just divide 

	jnc	fdivs3
	push	0x000
	mov	r0,0x001
	lcall	bin32cpl
	
	
fdivs3:

	pop	b
	pop	psw
	pop	0x001
	pop	0x000
	ret
