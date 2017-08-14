;-----------------------------------------------------------------;
; This routine fetches a command line argument (0,1,2,...,n)      ;                   ;    
; INPUT:       ACC         Argument to fetch.                     ;
;              COMPTR      Pointer to string with arguments.      ;
;              R0          Pointer to location to store argument. ;
; MODIFIES:    Carry Flag                                         ;
;-----------------------------------------------------------------;
argv:
   push  acc
   push  b
   push  0x0000
   push  0x0001
   push  0x0002
   
   mov   r1,comptr         ; Get copy of pointer to command input string
   mov   r2,a              ; Save copy of argument to fetch in R2
   mov   b,#0x000          ; Set initial argument count=0

argv1:
   mov   a,@r1             ; Get first character
   jz    argv_exit         ; ASCII 0? Yes, then exit
   cjne  a,#32,argv2       ; Is character a space?, Yes then get next char
   sjmp  argv3
argv2:
   lcall isascii           ; Is character a printable ASCII character
   jc    argv4             ; Yes, then increment arg counter
argv3:
   inc   r1                ; No, then point to next character
   sjmp  argv1             ; And loop again.
   
argv4:
   mov   a,b               ; Get argument#
   clr   c
   subb  a,r2              ; Is this the right argument?
   jz    argv7             ; Yes, then get string

   inc   b                 ; No, increment argument count
   
argv5:
   inc   r1                ; Increment to next character
   mov   a,@r1             ; Get character
   jz    argv_exit         ; ASCII 0? Yes, then exit
   cjne  a,#32,argv6       ; Character a space?
   sjmp  argv1             ; Yes, then look for next printable char.
argv6:
   lcall isascii           ; Is character printable ASCII?
   jnc   argv1             ; No, then find next printable char.
   sjmp  argv5             ; Yes, look for next non-printable char

argv7:
   mov   a,@r1             ; Get character
   mov   @r0,a             ; Save character
   jz    argv9             ; ASCII 0, then exit.
   cjne  a,#32,argv8       ; Is character a space?
   sjmp  argv9             ; Yes, then exit  
   lcall isascii           ; Is character a printable ASCII?
   jnc   argv9             ; No, then exit

argv8:
   inc   r1                ; Increment input string pointer
   inc   r0                ; Increment output pointer string    
   sjmp  argv7             ; Loop

argv9:  
   mov   @r0,#0x000         ; Terminate string
   
argv_exit: 

   pop   0x0002   
   pop   0x0001
   pop   0x0000
   pop   b
   pop   acc
   ret