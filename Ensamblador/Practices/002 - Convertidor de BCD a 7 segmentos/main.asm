;
; 7_Segmentos.asm
;
; Created: 09/09/2021 03:54:29 p. m.
; Author : Alan Samuel Aguirre Salazar
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
	out DDRA, R16			//A como entrada
	ldi R16, 0b1111_1111
	out PORTA, R16			//A con Pull Ups
	out DDRC, R16			//C como salida
	ldi R16, 0b0000_0000
	out PORTC, R16			//C saca 0

CICLO:						//Ciclo principal
	in R16, PINA			//Se lee el puerto A
	cpi R16, 0b1111_0000
	breq CERO				//Ve si es 0
	cpi R16, 0b1111_1000
	breq UNO				//Ve si es 1
	cpi R16, 0b1111_0100
	breq DOS				//Ve si es 2
	cpi R16, 0b1111_1100
	breq TRES				//Ve si es 3
	cpi R16, 0b1111_0010
	breq CUATRO				//Ve si es 4
	cpi R16, 0b1111_1010
	breq CINCO				//Ve si es 5
	cpi R16, 0b1111_0110
	breq SEIS				//Ve si es 6
	cpi R16, 0b1111_1110
	breq SIETE				//Ve si es 7
	cpi R16, 0b1111_0001
	breq OCHO				//Ve si es 8
	cpi R16, 0b1111_1001
	breq NUEVE				//Ve si es 9
	ldi R16, 0b0000_0000
	out PORTC, R16			//C saca 0
	rjmp CICLO

	CERO:							//Es 0	
		ldi R16, 0b0011_1111
		out PORTC, R16
		rjmp CICLO
	UNO:							//Es 1	
		ldi R16, 0b0000_0110
		out PORTC, R16
		rjmp CICLO
	DOS:							//Es 2
		ldi R16, 0b0101_1011
		out PORTC, R16
		rjmp CICLO
	TRES:							//Es 3
		ldi R16, 0b0100_1111
		out PORTC, R16
		rjmp CICLO
	CUATRO:							//Es 4
		ldi R16, 0b0110_0110
		out PORTC, R16
		rjmp CICLO
	CINCO:							//Es 5
		ldi R16, 0b0110_1101
		out PORTC, R16
		rjmp CICLO
	SEIS:							//Es 6
		ldi R16, 0b0111_1101
		out PORTC, R16
		rjmp CICLO
	SIETE:							//Es 7
		ldi R16, 0b0100_0111
		out PORTC, R16
		rjmp CICLO
	OCHO:							//Es 8
		ldi R16, 0b0111_1111
		out PORTC, R16
		rjmp CICLO
	NUEVE:							//Es 9
		ldi R16, 0b0110_0111
		out PORTC, R16
		rjmp CICLO
