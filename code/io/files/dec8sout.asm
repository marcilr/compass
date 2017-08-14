;--------------------------------------------------------------;
; This routine prints out the 8-bit signed (two's complemnt)   ;
; number in the ACC to standout output in decimal (base 10).   ;
;                                                              ;
; INPUT:       acc      Signed (two's complement) 8-bit        ;
;                       number to print.                       ;
; OUTPUT:               Prints signed decimal number.          ;    
; USES:        dec8out                                         ;
; MODIFIED:    None                                            ;
;                                                              ;
; NOTES:       For 8-bit two's complement values the           ;
;              range is -128 to 127.                           ;
;--------------------------------------------------------------;
dec8sout:
   push  acc
   push  psw         
   
   jnb   acc.7,dec8sout1      ; Check sign bit.
                              ; If positive just write value.
   push  acc                  ; Otherwise kick out a minus.
   mov   a,#45                ; ASCII for minus sign
   lcall cout                 ; Write minus sign.
   pop   acc                 
   dec   a                    ; Normalize
   cpl   a
dec8sout1:
   lcall dec8out              ; Write out the value.

   pop   psw
   pop   acc
   ret