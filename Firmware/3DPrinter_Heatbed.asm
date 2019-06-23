;******************* VARIABLES DEFINITIONS *********************  
   DQ       BIT  P3.0    ; 1 wire line
   RS       EQU  P1.0
   RW       EQU  P1.1
   E        EQU  P1.2
   LCD_DATA EQU  P2
   swpH     EQU  0d2H
   swpL     EQU  0ffH
   WDLSB    DATA 30H 
   WDMSB    DATA 31H
;***************************************************************
   ORG      0000H        ; Reset vector
   MOV      50H, #90     ; This stores the target temperature value (90°C) in the address 50h
   MOV      P0, #0       ; Clear P0 ports
   LJMP     MAIN         
   ORG      000BH        ; Timer0 vector
   LJMP     TMR0
EXIT_T0:                 ; RETI was moved to here to allow the use of   
   RETI                  ; the other interrupt vectors (if necessary)
;***************************************************************
;******************** TIMER ROUTINES ***************************
TMR0:    
LCD_AT:
   MOV      A, #1        
   CALL     CONFIG       ; Clear Display
   MOV      A, #2
   CALL     CONFIG       ; Return cursor to initial position
   MOV      DPTR, #TEXT1
   MOV      R6, #0
LCD_AT2:
   MOV      A, R6
   INC      R6
   MOVC     A, @A+DPTR
   CALL     W_DAT        ; Write first text from LCD TABLE
   CJNE     R6, #8, LCD_AT2
   MOV      R6, #3
   MOV      R1, #41H
LCD_AT3:
   MOV      A, @R1
   ADDC     A, #48
   CALL     W_DAT        ; Write actual temperature on display
   INC      R1
   DJNZ     R6, LCD_AT3
LCD_AT4:      
   MOV      A, #0DFH     
   CALL     W_DAT        ; Write 'º' on display
   MOV      A, #43H      
   CALL     W_DAT        ; Write 'C' on display
   MOV      A, #16       
   CALL     W_DAT        ; Write blank character on display
   MOV      A, #192      
   CALL     CONFIG       ; Go to next line on diplay
   MOV      A, #16       
   CALL     CONFIG       
LCD_AT5:
   MOV      DPTR, #TEXT2
   MOV      R6, #0
LCD_AT6:
   MOV      A, R6
   INC      R6
   MOVC     A, @A+DPTR
   CALL     W_DAT        ; Write second text from LCD TABLE
   CJNE     R6, #8, LCD_AT6
   MOV      R6, #3
   MOV      R1, #44H
LCD_AT7:
   MOV      A, @R1
   ADDC     A, #48
   CALL     W_DAT
   INC      R1
   DJNZ     R6, LCD_AT7
LCD_AT8:      
   MOV      A, #0DFH
   CALL     W_DAT
   MOV      A, #43H
   CALL     W_DAT
   MOV      A, #16
   CALL     W_DAT

; Timer value setup
   MOV      TH0,#swpH 
   MOV      TL0,#swpL

; This subroutine compares the temperature read by the sensor DS18B20 with the target temperature
COMPARA: 
   PUSH     PSW          ; Stores PSW into the stack (to prevent data loss)
   CLR      C   
   MOV      B, 50H       ; Target temp. needs to be incremented by one due to hysteresis
   INC      B 
   MOV      A, 51H       ; This part checks if the readed temperaure
   SUBB     A, B         ; is greater than the target temperature.
   JC       DESL            
   SETB     P3.7         ; If readed temperaure is > target temperature, so p1.7 = HIGH
   JMP      BUT1         ; Jump to button press detection subroutine
DESL:    
   CLR      P3.7         ; If readed temperaure is < target temperature, so p1.7 = LOW

; This subroutine verifies if a button was pressed		 
BUT1:	 
   POP      PSW
   JB       P1.5, BUT2   ; If button 1 was not pressed, checks button 2
   JNB      P1.5, $      ; If button 1 was pressed, waits till it's released
   DEC      50H          ; When it's released, decrements target temperature
BUT2:    
   JB       P1.7, EXIT   ; If button 2 was not pressed, jump to DISP subroutine
   JNB      P1.7, $      ; If button 2 was pressed, waits till it's released
   INC      50H          ; When it's released, increments target temperature
EXIT:
   CALL     TRANS2
   JMP      EXIT_T0  
;***************************************************************
;******************** MAIN PROGRAM *****************************
MAIN:       
TOINIT:
   CLR      EA
   MOV      TMOD, #01H
   MOV      TH0, #swpH
   MOV      TL0, #swpL
   SETB     EA
   SETB     ET0
   SETB     TR0
   MOV      R2, #2
   MOV      R0, #42H   
OVER:
   MOV      @R0, #00H
   INC      R0
   DJNZ     R2, OVER  
LOOP: 
   LCALL    DSWD     
   SJMP     LOOP

; Communication with DS18B20 sensor
DSWD:
   LCALL    INIT_LCD     ; Initialize LCD1602
   LCALL    RSTSNR       ; Initialize DS18B20 
   JNB      F0, KEND     
   MOV      R0, #0CCH
   LCALL    SEND_BYTE    
   MOV      R0, #44H     
   LCALL    SEND_BYTE    ; Send a convert command
   SETB     EA
   MOV      48H, #1     
SS2: 
   MOV      49H, #255  
SS1:
   MOV      4AH, #255  
SS0: 
   DJNZ     4AH, SS0
   DJNZ     49H, SS1
   DJNZ     48H, SS2
   CLR      EA
   LCALL    RSTSNR
   JNB      F0, KEND
   MOV      R0, #0CCH       
   LCALL    SEND_BYTE
   MOV      R0, #0BEH         
   LCALL    SEND_BYTE    ; Send Read Scratchpad command 
   LCALL    READ_BYTE    ; Read the low byte from scratchpad 
   MOV      WDLSB, A     ; Save the temperature (low byte)
   LCALL    READ_BYTE    ; Read the high byte from scratchpad
   MOV      WDMSB, A     ; Save the temperature (high byte)
   LCALL    TRANS1
KEND:    
   SETB     EA
   RET   

; Convert temperature from hexadecimal to decimal format
TRANS1:
   MOV      A, 30H
   ANL      A, #0F0H
   MOV      3AH, A
   MOV      A, 31H
   ANL      A, #0FH
   ORL      A, 3AH
   SWAP     A            ; Transform temperature value on accumulator to hexadecimal
   MOV      51H, A       ; Save this value into the address 51h
   MOV      B, #10
   DIV      AB
   MOV      43H, B 
   MOV      B, #10
   DIV      AB
   MOV      42H, B
   MOV      41H, A
   RET
   
TRANS2:
   MOV      A, 50H
   MOV      B, #10
   DIV      AB
   MOV      46H, B 
   MOV      B, #10
   DIV      AB
   MOV      45H, B
   MOV      44H, A
   RET
;****************************************************************
;******************** 1 WIRE COMMUNICATION **********************
; Send a byte to the 1 wire line
SEND_BYTE:                
   MOV      A, R0
   MOV      R5, #8 
SEN3:    
   CLR      C
   RRC      A
   JC       SEN1
   LCALL    WRITE_0
   SJMP     SEN2 
SEN1:    
   LCALL    WRITE_1
SEN2:    
   DJNZ     R5,SEN3 
   RET
   
; Read a byte from the 1 wire line
READ_BYTE:                
   MOV      R5, #8 
READ1:   
   LCALL    READ
   RRC      A
   DJNZ     R5, READ1  
   MOV      R0, A
   RET
   
; Reset 1 wire line
RSTSNR:                   
   SETB     DQ
   NOP
   NOP
   CLR      DQ
   MOV      R6, #250 
   DJNZ     R6, $		
   MOV      R6, #50
   DJNZ     R6, $		
   SETB     DQ 
   MOV      R6, #15
   DJNZ     R6, $		
   CALL     CHCK 
   MOV      R6, #60
   DJNZ     R6, $		
   SETB     DQ
   RET
;****************************************************************
;************************* LCD SETUP **************************** 
; Subroutine for initializing LCD
INIT_LCD:                 
   CALL     BUSY_CHECK
   CALL     DELAY
   CLR      RS
   CLR      RW
   CLR      E 
   MOV      LCD_DATA, #3CH
   SETB     E
   CALL     WAIT
   CLR      E
   MOV      LCD_DATA, #0CH
   SETB     E
   CALL     WAIT
   CLR      E
   MOV      LCD_DATA, #01H 
   SETB     E
   CALL     WAIT
   CLR      E        
   MOV      60H, #40
REPT1:                    ; Waits ~1.53ms
   CALL     WAIT
   DJNZ     60H, REPT1
   MOV      LCD_DATA, #06H 
   SETB     E
   CALL     WAIT
   CLR      E 
   RET       

; ~55us delay subroutine   
WAIT:
   MOV      62H, #55
   DJNZ     62H, $
   RET
   
; ~30ms delay subroutine
DELAY:                    
   MOV      60H, #0FAH
REPT3:
   MOV      61H, #78H
   DJNZ     61H, $
   DJNZ     60H, REPT3
   RET 

; Subroutine that checks if LCD is busy
BUSY_CHECK:                
   CLR      E              
   CLR      RS             
   SETB     RW             
   MOV      LCD_DATA ,#0FFH    
   SETB     E              
   JB       P2.7, BUSY_CHECK
   CLR      E              
   CLR      RW             
   RET 
   
; Subroutine that writes data in LCD   
W_DAT:                     
   CLR      E              
   SETB     RS             
   CLR      RW             
   ;CALL     WAIT           
   SETB     E              
   CALL     BUSY_CHECK     
   ;CALL     WAIT           
   MOV      LCD_DATA, A    ; Load data to P2
   CALL     WAIT           
   CLR      E              
   ;CALL     WAIT           
   RET   

; Subroutine for configuration 
CONFIG:                    
   CLR      E              
   CLR      RS             
   CLR      RW             
   ;CALL     WAIT           
   SETB     E              
   CALL     BUSY_CHECK    
   ;CALL     WAIT           
   MOV      LCD_DATA, A    ; Load data to P2
   CALL     WAIT           ;       
   CLR      E              
   ;CALL     WAIT           
   RET 
;****************************************************************   
;******************** LOW LEVEL SUBROUTINES *********************
CHCK:    
   MOV      C, DQ
   JC       RST0
   SETB     F0	  
   SJMP     CHCK0 
RST0:    
   CLR      F0
CHCK0:   
   RET		  
;****************************************************************
WRITE_0: 
   CLR      DQ
   MOV      R6, #30
   DJNZ     R6, $
   SETB     DQ
   RET
;****************************************************************
WRITE_1: 
   CLR      DQ 
   NOP
   NOP
   NOP
   NOP
   NOP
   SETB     DQ
   MOV      R6, #30
   DJNZ     R6, $
   RET
;****************************************************************
READ:    
   SETB     DQ 
   NOP
   NOP
   CLR      DQ
   NOP
   NOP
   SETB     DQ 
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   MOV      C, DQ
   MOV      R6, #23
   DJNZ     R6, $
   RET
;****************************************************************
;************************** LCD TABLE ***************************
TEXT1:
   DB       'A.TEMP: '
TEXT2:
   DB       'T.TEMP: '
   
   END
