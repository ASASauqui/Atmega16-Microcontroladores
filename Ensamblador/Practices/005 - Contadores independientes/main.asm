;
; ContadoresIndependientes.asm
;
; Created: 23/09/2021 04:15:27 p. m.
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
	out DDRA, R16			//A como entrada
	ldi R16, 0b0101_0101
	out PORTA, R16			//A con Pull Up
	ldi R16, 0b1111_1111
	out DDRC, R16			//C como salida
	ldi R16, 0b0000_0000
	ldi R17, 0b0000_0000
	ldi R18, 0b0000_0000
	out PORTC, R16			//Saca cero
	rjmp CICLO

CICLO:
	LED1A:
		sbis PINA, 0
		rcall RESET1
	LED1B:
		sbis PINA, 2
		rcall AUMENTAR1
	LED2A:
		sbis PINA, 4
		rcall RESET2
	LED2B:
		sbis PINA, 6
		rcall AUMENTAR2
	rjmp CICLO

OBSERVAR1:
	sbis PINA, 2
	rjmp OBSERVAR1
	ret


OBSERVAR2:
	sbis PINA, 6
	rjmp OBSERVAR2
	ret

OBSERVAR3:
	sbis PINA, 0
	rjmp OBSERVAR3
	ret

OBSERVAR4:
	sbis PINA, 4
	rjmp OBSERVAR4
	ret


AUMENTAR1:
	rcall RETARDO
	inc R16
	cpi R16, 16
	breq RESET1A
	OR R18, R16
	swap R18
	OR R18, R17
	out PORTC, R18
	rcall OBSERVAR1
	rcall RETARDO
	clr R18
	ret

AUMENTAR2:
	rcall RETARDO
	rcall OBSERVAR2
	inc R17
	cpi R17, 16
	breq RESET2A
	OR R18, R16
	swap R18
	OR R18, R17
	out PORTC, R18
	rcall RETARDO
	clr R18
	ret


RESET1:
	rcall RETARDO
	clr R16
	OR R18, R17
	out PORTC, R18
	rcall OBSERVAR3
	rcall RETARDO
	clr R18
	ret

RESET2:
	rcall RETARDO
	rcall OBSERVAR4
	clr R17
	OR R18, R16
	swap R18
	out PORTC, R18
	rcall RETARDO
	clr R18
	ret

RESET1A:
	rcall RETARDO
	clr R16
	OR R18, R17
	out PORTC, R18
	rcall OBSERVAR1
	rcall RETARDO
	clr R18
	rjmp LED2A


RESET2A:
	rcall RETARDO
	clr R17
	OR R18, R16
	swap R18
	out PORTC, R18
	rcall RETARDO
	clr R18
	rjmp CICLO
	

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