; Serial Port Interrupt Driven Example
; This acts like a repeater system, passing on all characters received
; Control codes are filtered out. R0 and R1 act an inptr and outptr

        inptr EQU R0            ;in_pointer
        outptr EQU R1           ;out_pointer
                 org 0h         ;power-on-reset
                 jmp main

                 org 0023h      ;serial port interrupt
                 jmp rs232
        main:    call init      ;initialise RS232 and interrupt system
        lp1:     jmp lp1        ;mainline does nothing, all interrupt driven
        init:    MOV inptr, #1  ;initialise pointers to ring buffer
                 MOV outptr, #0 ;
                 MOV TH1,  #0FDh        ;timer 1 auto-reload value
                 MOV SCON, #0D0h        ;Mode2, REN true, TI true, RI true
                 MOV TMOD, #20h ;timer 1 8 bit auto-reload mode
                 SETB TR1       ;start timer1 (TCON.6)
                 MOV IE, #90h   ;enable rs232 interrupt
                 SETB IP.4      ;high priority for serial interrupts (PS)
                 RET

        rs232:   PUSH PSW       ;interrupt handler for RS232
                 PUSH A
                 JNB RI, trans  ;if RI not set, then check transmit
                 MOV A, outptr  ;if inptr == outptr
                 SUBB A, inptr  ;
                 JZ rec1        ;then buffer is empty
                 MOV DPH, #00h
                 MOV DPL, inptr ;else *inptr++ = val
                 MOV A, SBUF    ;retrieve character into ACC
                 MOVX @DPTR, A  ;store character in buffer
                 INC inptr      ;and ++inptr
        rec1:    CLR RI         ;reset receive interrupt flag
        trans:   JNB TI, exit   ;if TI not set, check receive
                 MOV A, outptr
                 INC A          ;if ++inptr == outptr
                 SUBB A, inptr  ;
                 JZ trans1      ;    then buffer is full
                 INC outptr     ;else outptr++
                 MOV DPH, #00h
                 MOV DPL, outptr        ;and val = *outptr
                 MOVX A, @DPTR
                 ANL A, #0E0h   ;if val >= 20h then SEND(val)
                 JZ exit        ;else just ignore
                 MOVX A, @DPTR
                 MOV SBUF, A
        trans1:  CLR TI         ;reset TI
        exit:    POP A
                 POP PSW
                 RETI

                 DSEG
                 org 0h
        buffer:  DS 256         ;circular buffer
                 end
