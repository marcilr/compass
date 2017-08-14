;==================== RS232 Handler ================================>
;==================== RS232 Handler ================================>

;-----------------------------------------;
; UART Interrupt Handler.                 ;
;                                         ;
; txflag=1  Character in ACC to send      ;
; txflag=0  No character to send.         ;
;                                         ;
;-----------------------------------------;     
rs232:
   push  psw
   push  acc
   push  0x000                   ; Push r0
   push  0x001                   ; Push r1
   
   jnb   ri,xmit1
   
   clr   ri                      ; Clear interrupt
   mov   a,sbuf                  ; Get character

   mov   r1,rxtail               ; Get copy of pointer
   inc   rxtail                  ; Increment pointer
   anl   rxtail,#rxbuf+rxsize-1  ; Wrap if needed
   mov   r0,rxtail               ; Get copy of new pointer
   cjne  r0,#rxhead,rec1         ; Space in transmit buffer?
   mov   rxtail,#rxbuf           ; No, then reset buffer
   mov   rxhead,#rxbuf
     
   sjmp  rec2                    ; Continue
rec1:
   mov   @r1,a                   ; Yes, save char to buffer
   cjne  a,#13,rec2              ; Is char a carriage return?
   setb  comflag                 ; Yes, then set command flag.
   mov   @r1,#0x000              ; Terminate string
   sjmp  exit                    ; No, need to transmit cr
   
rec2:
   mov   sbuf,a                  ; Echo Character
   setb  txflag                  ; Indicate transmitting
   sjmp  exit
 
; Check for character to transmit:

xmit1:
   jnb   ti,exit                 ; Character to transmit?
   clr   ti                      ; Yes, clear transmit interrupt

   mov   a,txhead                ; Get pointer to next char to send.
   cjne  a,txtail,xmit2          ; Data to send?
   clr   txflag                  ; No, then bail
   sjmp  exit

xmit2:
   mov   r0,a                    ; Get pointer
   mov   sbuf,@r0                ; Send char to UART
   inc   txhead                  ; Increment pointer
   anl   txhead,#txbuf+txsize-1  ; Wrap if needed
   setb  txflag                  ; Indicate transmitting

exit:
   pop   0x001                   ; Pop r1
   pop   0x000                   ; Pop r0
   pop   acc   
   pop   psw
   reti 
