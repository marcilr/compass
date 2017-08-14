;--------------------------------------------------------;
; This routine prints the value in Acc as a two-digit    ;
; hexidecimal number. Acc is not changed. This routine   ;
; tends to be very useful for troubleshooting by simply  ;
; inserting calls to PHEX within troublesome code.       ;
; USES:        COUT                                      ;
; DESTROYS:    NONE                                      ;
;--------------------------------------------------------;
phex:
phex8:   
   push  acc   
   swap  a  
   anl   a, #15   
   add   a, #246  
   jnc   phex_b   
   add   a, #7
phex_b: 
   add   a, #58   
   lcall cout  
   pop   acc
phex1:   
   push  acc   
   anl   a, #15   
   add   a, #246
   jnc   phex_c   
   add   a, #7
phex_c: 
   add   a, #58   
   lcall cout  
   pop   acc   
   ret