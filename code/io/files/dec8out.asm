;-----------------------------------------------------;
; This routine prints out the 8-bit unsigned number   ;
; in the ACC to standout output in decimal (base 10). ;
; INPUT:    acc      8-bit number to print            ;
; OUTPUT:            Prints decimal number.           ;    
; USES:     cout                                      ;  
;-----------------------------------------------------;
dec8out:
   push  acc
   push  b
   
   mov   b,#255
   push  b                    ; Push a marker onto the stack

dec8out1:
   mov   b,#10
   div   ab                   ; Divide by 10
   push  b                    ; Save remainder
   jnz   dec8out1             ; Result=0, no then divide again

dec8out2:
   pop   acc                  ; Get remainder
   cjne  a,#255,dec8out3      ; Done? No, then continue
   sjmp  dec8out4             ; Yes, then exit

dec8out3:
   add   a,#48                ; Convert to ASCII 48-57 (0-9)
   lcall cout        
   sjmp  dec8out2

dec8out4:
   pop   b
   pop   acc
   ret