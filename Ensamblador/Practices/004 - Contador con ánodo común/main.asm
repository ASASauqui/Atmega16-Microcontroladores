;
; Contador.asm
;
; Created: 21/09/2021 03:49:29 p. m.
; Author : alans
;


; Replace with your application code
Reset:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

start:
    ldi R16, 0b0000_0000
	out DDRA, R16			//A0 como entrada
	ldi R16, 0b0000_0001
	out PORTA, R16			//A0 con Pull Up
	ldi R16, 0b0000_1111
	out DDRD, R16			//D como salida
	ldi R16, 0b0000_0000
	out PORTD, R16			//Saca cero
	rjmp CICLO

CICLO:
	sbic PINA, 0
	rjmp CICLO		// Hace si es 1
	rjmp POST



POST:
	rcall RETARDO
	inc R16
	cpi R16, 10
	breq DIEZ
	out PORTD, R16
	rjmp COMPROBAR

COMPROBAR:
	sbis PINA, 0
	rjmp COMPROBAR		// Hace si es 0
	rcall RETARDO
	rjmp CICLO

DIEZ:
	clr R16
	out PORTD, R16
	rjmp COMPROBAR

	

RETARDO:
	          ldi  R20, $63
	WGLOOP0:  ldi  R21, $64
	WGLOOP1:  dec  R21
			  brne WGLOOP1
			  dec  R20
			  brne WGLOOP0
			  ldi  R20, $01
	WGLOOP2:  dec  R20
			  brne WGLOOP2
	ret
	


