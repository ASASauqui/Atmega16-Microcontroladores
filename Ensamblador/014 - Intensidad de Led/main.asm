;
; Intensidad de Led.asm
;
; Created: 18/11/2021 04:27:18 p. m.
; Author : Alan Samuel Aguirre Salazar
;

.include "m16def.inc"     
 
	.org 0x0000
	jmp RESET

RESET:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

	// Puerto A como entrada
	ldi R16, 0b0000_0000
	out DDRA, R16 

	ldi R16, 0b1111_1111
	out PORTA, R16

	// Puerto B como salida
	ldi R16, 0b1111_1111
	out DDRB, R16

	ldi R16, 0b0100_0000
	out PORTB, R16 


	clr R16				// Registro todologo xd
	ldi R17, 10			// Lleva el 10
	clr R20				// Contador General
	ldi R21, 1			// Esta en minimo
	clr R22				// Esta en maximo


	rjmp CHECK


CHECK:
	sbis PINA, 0
		rjmp AUMENTAR
	sbis PINA, 4
		rjmp DISMINUIR

	rjmp CHECK


IRACHECK1:
	rjmp CHECK

AUMENTAR:
	rcall RETARDO
	TRABA_AUMENTAR:
		sbis PINA, 0
			rjmp TRABA_AUMENTAR
	rcall RETARDO

	clr R21

	cpi R22, 1
		breq IRACHECK1

	add R20, R17

	cpi R20, 250
		breq MAXIMO
	cbi PORTB, 6
	cbi PORTB, 7

	CONTINUARAUMENTAR:
		// TCNT0
		ldi R16, 0
		out TCNT0, R16

		// OCR0
		out OCR0, R20

		// TCCR0
		ldi R16, 0b0110_1100
		out TCCR0, R16

		rjmp CHECK

MAXIMO:
	cbi PORTB, 6
	sbi PORTB, 7
	
	clr R21
	ldi R22, 1

	rjmp CONTINUARAUMENTAR

	
IRACHECK2:
	rjmp CHECK

DISMINUIR:
	rcall RETARDO
	TRABA_DISMINUIR:
		sbis PINA, 4
			rjmp TRABA_DISMINUIR
	rcall RETARDO

	clr R22

	cpi R21, 1
		breq IRACHECK2

	sub R20, R17

	cpi R20, 0
		breq MINIMO
	cbi PORTB, 6
	cbi PORTB, 7

	CONTINUARDISMINUIR:
		// TCNT0
		ldi R16, 0
		out TCNT0, R16

		// OCR0
		out OCR0, R20

		// TCCR0
		ldi R16, 0b0110_1100
		out TCCR0, R16

		rjmp CHECK

MINIMO:
	// TCCR0
	clr R16
	out TCCR0, R16

	sbi PORTB, 6
	cbi PORTB, 7

	ldi R21, 1
	clr R22

	rjmp CHECK

	


RETARDO:
			  ldi  R29, $E1
	WGLOOP0:  ldi  R30, $EC
	WGLOOP1:  dec  R30
			  brne WGLOOP1
			  dec  R29
			  brne WGLOOP0
			  ldi  R29, $08
	WGLOOP2:  dec  R29
			  brne WGLOOP2
			  nop
	ret







