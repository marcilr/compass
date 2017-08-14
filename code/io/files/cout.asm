;-----------------------------------------------------;
; This routine send a character out the serial port   ;
; INPUT:       ACC      Character to send             ;
; MODIFIES:    None                                   ;
; NOTES:       This routines works in conjunction     ;
;              will the rs232 interrupt handler.      ;
;-----------------------------------------------------;
cout:
   push  psw
   push  0x000                   ; Save r0
   push  0x001                   ; Save r1
  
   mov   r1,txtail               ; Save copy of tail
   inc   txtail                  ; Increment to next position
   anl   txtail,#txbuf+txsize-1  ; Wrap pointer if needed
   mov   r0,txtail               ; Get ready for comparison
   
cout1:
   cjne  r0,#txhead,cout2        ; Space in transmit buffer?
   sjmp  cout1                   ; No, then loop

cout2:
   mov   @r1,a                   ; Save char to buffer
   jb    txflag,*                ; Transmitting? Yes, then wait.
   setb  ti 
 
   pop   0x001
   pop   0x000
   pop   psw
   ret