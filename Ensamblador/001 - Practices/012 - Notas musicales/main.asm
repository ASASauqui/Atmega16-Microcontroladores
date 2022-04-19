;
; Teclado1Octava.asm
;
; Created: 11/11/2021 03:49:43 p. m.
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

	// Puerto A y como entrada
	ldi R16, 0b0000_0000
	out DDRA, R16 
	ldi R16, 0b1111_1111
	out PORTA, R16

	// Puerto B como salida
	ldi R16, 0b0000_1000
	out DDRB, R16

	ldi R16, 0b0000_0000
	out PORTB, R16 



	// TIFR
	ldi R16, 0b0000_0011
	out TIFR, R16

	// TIMSK
	ldi R16, 0b0000_0010
	out TIMSK, R16


	// TCNT0
	ldi R16, 0
	out TCNT0, R16


	clr R16
	clr R20				// Contador



	rjmp CHECK


CHECK:
	rcall DO
	rcall DO
	rcall RE
	rcall RETARDO
	rcall DO
	rcall FA
	rcall MI
	rcall RETARDO
	rcall RETARDO

	rcall PARAR
	rcall RETARDO

	rcall DO
	rcall DO
	rcall RE
	rcall RETARDO
	rcall DO
	rcall SOL
	rcall FA
	rcall RETARDO
	rcall RETARDO

	rcall PARAR
	rcall RETARDO
	
	rcall DO
	rcall DO
	rcall DO
	rcall RETARDO
	rcall LA
	rcall FA
	rcall MI
	rcall RE
	rcall RETARDO

	rcall SI
	rcall SI
	rcall LA
	rcall RETARDO
	rcall FA
	rcall SOL
	rcall FA
	rcall RETARDO
	rcall RETARDO

	rcall PARAR
	rcall RETARDO
	rcall RETARDO
	rcall RETARDO
	rcall RETARDO
	rcall RETARDO


	rjmp CHECK
	

PARAR:
	// TCCR0
	ldi R16, 0
	out TCCR0, R16
	ret
	
	
DO:
	// OCR0
	ldi R16, 238
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret

RE: 
	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// OCR0
	ldi R16, 212
	out OCR0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret
	
MI: 
	// OCR0
	ldi R16, 189
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret

FA: 
	// OCR0
	ldi R16, 178
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret

SOL: 
	// OCR0
	ldi R16, 158
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret

LA: 
	// OCR0
	ldi R16, 141
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret

SI: 
	// OCR0
	ldi R16, 126
	out OCR0, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// TCCR0
	ldi R16, 0b0001_1010
	out TCCR0, R16

	rcall RETARDO
	rcall RETARDO

	ret
	



RETARDO:
			  ldi  R29, $09
	WGLOOP0:  ldi  R30, $37
	WGLOOP1:  ldi  R31, $C9
	WGLOOP2:  dec  R31
			  brne WGLOOP2
			  dec  R30
			  brne WGLOOP1
			  dec  R29
			  brne WGLOOP0
			  ldi  R29, $01
	WGLOOP3:  dec  R29
			  brne WGLOOP3
	ret






