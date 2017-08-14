;-----------------------------------------------------;
; This routine writes out the 16-byte value in STR.   ;
; It prints the ASCII code and character if it is     ;
; printable.                                          ;
;                                                     ;
; INPUT:       NONE                                   ;
; OUTPUT:      Writes out contents of STR             ;
; USES:        ISASCII, DEC8OUT, SEND_SPACE, COUT     ;
; MODIFIES:    Carry Flag                             ;
;-----------------------------------------------------;
strout:
   push  acc
   push  0x000
   push  0x001
   
   mov   r0,#str        ; Get point to string storage
   mov   r1,#16         ; Set count to length of buffer
   
   lcall send_crlf
strout1:
   mov   a,@r0          ; Get character
   lcall send_crlf      ; Send line feed
   lcall dec8out        ; Write ASCII value
   lcall send_space     ; Write a space
   lcall isascii        ; Check if printable
   jnc   strout2        ; No, then print '*'
   lcall cout           ; Yes, print char as is.
   sjmp  strout3
strout2:   
   mov   a,0x02A        ; Get '*' char in ACC
   lcall cout           ; Print it
strout3:
   inc   r0             ; Point to next char.
   djnz  r1,strout1

   pop   0x001
   pop   0x000
   pop   acc
   ret