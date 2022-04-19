;
; Cronometro.asm
;
; Created: 09/11/2021 03:52:07 p. m.
; Author : Alan Samuel Aguirre Salazar
;


.include "m16def.inc"     
 
	.org 0x0000
	jmp RESET

	.org 0x0026   
	rjmp TIM0_COMP ; Timer0 Compare A Handler

RESET:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

	// Puerto A como entrada
	ldi R16, 0b0000_0000
	out DDRA, R16 
	ldi R16, 0b1000_0001
	out PORTA, R16

	// Puerto C y D como salida
	ldi R16, 0b1111_1111
	out DDRC, R16
	out DDRD, R16

	ldi R16, 0b0000_0000
	out PORTC, R16 
	out PORTD, R16 


	//-------------
	sei // Activar interrupciones

	// OCR0
	ldi R16, 155 // Tu tope a contar
	out OCR0, R16
	// 0 - 256

	// TIFR
	ldi R16, 0b0000_0011 //Banderas de activación (comparación y overflow)
	out TIFR, R16

	// TIMSK
	ldi R16, 0b0000_0010 //Habilita la que vayas a ocupar
	out TIMSK, R16


	// TCNT0
	ldi R16, 0 // Contador
	out TCNT0, R16

/*Tienes un prescaler de 256
OCR0 = 155
TCNT0 = 155

1 centésima de segundo
*/

	ldi R16, 0
	out TCCR0, R16


	// 
/*Prescaler
1 =  001
8 =  010
64 = 011
256 =100
1024=101
*/

	clr R16
	clr R17					// Unidades Segundos
	clr R18					// Decenas Segundos
	clr R19					// Minutos
	clr R20					// Contador



	rjmp CHECK


CHECK:
	sbis PINA, 0
			rjmp INICIO
	sbis PINA, 7
			rjmp LIMPIAR
	rjmp CHECK






INICIO:
	rcall RETARDO
	TRABA_INICIO:
		sbis PINA, 0
			rjmp TRABA_INICIO
	rcall RETARDO

	clr R16
	clr R17
	clr R18
	clr R19
	clr R20
	out TCNT0, R16
	out TCCR0, R16
	out PORTC, R16
	out PORTD, R16

	ldi R16, 0b0000_1100
	out TCCR0, R16

	rjmp CHECK

LIMPIAR:
	rcall RETARDO
	TRABA_LIMPIAR:
		sbis PINA, 7
			rjmp TRABA_LIMPIAR
	rcall RETARDO

	clr R16
	clr R17
	clr R18
	clr R19
	clr R20
	out TCNT0, R16
	out TCCR0, R16

	out PORTC, R16
	out PORTD, R16

	rjmp CHECK



TIM0_COMP:
	inc R20 // 100
	cpi R20, 100
		breq SUMARUNIDADSEGUNDO
	reti


SUMARUNIDADSEGUNDO:
	clr R20

	inc R17
	// 8 segundos
	cpi R17, 10
		breq SUMARDECENASEGUNDO

	mov R16, R18
	swap R16
	or R16, R17
	out PORTD, R16
	out PORTC, R19

	reti

SUMARDECENASEGUNDO:
	clr R17

	inc R18
	cpi R18, 6
		breq SUMARMINUTO
	mov R16, R18
	// R16 = 0b0000_0010
	swap R16
	// R16 = 0b0010_0000
	or R16, R17
	// R16 = 0b0010_0000 = 2
	// R17 = 0b0000_1000 = 8
	//       0b0010_1000 = 28
	out PORTD, R16
	out PORTC, R19

	reti


SUMARMINUTO:
	clr R17
	clr R18

	inc R19
	cpi R19, 5
		breq PARAR
	mov R16, R18
	swap R16
	or R16, R17
	out PORTD, R16
	out PORTC, R19

	reti

PARAR:
	clr R16
	clr R17
	clr R18
	clr R19
	clr R20
	out TCNT0, R16 // contador a 0
	out TCCR0, R16 // Apago interruptor

	reti
	




RETARDO:
			  ldi  R29, $06
	WGLOOP0:  ldi  R30, $37
	WGLOOP1:  ldi  R31, $C9
	WGLOOP2:  dec  R31
			  brne WGLOOP2
			  dec  R30
			  brne WGLOOP1
			  dec  R29
			  brne WGLOOP0
			  nop
			  nop
	ret






