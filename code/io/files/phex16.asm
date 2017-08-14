;-----------------------------------------------------;   
; This routine prints of the value of DPTR as a       ;
; 4-digit hexidecimal number.                         ;
; USES:        phex                                   ;
; DESTROYS:    NONE                                   ;
;-----------------------------------------------------;   
phex16:  
   push  acc
   mov   a,dph 
   lcall phex  
   mov   a,dpl 
   lcall phex  
   pop   acc   
   ret