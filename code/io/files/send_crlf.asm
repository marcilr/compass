;-----------------------------------------------------;
; This routine just sends a return-linefeed pair to   ;
; standard output.                                    ;
; USES:        cout, cr, lf                           ;
; MODIFIES:    None                                   ;
;-----------------------------------------------------;
send_crlf:
   push  acc  

   mov   a,#cr      
   lcall cout                   
   mov   a,#lf
   lcall cout
   
   pop   acc
   ret