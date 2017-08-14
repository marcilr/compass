;-----------------------------------------------------------;
; This is my new and improved routine to write out a        ;
; 16-bit unsigned in DPTR to standard output in             ;
; base 10. This routine uses the divide by 10, push         ;
; the remainder on the stack trick.                         ;
;                                                           ;
; INPUT:    DPTR              Value to write.               ;
; USES:     DIVIDE, COUT      Write value to standard out.  ;
;                                                           ;
; The main part of this routine is my own.  The             ;
; divide dec16outx routine to divide r2-r3 by r4-5 is       ;
; from the Paulmon site at:                                 ;
;     http://www.pjrc.com/tech/8051/serial_io.html          ;
;-----------------------------------------------------------;
dec16out:
   push  0x000
   push  0x001
   push  0x002
   push  0x003
   push  0x004
   push  0x005
   push  psw
   push  acc
   push  b
   
   mov   a,#255
   push  acc                  ; Push a marker onto the stack

   mov   r2,dph               ; High byte->R2
   mov   r3,dpl               ; Low byte->R3

dec16out1:
   mov   r4,#0                ; Clear High byte divisor
   mov   r5,#10               ; Divide by 10
   lcall divide               ; Divide by 10
   push  0x005                ; Save remainder
   mov   a,r2                 ; Get low byte result
   orl   a,r3                 ; OR on high byte
   jnz   dec16out1            ; Result=0, no then divide again

dec16out2:
   pop   acc                  ; Get remainder
   cjne  a,#255,dec16out3     ; Done? No, then continue
   sjmp  dec16out4            ; Yes, then exit

dec16out3:
   add   a,#48                ; Convert to ASCII 48-57 (0-9)
   lcall cout        
   sjmp  dec16out2

dec16out4:
   pop  b
   pop  acc
   pop  psw
   pop  0x005
   pop  0x004
   pop  0x003
   pop  0x002
   pop  0x001
   pop  0x000
   ret