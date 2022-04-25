;
; Servomotor.asm
;
; Created: 30/11/2021 11:32:40 a. m.
; Author : Alan Samuel Aguirre Salazar
;




// -----------------------IMPORTANTE-TABLA----------------------------
/*
							OCR0			TIEMPO EN ALTO				
	0 grados (0-9)		=	46			=	0.001504 s
	20 grados (10-29)	=	47			=	0.001536 s
	40 grados (30-49)	=	48			=	0.001568 s
	60 grados (50-69)	=	49			=	0.0016   s
	80 grados (70-89)	=	50			=	0.001632 s
	100 grados (90-99)	=	51			=	0.001664 s
*/
//----------------------------------------------------------------------------------





.include "m16def.inc"     
 
;Palabras claves (aquí pueden definirse)
	.equ DDR_TEC=DDRA
	.equ PORT_TEC=PORTA
	.equ PIN_TEC=PINA


Start:
	;Primero inicializamos el stack pointer...
		ldi r16, high(RAMEND)
		out SPH, r16
		ldi r16, low(RAMEND)
		out SPL, r16 

		ldi R16, 0b0001_1111
		out DDR_TEC, R16		//	Configuré el puerto del teclado SALIDAS:ENTRADAS

	// Congiguracion de los puertos
		ldi R16, 0b1111_1111
		out DDRB, R16
		out DDRC, R16
		out DDRD, R16
		ldi R16, 0b0000_0000
		out PORTB, R16
		out PORTC, R16
		out PORTD, R16

	// Configuracion del timer
		// TCNT0
		ldi R16, 0
		out TCNT0, R16
		//OCR0
		ldi R16, 46				//	0 grados (46)
		out OCR0, R16

		//TCCR0
		ldi R16, 0b0110_1011	//	Inicializamos prescaler y PWM
		out TCCR0, R16


	// Registros a utilizar
		ldi R17, 0				//	Registro comodin que recopila el valor que se introduce mediante el teclado
		ldi R18, 0				//	Indica la cantidad de valores puestos en R17 [0,1,2]
		ldi R19, 0				//	Indica si ya se presiono el asterisco y se movio el servomotor
		ldi R20, 0				//	Contiene el digito que debe ir en la derecha
		ldi R21, 0				//	Contiene el digito que debe ir en la izquierda
		ldi R22, 0				//	Contiene el numero entero
		ldi R23, 0				//	Registro comodin que recopila el valor que se introduce mediante el teclado
		ldi R24, 0				//	Contiene la decena
		ldi R25, 0				//	Contiene la unidad


	rjmp TECLADO



// -------------------------Teclado-------------------------

TECLADO:

	ldi R16, 0b1111_1111

	out PORT_TEC, R16			// Pongo 5V en las salidas, y pull ups en las entradas.

	cbi PORT_TEC, 1				// Pone un 0 en el pin 0 del puerto del teclado.
	nop							// Pierde un ciclo de reloj
	nop							// Pierde un ciclo de reloj
	sbis PIN_TEC,7
	rjmp GATO
	sbis PIN_TEC,6
	rjmp CERO
	sbis PIN_TEC,5
	rjmp ASTERISCO

	sbi PORT_TEC, 1				// Pongo 5V en el pin 0 del puerto del teclado.
	cbi PORT_TEC, 2				// Pone un 0 en el pin 1 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp NUEVE
	sbis PIN_TEC,6
	rjmp OCHO
	sbis PIN_TEC,5
	rjmp SIETE
	

	sbi PORT_TEC, 2				// Pongo 5V en el pin 1 del puerto del teclado.
	cbi PORT_TEC, 3				// Pone un 0 en el pin 2 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp SEIS
	sbis PIN_TEC,6
	rjmp CINCO
	sbis PIN_TEC,5
	rjmp CUATRO

	sbi PORT_TEC, 3				// Pongo 5V en el pin 2 del puerto del teclado.
	cbi PORT_TEC, 4				// Pone un 0 en el pin 3 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,7
	rjmp TRES
	sbis PIN_TEC,6
	rjmp DOS
	sbis PIN_TEC,5
	rjmp UNO

	rjmp TECLADO





// -------------------------Colocacion de valores-------------------------

PONERVALORES:
	cpi R18, 0
		breq IZQUIERDA
	cpi R18, 1
		breq DERECHA

IZQUIERDA:
	inc R18
	mov R20, R17
	out PORTD, R20

	mov R24, R23

	rjmp TECLADO

DERECHA:
	inc R18
	mov R21, R17
	out PORTC, R20
	out PORTD, R21

	mov R25, R23

	// Multiplicacion de decena
	ldi R16, 10
	mul R24, R16
	movw R22, R0

	// Sumar las unidades
	add R22, R25

	rjmp TECLADO



// -------------------------Checar rangos-------------------------

EVALUAR:								//	0-9
	cpi R22, 10
		brsh MASDIEZ
	ldi R16, 46							//	0 grados 
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

MASDIEZ:								//	10-29
	cpi R22, 30
		brsh MASTREINTA
	ldi R16, 47							//	20 grados 
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

MASTREINTA:								//	30-49
	cpi R22, 50
		brsh MASCINCUENTA
	ldi R16, 48							//	40 grados
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

MASCINCUENTA:							//	50-69
	cpi R22, 70
		brsh MASSETENTA
	ldi R16, 49							//	60 grados
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

MASSETENTA:								//	70-89
	cpi R22, 90
		brsh MASNOVENTA
	ldi R16, 50							//	80 grados 
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

MASNOVENTA:								//	90-99
	ldi R16, 51							//	100 grados 
	out OCR0, R16

	ldi R19, 1

	rjmp TECLADO

	



// -------------------------Numeros del teclado-------------------------

// Fila 0
UNO:
	// Código al presionar
	
	rcall RETARDO						//	30 milis
	TRABA_UNO:
		sbis PIN_TEC,5
	rjmp TRABA_UNO
	rcall RETARDO						//	30 milis

	//	Código al soltar

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado1
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado1

	ldi R17, 0b0000_1000
	ldi R23, 0b0000_0001
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor1

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor1

	rjmp TECLADO

MandarATeclado1:
	rjmp TECLADO
MandarAPonerValor1:
	rjmp PONERVALORES


DOS:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_DOS:
		sbis PIN_TEC,6
	rjmp TRABA_DOS
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado1
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado1

	ldi R17, 0b0000_0100
	ldi R23, 0b0000_0010
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor2

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor2

	rjmp TECLADO

MandarATeclado2:
	rjmp TECLADO
MandarAPonerValor2:
	rjmp PONERVALORES


TRES:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_TRES:
		sbis PIN_TEC,7
	rjmp TRABA_TRES
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado3
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado3

	ldi R17, 0b0000_1100
	ldi R23, 0b0000_0011
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor3

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor3

	rjmp TECLADO

MandarATeclado3:
	rjmp TECLADO
MandarAPonerValor3:
	rjmp PONERVALORES



// Fila 1
CUATRO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_CUATRO:
		sbis PIN_TEC,5
	rjmp TRABA_CUATRO
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado4
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado4

	ldi R17, 0b0000_0010
	ldi R23, 0b0000_0100
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor4

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor4

	rjmp TECLADO

MandarATeclado4:
	rjmp TECLADO
MandarAPonerValor4:
	rjmp PONERVALORES


CINCO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_CINCO:
		sbis PIN_TEC,6
	rjmp TRABA_CINCO
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado5
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado5

	ldi R17, 0b0000_1010
	ldi R23, 0b0000_0101
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor5

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor5

	rjmp TECLADO

MandarATeclado5:
	rjmp TECLADO
MandarAPonerValor5:
	rjmp PONERVALORES


SEIS:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_SEIS:
		sbis PIN_TEC,7
	rjmp TRABA_SEIS
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado6
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado6

	ldi R17, 0b0000_0110
	ldi R23, 0b0000_0110
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor6

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor6

	rjmp TECLADO

MandarATeclado6:
	rjmp TECLADO
MandarAPonerValor6:
	rjmp PONERVALORES




// Fila 2
SIETE:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_SIETE:
		sbis PIN_TEC,5
	rjmp TRABA_SIETE
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado7
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado7

	ldi R17, 0b0000_1110
	ldi R23, 0b0000_0111
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor7

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor7

	rjmp TECLADO

MandarATeclado7:
	rjmp TECLADO
MandarAPonerValor7:
	rjmp PONERVALORES


OCHO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_OCHO:
		sbis PIN_TEC,6
	rjmp TRABA_OCHO
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado8
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado8

	ldi R17, 0b0000_0001
	ldi R23, 0b0000_1000
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor8

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor8

	rjmp TECLADO

MandarATeclado8:
	rjmp TECLADO
MandarAPonerValor8:
	rjmp PONERVALORES


NUEVE:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_NUEVE:
		sbis PIN_TEC,7
	rjmp TRABA_NUEVE
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado9
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado9

	ldi R17, 0b0000_1001
	ldi R23, 0b0000_1001
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor9

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor9

	rjmp TECLADO

MandarATeclado9:
	rjmp TECLADO
MandarAPonerValor9:
	rjmp PONERVALORES



// Fila 3
ASTERISCO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_ASTERISCO:
		sbis PIN_TEC,5
	rjmp TRABA_ASTERISCO
	rcall RETARDO						//	30 milis

	cpi R19, 1
		breq MandarATeclado10
	cpi R18, 2
		breq MandarAEvaluar

	rjmp TECLADO

MandarATeclado10:
	rjmp TECLADO
MandarAEvaluar:
	rjmp EVALUAR


CERO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_CERO:
		sbis PIN_TEC,6
	rjmp TRABA_CERO
	rcall RETARDO						//	30 milis

	cpi R18, 2							// Verifica para ignorar
		breq MandarATeclado0
	cpi R19, 1							// Verifica para ignorar
		breq MandarATeclado0

	ldi R17, 0b0000_0000
	ldi R23, 0b0000_0000
	cpi R18, 0							// Checa si no se han puesto valores
		breq MandarAPonerValor0

	cpi R18, 1							// Checa si solo se ha puesto un valor
		breq MandarAPonerValor0

	rjmp TECLADO

MandarATeclado0:
	rjmp TECLADO
MandarAPonerValor0:
	rjmp PONERVALORES


GATO:
	// Código al presionar

	rcall RETARDO						//	30 milis
	TRABA_GATO:
		sbis PIN_TEC,7
	rjmp TRABA_GATO
	rcall RETARDO						//	30 milis

	//	Código al soltar
		//OCR0
		ldi R16, 46						//	0 grados 46
		out OCR0, R16

		ldi R16, 0
		ldi R17, 0						//	Registro comodin que recopila el valor que se introduce mediante el teclado
		ldi R18, 0						//	Indica la cantidad de valores puestos en R17 [0,1,2]
		ldi R19, 0						//	Indica si ya se presiono el asterisco y se movio el servomotor
		ldi R20, 0						//	Contiene el digito que debe ir en la derecha
		ldi R21, 0						//	Contiene el digito que debe ir en la izquierda
		ldi R22, 0						//	Contiene el numero entero
		ldi R23, 0						//	Registro comodin que recopila el valor que se introduce mediante el teclado
		ldi R24, 0						//	Contiene la decena
		ldi R25, 0						//	Contiene la unidad

		out PORTC, R16
		out PORTD, R16


	rjmp TECLADO






RETARDO: // 30 milis (60,000 ciclos en 2 mhz)
			  ldi  R29, $63
	WGLOOP0:  ldi  R30, $C9
	WGLOOP1:  dec  R30
			  brne WGLOOP1
			  dec  R29
			  brne WGLOOP0
			  ldi  R29, $02
	WGLOOP2:  dec  R29
			  brne WGLOOP2
	ret









