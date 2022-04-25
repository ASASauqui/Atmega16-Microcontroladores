;
; Medidor de Periodo.asm
;
; Created: 16/11/2021 03:25:02 p. m.
; Author : Alan Samuel Aguirre Salazar
;

.include "m16def.inc"     
 
	.org 0x0000
	jmp RESET

	.org 0x0026   
	rjmp TIM0_COMP

RESET:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

	// Puerto A y B como entrada
	ldi R16, 0b0000_0000
	out DDRA, R16 
	out DDRB, R16 

	ldi R16, 0b1111_1111
	out PORTA, R16
	out PORTB, R16

	// Puerto C como salida
	ldi R16, 0b1111_1111
	out DDRC, R16

	ldi R16, 0b0000_0000
	out PORTC, R16 

	sei

	// OCR0
	ldi R16, 249
	out OCR0, R16

	// TIFR
	ldi R16, 0b0000_0011
	out TIFR, R16

	// TIMSK
	ldi R16, 0b0000_0010
	out TIMSK, R16

	// TCNT0
	ldi R16, 0
	out TCNT0, R16


	clr R16				// Registro todologo xd
	clr R20				// Contador General
	clr R21				// Contador de decimales
	clr R22				// Booleano



	rjmp CHECK


CHECK:
	sbis PINB, 0
		rjmp ACTIVAR

	rjmp CHECK
	
	
ACTIVAR:
	rcall RETARDO
	TRABA_ACTIVAR:
		sbis PINB, 0
			rjmp TRABA_ACTIVAR
	rcall RETARDO

	// Booleano
	ldi R22, 1

	// Limpiar contador general
	clr R20

	// TCNT0
	ldi R16, 0
	out TCNT0, R16

	// Trabas para entrar justamente al inicio de un ciclo
	TRABA_ACTIVAR1:
		sbic PINA, 0
			rjmp TRABA_ACTIVAR1		// Hace si es 1
	TRABA_ACTIVAR2:
		sbis PINA, 0
			rjmp TRABA_ACTIVAR2		// Hace si es 0

	// TCCR0
	ldi R16, 0b0000_1010
	out TCCR0, R16

	rjmp TRABAGENERAL


TRABAGENERAL:
	cpi R22, 1
		breq TRABAGENERAL
	rjmp CHECK
	


TIM0_COMP:
	sbis PINA, 0
		rjmp IMPRIMIR				// Hace si es 0
	inc R20

	reti

IMPRIMIR:
	// TCCR0
		clr R16
		out TCCR0, R16
	// TCNT0
		out TCNT0, R16

	// Suma de 1 porque no toma el valor que es justamente cuando termina un ciclo
	ldi R16, 1
	add R20, R16

	// Ver si es mayor a 10
	cpi R20, 10
		BRSH FRAGMENTAR

	//Impresion final y reseteo de los registros
	IMPRIMIRCONTINUAR:
		out PORTC, R20
		clr R16
		clr R20
		clr R21
		clr R22

		reti

FRAGMENTAR:
	subi R20, 10
	inc R21
	cpi R20, 10
		BRSH FRAGMENTAR
	swap R21
	or R20, R21

	rjmp IMPRIMIRCONTINUAR
	


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






