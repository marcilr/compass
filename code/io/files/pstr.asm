;--------------------------------------------------------;
; This routine prints out a string in PSTORE.            ;
; INPUT:    dptr     Points to string in ROM to print.   ;
; OUTPUT:            Write string to serial port.        ;
; USES:     cout                                         ;
; MODIFIES: none                                         ;
;--------------------------------------------------------;
pstr: 
   push  acc
   push  dpl
   push  dph
pstr1:
   mov   a,#0x000
   movc  a,@a+dptr            ; Get character
   lcall cout                 ; Print character
   inc   dptr                 ; Point to next char
   jnz   pstr1                ; Done?
pstr2:
   pop   dph
   pop   dpl
   pop   acc
   ret