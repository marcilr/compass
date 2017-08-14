;--------------------------------------------------------------;
; This routine takes the unsigned decimal, ASCII 0             ;
; terminated string pointed to by R0 and returns it            ;
; as a binary number in ACC. Pretty slick:)                    ;
;                                                              ;
; INPUT:       R0       Points to decimal string to convert.   ;
; OUTPUT:      ACC                                             ;
; MODIFIES:    Carry Flag                                      ;
;--------------------------------------------------------------;
dec8in:
   push  b
   push  0x000
   push  0x001
   
   clr   a                 ; ACC:=0
dec8in1:
   push  acc               ; Save value 
   mov   a,@r0             ; Get Byte
   jz    dec8in2           ; Done? Then exit
   clr   c                 ; Clear borrow
   subb  a,#0x030          ; Convert to 0-9
   mov   r1,a              ; Save in R1
   pop   acc               ; Restore value
   mov   b,#10             ; Multiply by 10
   mul   ab                
   add   a,r1              ; Add in byte.
   inc   r0                ; Point to next byte
   sjmp  dec8in1
   
dec8in2:
   pop   acc
   
   pop   0x001
   pop   0x000
   pop   b
   ret