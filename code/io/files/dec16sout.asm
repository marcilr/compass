;--------------------------------------------------------------;
; This routine prints out the 16-bit signed (two's complemnt)  ;
; number in DPTR to standout output in decimal (base 10).      ;
;                                                              ;
; INPUT:       DPTR     Signed (two's complement) 8-bit        ;
;                       number to print. DPH high byte, DPL    ;
;                       low byte.                              ;
; OUTPUT:               Prints signed decimal number.          ;    
; USES:        dec16out, util_dptrdec                          ;
; MODIFIED:    None                                            ;
;                                                              ;
; NOTES:       The maximum range for 16-bit two's complement   ;
;              numbers is -32,768 to 32,767.                   ;
;--------------------------------------------------------------;
dec16sout:
   push  acc
   push  psw
   push  dpl
   push  dph     
   
   mov   a,dph                ; Get high byte
   jnb   acc.7,dec16sout1     ; Check sign bit.
                              ; If positive just write value.
   mov   a,#45                ; ASCII for minus sign
   lcall cout                 ; Write minus sign.

; Normalize DPTR

   lcall util_dptrdec         ; Dec DPTR by 1
   mov   a,dpl
   cpl   a
   mov   dpl,a
                              ; Complement DPTR
   mov   a,dph
   cpl   a
   mov   dph,a

dec16sout1:
   lcall dec16out             ; Write out the value.

   pop   dph
   pop   dpl
   pop   psw
   pop   acc
   ret