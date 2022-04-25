;
; TecladoMatricial.asm
;
; Created: 07/10/2021 04:11:45 p. m.
; Author : Alan Samuel Aguirre Salazar
;

.include "m16adef.inc"     
 
;Palabras claves (aquí pueden definirse)
.equ DDR_TEC=DDRA
.equ PORT_TEC=PORTA
.equ PIN_TEC=PINA


Reset:
;Primero inicializamos el stack pointer...
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 

ldi R16, 0b0000_1111
out DDR_TEC, R16 //	Configuré el puerto del teclado SALIDAS:ENTRADAS
//CONFIGURAR LO DEMÁS QUE HAGA FALTA...

ldi R16, 0b1111_1111
out DDRC, R16

ldi R17, 0
ldi R18, 0

out PORTC, R17






TECLADO:
	ldi R16, 0b1111_1111
	out PORT_TEC, R16			// Pongo 5V en las salidas, y pull ups en las entradas.
	cbi PORT_TEC, 0				// Pone un 0 en el pin 0 del puerto del teclado.
	nop							// Pierde un ciclo de reloj
	nop							// Pierde un ciclo de reloj
	sbis PIN_TEC,6
	rjmp CERO

	sbi PORT_TEC, 0				// Pongo 5V en el pin 0 del puerto del teclado.
	cbi PORT_TEC, 1				// Pone un 0 en el pin 1 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp SIETE
	sbis PIN_TEC,6
	rjmp OCHO
	sbis PIN_TEC,5
	rjmp NUEVE
	

	sbi PORT_TEC, 1				// Pongo 5V en el pin 1 del puerto del teclado.
	cbi PORT_TEC, 2				// Pone un 0 en el pin 2 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp CUATRO
	sbis PIN_TEC,6
	rjmp CINCO
	sbis PIN_TEC,5
	rjmp SEIS
	

	sbi PORT_TEC, 2				// Pongo 5V en el pin 2 del puerto del teclado.
	cbi PORT_TEC, 3				// Pone un 0 en el pin 3 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp UNO
	sbis PIN_TEC,6
	rjmp DOS
	sbis PIN_TEC,5
	rjmp TRES
	

	rjmp TECLADO

// Fila 0
UNO:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_1000
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_UNO:
		sbis PIN_TEC,7
	rjmp TRABA_UNO
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

DOS:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_0100
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_DOS:
		sbis PIN_TEC,6
	rjmp TRABA_DOS
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

TRES:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_1100
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_TRES:
		sbis PIN_TEC,5
	rjmp TRABA_TRES
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO


// Fila 1
CUATRO:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_0010
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_CUATRO:
		sbis PIN_TEC,7
	rjmp TRABA_CUATRO
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

CINCO:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_1010
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_CINCO:
		sbis PIN_TEC,6
	rjmp TRABA_CINCO
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

SEIS:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_0110
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_SEIS:
		sbis PIN_TEC,5
	rjmp TRABA_SEIS
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO



// Fila 2
SIETE:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_1110
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_SIETE:
		sbis PIN_TEC,7
	rjmp TRABA_SIETE
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

OCHO:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_0001
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_OCHO:
		sbis PIN_TEC,6
	rjmp TRABA_OCHO
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

NUEVE:
	// Código al presionar
		mov R18, R17
		ldi R17,0b0000_1001
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_NUEVE:
		sbis PIN_TEC,5
	rjmp TRABA_NUEVE
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO


// Fila 3
CERO:
	// Código al presionar
		mov R18, R17
		ldi R17,0
		swap R18
		or R18, R17
		out PORTC, R18
	rcall RETARDO				//	50 milis
	TRABA_CERO:
		sbis PIN_TEC,6
	rjmp TRABA_CERO
	rcall RETARDO				//	50 milis
	//	Código al soltar
	rjmp TECLADO

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

/*RETARDO:
			  ldi  R25, $97
	WGLOOP0:  ldi  R26, $06
	WGLOOP1:  ldi  R27, $92
	WGLOOP2:  dec  R27
			  brne WGLOOP2
			  dec  R26
			  brne WGLOOP1
			  dec  R25
			  brne WGLOOP0
			  nop
	ret*/






