

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
; Configuration data 
; PICmicro MCU type: 16F88 
; Oscillator: RC mode, slow, VR1 fully anticlockwise (min.rate) 
; LCD display: off 
; 7-segment display: off 
; Version 3 board settings: J14 links: Digital 
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
; The following lines embed configuration data into the PICmicro
	LIST P=16F88
	__CONFIG H'2007', H'3F7A'       ; RC mode
	__CONFIG H'2008', H'3FFC'       ; Clock Fail-Safe disabled
	
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
				
; setting Port B to output mode and turn on each led in sequence followed by turning each led off in sequence repeatedly.
; a short delay subroutine is called after each led on/off step
				
	ORG	0		; Reset vector
	GOTO 5		; Goto start of program
	ORG	 4		; Interrupt vector
	GOTO 5		; Goto start of program
	ORG	 5		; Start of program memory

;ASSEMBLER DIRECTIVES FOLLOW BELOW

STATUS    EQU       H'03'
Z         EQU       2
ANSEL     EQU       H'96'
PORTB     EQU       H'06'
TRISB     EQU       H'86'
PORTA     EQU       H'05'
TRISA     EQU       H'85'
TRISB     EQU	    H'86'
PAGE      EQU       5
COUNT1    EQU       H'20'
COUNT2	  EQU	    H'21'
PCL       EQU       H'02'
DIGIT1    EQU       H'23'
DIGIT2    EQU       H'24'
DIGIT3    EQU       H'25'
DIGIT4    EQU       H'26'
W	      EQU	    0
PCL       EQU       H'02'


;THE STEPS BELOW SET UP PORTB AND PORTA OUTPUT PORTS BY WRITING ALL ZEROS INTO THE PORTS DIRECTION REGISTERS WHICH ARE
;LOCATED IN PAGE1. THUS IT IS NECCESSARY TO CHANGE TO PAGE1 TO DO THIS AND CHANGE BACK TO PAGE0 WHEN DONE.
;PAGE0 IS SELECTED BY DEFAULT.


;0000 to 9999 display on 7-SegDisplay code 

MAIN_1	CLRF	PORTB		          ; set all Port B pins to logic 0
        CLRF    PORTA
	BSF	STATUS,5		; instruct program that Page 1 commands come next
	    CLRF    ANSEL		          ; clear ANSEL register to make port pins digital
        CLRF    TRISA
	   CLRF	    TRISB		          ; set all Port B pins as outputs from within Page 1 USING PORTB DIRECTION REGISTER DIRB
	BCF	STATUS,5	 	; instruct program that Page 0 commands come next	
	   CLRF  	DIGIT1                 ;clear DIGIT1
	   CLRF	    DIGIT2                 ;clear DIGIT2
	   CLRF	    DIGIT3                 ;clear DIGIT3
	   CLRF	    DIGIT4                 ;clear DIGIT4


START	MOVLW    D'1'             ;move literal value digit 1 to working register
        MOVWF    COUNT2             ;move contents of COUNT2 to to working register w



COUNT_1 MOVLW    D'10'
        MOVWF    COUNT1



MAIN	MOVF     DIGIT4,W
	CALL     TABLE
        MOVWF    PORTB
        MOVLW    D'08'
        MOVWF    PORTA
	CALL     DELAY

	    MOVF     DIGIT3,W
	CALL     TABLE
	    MOVWF    PORTB
	    MOVLW    D'04'
	    MOVWF    PORTA
	CALL     DELAY

	    MOVF     DIGIT2,W
	CALL     TABLE
        MOVWF    PORTB
        MOVLW    D'02'
        MOVWF    PORTA
	CALL     DELAY

	    MOVF     DIGIT1,W
	CALL     TABLE
        MOVWF    PORTB
        MOVLW    D'01'
        MOVWF    PORTA
	CALL     DELAY



	DECF     COUNT1
	BTFSS    STATUS, Z
	GOTO     MAIN

	DECF     COUNT2
	BTFSS    STATUS, Z

	GOTO     COUNT_1
	CALL     COUNTER

	GOTO     START


COUNTER	INCF     DIGIT4
	MOVF     DIGIT4,W
	ADDLW    H'F6'
	BTFSS    STATUS, Z
	GOTO     FINISH
	CLRF     DIGIT4
	INCF     DIGIT3
	MOVF     DIGIT3,W 
	ADDLW    H'F6'
	BTFSS    STATUS, Z
	GOTO     FINISH 
	CLRF     DIGIT3

        INCF     DIGIT2
	MOVF     DIGIT2,W
	ADDLW    H'F6'
	BTFSS    STATUS, Z
	GOTO     FINISH
	CLRF     DIGIT2
	INCF     DIGIT1
	MOVF     DIGIT1,W 
	ADDLW    H'F6'
	BTFSS    STATUS, Z
	GOTO     FINISH 
	CLRF     DIGIT1

FINISH  RETURN 

TABLE     ADDWF    PCL,F         ; this the "look up table " 
          RETLW    H'C0'         ;H'C0' is the corresponding hex code for showing number 0 on the display
          RETLW    H'F9'        ; H'F9' is the corresponding hex code for showing number 1 on the display
          RETLW    H'A4'        ; H'A4' is the corresponding hex code for showing number 2 on the display
          RETLW    H'B0'        ; H'B0' is the corresponding hex code for showing number 3 on the display
          RETLW    H'99'        ; H'99' is the corresponding hex code for showing number 4 on the display
          RETLW    H'92'        ; H'92' is the corresponding hex code for showing number 5 on the display
          RETLW    H'83'        ; H'83' is the corresponding hex code for showing number 6 on the display
          RETLW    H'F8'       ;  H'F8' is the corresponding hex code for showing number 7 on the display
          RETLW    H'80'        ; H'80' is the corresponding hex code for showing number 8 on the display
          RETLW    H'98'        ; H'98' is the corresponding hex code for showing number 9 on the display


   ;DELAY SUBROUTINE FOLLOWS BELOW

DELAY     MOVLW     H'ff'               ; this is the delay subroutine which loads
LOOP      ADDLW     H'FF'               ; the working register W with a number delayval
          BTFSS     STATUS,Z               ; and counts it down to zero thus creating a delay.
          GOTO      LOOP                   ; when finished it returns to the calling (main) routine
          RETURN    			
          END                              ; final statement, required to end the program 