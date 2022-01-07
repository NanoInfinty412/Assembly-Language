INCLUDE 'derivative.inc'
; export symbols
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on
            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack
			XDEF Entry, RTI_ISR
            ; LCD References        
            ; Potentiometer References
            xref pot_value
            xref read_pot 
            xref init_LCD
            xref display_string      
; variable/data section

my_variable: SECTION 
disp1: ds.b 50 ; bytes for the user info display
disp2: ds.b 50 ; for the main menu
temp: ds.b 50 ; for unexpected error/ messages
password: dc.b "00000000";
user: dc.b 8;
counter equ 8
key ds.b 1;
val1 ds.b 1;
val2         ds.b  1; defines variable 
val3         ds.b  1; defines variable
toggle       ds.b  1; defines variable 

my_constants: SECTION
port_u        equ  $268 ; Initialize Port U 0-3 and 4-7 as I/0
port_u_ddr    equ  $26A; data direction register of Port U 0-3 and 4-7 as I/0
port_u_ppr    equ  $26D; Polarity select register to set pins 0-3 as pull-up/down if $f0/$ff
port_u_enable equ  $26C; the Pull Device Enable Register, enabled/unabled if $0F/$FF
port_s        equ  $248; Port_s to be used for Leds | $FF output 
port_s_ddr    equ  $24a; Leds as output if $FF 
RTIFLG equ $0037  ; Real time interrupt flag
RTIENA equ $0038  ; Interrupt enable register
RTICTL: equ $003B; RTI control register address RTICL | For duty cycle manip
INTCR: equ $1E ; The register to enable the IRQ
Port_t equ $240 ; dipswitches
Port_t_DDR equ $242 ; Used as input set $00


 
sequence1  dc.b  $70, $B0, $D0, $E0, $00 ; sequence1 to be used to scan all four rows
sequence2  dc.b  $eb, $77, $7b, $7d, $b7, $bb, $bd, $d7, $db, $dd, $e7, $ed, $7e, $be, 
$de,$ee, $ff; sequence2 to be used

; code section 
MyCode:     SECTION
Entry:
	_Startup:
	   ;User information:
	   movb #'U',disp1+0
	   movb #'s',disp1+1
	   movb #'e',disp1+2
	   movb #'r',disp1+3
	   movb #'n',disp1+4
	   movb #'a',disp1+5
	   movb #'m',disp1+6
	   movb #'e',disp1+7
	   movb #':',disp1+8
	   movb #'E',disp1+9
	   movb #'c',disp1+10
	   movb #'e',disp1+11
	   movb #'3',disp1+12
	   movb #'6',disp1+13
	   movb #'2',disp1+14
	   movb #0,disp1+15
	   movb #'P',disp1+16
	   movb #'a',disp1+17
	   movb #'s',disp1+18
	   movb #'s',disp1+19
	   movb #'w',disp1+20
	   movb #'o',disp1+21
	   movb #'r',disp1+22
	   movb #'d',disp1+23
	   movb #':',disp1+24
	   ;display screen 2 : Main menu
	   movb #'M',disp2
	   movb #'a',disp2+1
	   movb #'i',disp2+2
	   movb #'n',disp2+3
	   movb #' ',disp2+4
	   movb #'m',disp2+5
	   movb #'e',disp2+6
	   movb #'n',disp2+7
	   movb #'u',disp2+8
	   movb #0,disp2+9
	   movb #'1',disp2+10
	   movb #'2',disp2+11
	   movb #':',disp2+12
	   movb #'4',disp2+13
	   movb #'7',disp2+14
	   movb #'p',disp2+15
	   movb #'m',disp2+16
	   movb #'-',disp2+17
	   movb #'4',disp2+18
	   movb #'/',disp2+19
	   movb #'19',disp2+20
	   movb #'/',disp2+21
	   movb #'2',disp2+22
	   movb #'0',disp2+23
	   movb #'2',disp2+24
	   movb #'0',disp2+25
	   movb #'-',disp2+26    ;string terminator, acts like '\0'    
	LDS #__SEG_END_SSTACK
	   jsr init_LCD
	start0: jsr read_pot
        ldd pot_value ; loads the variables implemented 
        ldx #100
		idiv
    exg x,d ; exchange quotient with remainder in d
    addd #$30 ; convert to its ASCII equivalent
    stab disp2+27; write the value/100 of the potentiometer to LCD
    exg x,d;
    ldx #10
    idiv
    exg x,d
    addd #$30
    stab disp2+28;write the value/10 of the potentiometer to LCD
    exg x,d; exchange x with d 
    addd #$30 ; add $30 to find the corresponding ASCII
    stab disp2+29; 
	;--Print strings on LCD---
    ldd #disp1; load #disp1 to register d 
    jsr display_string;
	;--Read the Keypad--
	bset port_u,#$F0; set port_U
	bset port_u_ddr, #$F0; set the port_u_ddr so bits 0-3 and 4-7 are I/0
	bset port_u_ppr, #$F0; set the port_s_ddr so bits 0-3 are a pull-up device
	bset port_u_enable, #$0F; set to enable the pull-up device on pins 0-3
	bclr val2, #$ff; clear val2
	clr  toggle
	store:  
		ldx  #sequence1 ; loads sequence1 into x
        ldy  #sequence2; loads sequence2 into y
        ldab   #0 ; starts at 0
	start:  
		ldaa  1,x+; increments x and goes to the next element in the array.
        cmpa  #$00 ; operates comparison
        beq   store ; Check if we have reached the terminator
        staa  port_u ; sequence sent to port_U
        jsr   debounce ;delay debounce
        ldaa  port_u; read port_u
        staa  val3; store port_u at val3
        brset port_u,#$0f, start; branch and check for the next element in the sequence if not found!        
		loop1:
			ldaa 1,y+  ; use look-up table and check the sequence to find the corresponding value
			cmpa val3; compare to val3 or key
			beq storeval;
			incb; increment and branch again
			bra loop1		
		debounce:
			pshy; push y
			ldy #1000
		delay:   dey
			bne delay
			puly  
			rts
		storeval:
			stab key;
		done:    
			stab key; stores b at key
		rts; return subroutine
	;user input of password
	ldy #24
	access:
		incy; 
		ldaa counter;
		cmpa #0;
		beq done; 8-characters length reached 
		deca; decrement a
		staa counter; store it back
		ldx user; load the starting address of the array into x 
		ldab key; 
		stab 1,x+; store the password by the user to x	
		movb #'*',disp1+y
		ldd #disp1; load #disp1 to register d 
		jsr display_string;
		bra access; always branch unless counter is zer0
	ldaa #0
	validity:
		cmpa counter;
		bra equal
		inca
		ldd password;
		cmpd 1,x+
		bne noteq; not equal
		bra validity; same character
	noteq:	;not equal
		movb #'E',temp+0
		movb #'R',temp+1
		movb #'R',temp+2
		movb #'o',temp+3
		movb #'R',temp+4
		ldd #temp; load #disp1 to register d 
		jsr display_string;
		bra start;
		bra validity;
	equal: ; Right Password - Display Main menu
		movb #0,temp+0
		movb #'0'temp+1
		movb #'.'temp+2
		movb #' 'temp+3
		movb #'S',temp+4
		movb #'t',temp+5
		movb #'a',temp+6
		movb #'t',temp+7
		movb #'u',temp+8
		movb #'s',temp+9
		ldd #temp; load #temp to register d 
		jsr display_string;
	choice: 
		jsr start; go back to start and wait for a user input
		ldaa key;
		cmpa #0; wait for 0 to go to menu
		beq menu
		bneq start; go back to start if wrong entry		
	;-----
	bset port_s_DDR, $FF; makes LED outputs
	bclr port_s, $FF; 
 
	h:
		jsr harvest
	p:
		jsr plant; After planting, branch to cylcle of watering 1
	case1:
		jsr row1
		jsr start; wait for user choice
		ldaa key
		cmpa #1; if harvest is not selected 
		bneq p; branch to plant
		beq h; otherwise, branch to harvest
		rts
	case2:
		jsr row2
		jsr start; wait for user choice
		ldaa key
		cmpa #1; if harvest is not selected 
		bneq p; branch to plant
		beq h; otherwise, branch to harves
		rts
	case3:
		jsr row3
		jsr start; wait for user choice
		ldaa key
		cmpa #1; if harvest is not selected 
		bneq p; branch to plant
		beq h; otherwise, branch to harves
		rts
	case4:
		jsr row4
		jsr start; wait for user choice
		ldaa key
		cmpa #1; if harvest is not selected 
		bneq p; branch to plant
		beq h; otherwise, branch to harves
		rts
	menu: ; initialize row choices 
		movb #'1',temp+0
		movb #'.',temp+1
		movb #' ',temp+2
		movb #'R',temp+3
		movb #'o',temp+4
		movb #'w',temp+5
		movb #'1',temp+6
		movb #0,temp+7
		movb #'2',temp+8
		movb #'.',temp+9
		movb #' ',temp+10
		movb #'R',temp+11
		movb #'o',temp+12
		movb #'w',temp+13
		movb #'2',temp+14
		movb #0,temp+15
		movb #'3',temp+16
		movb #'.',temp+17
		movb #' ',temp+18
		movb #'R',temp+19
		movb #'o',temp+20
		movb #'w',temp+21
		movb #'3',temp+22
		movb #0,temp+23
		movb #'4',temp+24
		movb #'.',temp+25
		movb #' ',temp+26
		movb #'R',temp+27
		movb #'o',temp+28
		movb #'w',temp+29
		movb #'4',temp+30
		movb #0,temp+31
		ldd #temp; load #temp to register d 
		jsr display_string;
		jsr start;
		rts;
	row1:
		movb #'P',temp+0
		movb #'.',temp+1
		movb #'.',temp+2
		movb #'.',temp+3
		movb #'.',temp+4
		movb #'.',temp+5
		movb #'R',temp+6
		movb #'o',temp+7
		movb #'w',temp+8
		movb #'1',temp+9
		movb #'.',temp+10
		movb #'.',temp+11
		movb #'.',temp+12
		movb #'.',temp+13
		movb #'.',temp+14
		movb #'.',temp+15
		movb #'H',temp+16
		movb #0,temp+17
		ldd #temp; load #temp to register d 
		jsr display_string;
		rts
	row2:
		movb #'P',temp+0
		movb #'.',temp+1
		movb #'.',temp+2
		movb #'.',temp+3
		movb #'.',temp+4
		movb #'.',temp+5
		movb #'R',temp+6
		movb #'o',temp+7
		movb #'w',temp+8
		movb #'2',temp+9
		movb #'.',temp+10
		movb #'.',temp+11
		movb #'.',temp+12
		movb #'.',temp+13
		movb #'.',temp+14
		movb #'.',temp+15
		movb #'H',temp+16
		movb #0,temp+17
		ldd #temp; load #temp to register d 
		jsr display_string;
		rts
	row3:
		movb #'P',temp+0
		movb #'.',temp+1
		movb #'.',temp+2
		movb #'.',temp+3
		movb #'.',temp+4
		movb #'.',temp+5
		movb #'R',temp+6
		movb #'o',temp+7
		movb #'w',temp+8
		movb #'3',temp+9
		movb #'.',temp+10
		movb #'.',temp+11
		movb #'.',temp+12
		movb #'.',temp+13
		movb #'.',temp+14
		movb #'.',temp+15
		movb #'H',temp+16
		movb #0,temp+17
		ldd #temp; load #temp to register d 
		jsr display_string;
		ldd #temp; load #temp to register d 
		jsr display_string;
		rts
	row4:
		movb #'P',temp+0
		movb #'.',temp+1
		movb #'.',temp+2
		movb #'.',temp+3
		movb #'.',temp+4
		movb #'.',temp+5
		movb #'R',temp+6
		movb #'o',temp+7
		movb #'w',temp+8
		movb #'4',temp+9
		movb #'.',temp+10
		movb #'.',temp+11
		movb #'.',temp+12
		movb #'.',temp+13
		movb #'.',temp+14
		movb #'.',temp+15
		movb #'H',temp+16
		movb #0,temp+17
		ldd #temp; load #temp to register d 
		jsr display_string;
		rts
	
	harvest:
	***********************
	********************
	*******
	plant:
		ldx temp;
		ldaa x,18; verify if temp has already updated to an other state
		cmpa $2E; Verify if cycle 1 is done
		beq cycle1
		cmpa $146; Verify if cycle 2 is done
		beq cycle2
		bneq cycle0;
		cycle0:
			movb #'.',temp+18
			movb #'.',temp+19
			movb #'.',temp+20
			movb #'.',temp+21
			movb #'.',temp+22
			movb #'.',temp+23
			movb #'.',temp+24
			movb #'.',temp+25
			movb #'.',temp+26
			movb #'.',temp+27
			movb #'.',temp+28
			movb #'.',temp+29
			movb #'.',temp+30
			movb #'.',temp+31
			movb #'.',temp+32	
			ldd #temp; update lcd message 
			jsr display_string;
		rts
	ldaa key;
	cmpa #1;
	beq cycle1a
	cycle1a:
		ldab #%00010000
		stab val1;
	cmpa #2;
	beq cycle1b
	cycle1b:
		ldab #%00100000
		stab val1;
	cmpa #3;
	beq cycle1c
	cycle1c:
		ldab #%01000000
		stab val1;
	cmpa #4;
	beq cycle1d
	cycle1d:
		ldab #%10000000
		stab val1;
	movb #$7F, RTICTL; Init RTI to a 128 ms interval
	movb #$80, RTIENA; Enable RTI
	cli ; clear interrupt to enable
	ldab #1; temporary
	Loop1:BRCLR Port_t, val1, Loop1 ; wait for switch to be 1	
	bset INTCR, $C0; use the IRQ - User requested interrupt
	BSET Port_s, val1; set LEDs
	RTI_ISR:
		decb;
		cmpb #1;
		bneq LEDon;
		beq exitRTI
	exitRTI: rti;	
	cmpb #1
	beq update;
	Bclr Port_s, #$0F; clear LEDs
	Loop2: BRSET Port_t, val1, Loop2 ;wait for switch to be 0
	ldab #$78; load $78 120 in decimal to wait 15 sec
	LEDon:
		bset INTCR, $C0; use the IRQ - User requested interrupt
	update:
		movb #'í',temp+18
		movb #'í',temp+19
		movb #'í',temp+20
		movb #'í',temp+21
		movb #'í',temp+22
		movb #'í',temp+23
		movb #'í',temp+24
		movb #'í',temp+25
		movb #'í',temp+26
		movb #'í',temp+27
		movb #'í',temp+28
		movb #'í',temp+29
		movb #'í',temp+30
		movb #'í',temp+31
		movb #'í',temp+32	
		ldd #temp; load #temp to register d 
		jsr display_string;
	cycle2:
			movb #'¥',temp+18
			movb #'¥',temp+19
			movb #'¥',temp+20
			movb #'¥',temp+21
			movb #'¥',temp+22
			movb #'¥',temp+23
			movb #'¥',temp+24
			movb #'¥',temp+25
			movb #'¥',temp+26
			movb #'¥',temp+27
			movb #'¥',temp+28
			movb #'¥',temp+29
			movb #'¥',temp+30
			movb #'¥',temp+31
			movb #'¥',temp+32	
	switches: 
	
		



