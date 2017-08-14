;-----------------------------------------------------------;
; External Interrupt 0 handler.                             ;
;                                                           ;
; Need to drop CS before pulsing clock.                     ;
;                                                           ;
; Order of operations:                                      ;
;     1. CONV low                                           ;
;     2. CS low                                             ;
;     3. Clock out 16-bit value.                            ;
;     4. CS high                                            ;
;                                                           ;
; Clocking info:                                            ;
;     1ms = 10^-3                                           ;
;     1ns = 10^-9    1ms=1,000,000ns                        ;
;     12clock cycles @ 11.0592Mhz=                          ;
;                                                           ;
; NOTES:                                                    ;
;                                                           ;
; SCLK should not come high 2fclk+200ns after CS goes low.  ;
;  =2fclk+200ns after CS goes low.                          ;
;  =2*1/32,768=.061ms=61,035ns                              ;
;                                                           ;
;  1 NOP = 12 cycles @ 11.0592Mhz                           ;   
;        = 109ns                                            ;
;                                                           ;
; Clock Pulse width must be at least 200ns                  ;
; SCLK falling to new SDATA = 310ns max                     ;
;-----------------------------------------------------------;
extint0:
   push  psw
   push  acc
   push  dpl
   push  dph

   mov   rs0,#1                  ; Use register bank 4
   mov   rs1,#1

   jb    calflag,extint00        ; Calibration?        
   jb    convflag,extint01       ; Conversion?
   sjmp  extint02                ; Clear out A/D just in case.

extint00:
;--- Interrupt triggered by calibration
   clr   calflag                 ; Clear Calibrate flag
   setb  caldoneflag             ; Indicate Calibration complete
   sjmp  extint02

;--- interrupt triggered by conversion
extint01:
   clr   convflag                ; Clear CONV flag
   setb  convdoneflag            ; Indicate Conversion complete
   
extint02:
   lcall delayms
   
; ===>CONV low
   mov   dptr,#0x8000            ; Address for CONV low
   movx  @dptr,a                 ; Set CONV low, so we don't start 
                                 ; another conversion after this one.
   lcall delayms
   
; ===>CS low
   mov   dptr,#0x9000            ; Address for CS low
   movx  @dptr,a                 ; Set CS low, and enable A/D output.

   lcall delayms
   
; This piece of code fetches the 16-bit sensor value from
; the CS5505 A/D converter.  The first thing it does it 
; pulse CLK2 low. The rising edge of this dummy read pulse
; initializes the
; shifting mechanism of SDATA.  The falling edge of the next 
; negative pulse shifts out the MSB of the value.  Each 
; subsequent falling edge shifts out the next bit.

   mov   dptr,#0x9800            ; Address for CLK2 Pulse
   movx  a,@dptr                 ; Pulse CLK2 low

   lcall delayms

;   nop                           ; These NOPs are necessary for timing.
;   nop
;   nop
;   nop
;   nop

   mov   x,#0x000                ; Clear X value
   mov   x+1,#0x000
   
   mov   y,#0x000                ; Clear Y value
   mov   y+1,#0x000
   
   mov   z,#0x000                ; Clear Z value
   mov   z+1,#0x000

;=====> Get high bytes

   mov   r1,#8
extint03:

;---Rotate all values left 1 position

   mov   a,x+1
   rl    a
   mov   x+1,a

   mov   a,y+1
   rl    a
   mov   y+1,a

   mov   a,z+1
   rl    a
   mov   z+1,a
   
;--- Read value

   mov   dptr,#0x9800            ; address for CLK2 Pulse
   movx  a,@dptr                 ; Read A/D value

   mov   b,a                     ; Save copy of value

;--- Exact 3 low bits (x,y,z) and save them
   
   anl   a,#00000001b            ; Mask for low bit (x)
   orl   x+1,a                   ; Add bit to value
   
   mov   a,b                     ; Get value back 
   anl   a,#00000010b            ; Mask for 2nd bit (y)
   rr    a                       ; Get bit in low position
   orl   y+1,a                   ; Add bit to value
   
   mov   a,b                     ; Get value back
   anl   a,#00000100b            ; Mask for 3rd bit (z)
   rr    a                       ; Get bit in low position
   rr    a                    
   orl   z+1,a                   ; Add bit to value
   
   djnz  r1,extint03

;====> Get low bytes of (x,y,z)

   mov   r1,#8
extint04:

;---Rotate all values left 1 position

   mov   a,x
   rl    a
   mov   x,a

   mov   a,y
   rl    a
   mov   y,a

   mov   a,z
   rl    a
   mov   z,a
   
;--- Read value

   mov   dptr,#0x9800            ; address for CLK2 Pulse
   movx  a,@dptr                 ; Read A/D value

   mov   b,a                     ; Save copy of value

;--- Exact 3 low bits (x,y,z) and save them
   
   anl   a,#00000001b            ; Mask for low bit (x)
   orl   x,a                     ; Add bit to value
   
   mov   a,b                     ; Get value back 
   anl   a,#00000010b            ; Mask for 2nd bit (y)
   rr    a                       ; Get bit in low position
   orl   y,a                     ; Add bit to value
   
   mov   a,b                     ; Get value back
   anl   a,#00000100b            ; Mask for 3rd bit (z)
   rr    a                       ; Get bit in low position
   rr    a                    
   orl   z,a                     ; Add bit to value
   
   djnz  r1,extint04
 

; ===>CS high
   mov   dptr,#0x9100            ; Address to set CS high
   movx  @dptr,a                 ; Disable serial output on A/D.

   pop   dph
   pop   dpl
   pop   acc
   pop   psw
   reti
   