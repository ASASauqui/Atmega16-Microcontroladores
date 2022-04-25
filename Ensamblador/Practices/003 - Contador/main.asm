;
; Contador.asm
;
; Created: 21/09/2021 03:49:29 p. m.
; Author : Alan Samuel Aguirre Salazar
;

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
	ldi R16, 0b1111_1111
	out DDRD, R16			//D como salida
	ldi R16, 0b0000_0000
	out PORTD, R16			//Saca cero
	ldi R17, 0				//Inicializamos en cero la bandera
	rjmp CICLO

CICLO:
	sbic PINA, 0
	ldi R18, 0 //
	sbic PINA, 0 //
	rjmp CICLO				//Hace si es 1
	cpi R17, 1 //
	breq COMPROBAR //
	inc R16
	cpi R16, 0b0000_1010	//Ve si es 10
	breq DIEZ
	rjmp SACAR

SACAR:
	out PORTD, R16
	rcall RETARDO
	ldi R17, 1 //
	ldi R18, 1 //
	rjmp CICLO

DIEZ:
	clr R16
	out PORTD, R16
	rcall RETARDO
	ldi R17, 1 //
	ldi R18, 1 //
	rjmp CICLO

COMPROBAR:
	cpi R18, 1
	breq CICLO
	ldi R17, 0

	inc R16
	cpi R16, 0b0000_1010	//Ve si es 10
	breq DIEZ
	rjmp SACAR
	

RETARDO:
			  ldi  R17, $A5
	WGLOOP0:  ldi  R18, $C9
	WGLOOP1:  dec  R18
			  brne WGLOOP1
			  dec  R17
			  brne WGLOOP0
			  ldi  R17, $03
	WGLOOP2:  dec  R17
			  brne WGLOOP2
			  nop
	ret
	


