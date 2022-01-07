INCLUDE 'derivative.inc'
; export symbols
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on
            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack
            ; LCD References
            ; Potentiometer References
            xref pot_value
            xref read_pot
            xref init_LCD
            xref display_string
; variable/data section
my_variable: SECTION
disp: ds.b 100
; code section
MyCode:     SECTION
Entry:
_Startup:
           ;intializing string "disp" to be:
;"The value of the pot is:      ",0
           movb #'M',disp
           movb #'a',disp+1
           movb #'i',disp+2
           movb #'n',disp+3
           movb #' ',disp+4
           movb #'m',disp+5
           movb #'e',disp+6
		   movb #'n',disp+7
		   movb #'u',disp+8
           movb #0,disp+9
           movb #'U',disp+10
           movb #'s',disp+11
           movb #'e',disp+12
           movb #'r',disp+13
           movb #'n',disp+14
           movb #'a',disp+15
           movb #'m',disp+16
           movb #'e',disp+17
           movb #':',disp+18
           movb #'P',disp+43
           movb #'a',disp+44
           movb #'s',disp+45
           movb #'s',disp+46
           movb #'w',disp+47
           movb #'o',disp+48
           movb #'r',disp+49
           movb #'d',disp+50
           movb #':',disp+51
           movb #0,disp+77
           movb #'1',disp+78
           movb #'2',disp+79
           movb #':',disp+80
           movb #'4',disp+81
           movb #'7',disp+82
		   movb #'a',disp+83
		   movb #'m',disp+84
		   movb #'|',disp+85
		   movb #'4',disp+86
		   movb #'/',disp+87
		   movb #'19',disp+88
		   movb #'/',disp+89
		   movb #'2',disp+90
		   movb #'0',disp+91
		   movb #'2',disp+92
		   movb #'0',disp+93
           movb #'|',disp+94    ;string terminator, acts like '\0'
		   movb #'',disp+98
        LDS #__SEG_END_SSTACK
           jsr init_LCD
   start: jsr read_pot
         ldd pot_value ; loads the variables implemented
         ldx #100
          idiv
      exg x,d ; exchange quotient with remainder in d
      addd #$30 ; convert to its ASCII equivalent
      stab disp+95;
      exg x,d;

      ldx #10
      idiv
      exg x,d
      addd #$30
      stab disp+96

     exg x,d; exchange x with d
     addd #$30 ; add $30 to d
     stab disp+97;

     ldd #disp; load #disp to d
     jsr display_string ;

     bra start
