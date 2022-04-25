;
; Candado.asm
;
; Created: 14/10/2021 03:23:48 p. m.
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

	ldi R16, 0b1000_0001
	out DDRD, R16

	ldi R16, 0b1000_0000	
	out PORTD, R16

	ldi R17, 0					// Registro de si la cerradura esta o no abierta
	ldi R18, 0					// Registro de si la alarma esta o no activada
	ldi R19, 0					// Registro contador
	ldi R20, 0					// Registro Guardador de Resultados (izquierda)
	ldi R21, 0					// Registro Guardador de Resultados (Derecha)
	ldi R22, 0					// Registro de operacion AND (0b0000_1111)
	ldi R23, 0
	ldi R24, 0
	ldi R25, 0
	ldi R26, 0

	/*ldi R26, 0b1111_1111
	out DDRB, R16
	out DDRC, R16*/




TECLADO:
	/*out PORTB, R20
	out PORTC, R21*/

	ldi R16, 0b1111_1111
	out PORT_TEC, R16			// Pongo 5V en las salidas, y pull ups en las entradas.
	cbi PORT_TEC, 0				// Pone un 0 en el pin 0 del puerto del teclado.
	nop							// Pierde un ciclo de reloj
	nop							// Pierde un ciclo de reloj
	sbis PIN_TEC,7
	rjmp ASTERISCO
	sbis PIN_TEC,6
	rjmp CERO
	sbis PIN_TEC,5
	rjmp GATO
	sbis PIN_TEC,4
	rjmp D

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
	sbis PIN_TEC,4
	rjmp C
	

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
	sbis PIN_TEC,4
	rjmp B

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
	sbis PIN_TEC,4
	rjmp A

	rjmp TECLADO


// Comprobaciones de claves
COMPROBAR:
	ldi R19, 0
	cpi R20, 0b0001_0101
	breq COMPROBAR1
	rjmp ACTIVARALARMA
	COMPROBAR1:
		cpi R21, 0b0111_1001
		breq ABRIRCANDADO
		rjmp ACTIVARALARMA

COMPROBARCOMBINACIONALARMA:
	cpi R21, 0b0010_0011
	breq DESACTIVARALARMA
	rjmp TECLADO


// Alarma
ACTIVARALARMA:
	ldi R18, 1
	clr R20
	clr R21
	ldi R16, 0b1000_0001	
	out PORTD, R16
	rjmp TECLADO

DESACTIVARALARMA:
	ldi R19, 0
	ldi R18, 0
	clr R20
	clr R21
	ldi R16, 0b1000_0000	
	out PORTD, R16
	rjmp TECLADO


// Candado
ABRIRCANDADO:
	ldi R17, 1
	clr R20
	clr R21
	ldi R16, 0b0000_0000	
	out PORTD, R16
	rjmp TECLADO

CERRARCANDADO:
	ldi R17, 0
	ldi R16, 0b1000_0000	
	out PORTD, R16
	ldi R19, 0
	clr R20
	clr R21
	clr R22
	rjmp TECLADO


// Resetear
RESETEARCANDADO:
	ldi R19, 0
	clr R20
	clr R21
	rjmp TECLADO



// Fila 0
UNO:
	// Código al presionar
	
	rcall RETARDO				//	50 milis
	TRABA_UNO:
		sbis PIN_TEC,7
	rjmp TRABA_UNO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO1

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0001
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA1
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR1

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO1:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA1:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR1:
			rjmp COMPROBAR

DOS:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_DOS:
		sbis PIN_TEC,6
	rjmp TRABA_DOS
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO2

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0010
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA2
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR2

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO2:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA2:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR2:
			rjmp COMPROBAR

TRES:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_TRES:
		sbis PIN_TEC,5
	rjmp TRABA_TRES
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO3

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0011
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA3
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR3

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO3:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA3:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR3:
			rjmp COMPROBAR

A:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_A:
		sbis PIN_TEC,4
	rjmp TRABA_A
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOA
		// RESETEAR
			cpi R18, 0
			breq MandarARESETEARCANDADO

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOA:
			rjmp CERRARCANDADO
		MandarARESETEARCANDADO:
			rjmp RESETEARCANDADO


// Fila 1
CUATRO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_CUATRO:
		sbis PIN_TEC,7
	rjmp TRABA_CUATRO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO4

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0100
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA4
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR4

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO4:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA4:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR4:
			rjmp COMPROBAR

CINCO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_CINCO:
		sbis PIN_TEC,6
	rjmp TRABA_CINCO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO5

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0101
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA5
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR5

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO5:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA5:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR5:
			rjmp COMPROBAR

SEIS:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_SEIS:
		sbis PIN_TEC,5
	rjmp TRABA_SEIS
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO6

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0110
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA6
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR6

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO6:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA6:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR6:
			rjmp COMPROBAR

B:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_B:
		sbis PIN_TEC,4
	rjmp TRABA_B
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOB

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOB:
			rjmp CERRARCANDADO



// Fila 2
SIETE:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_SIETE:
		sbis PIN_TEC,7
	rjmp TRABA_SIETE
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO7

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0111
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA7
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR7

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO7:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA7:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR7:
			rjmp COMPROBAR

OCHO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_OCHO:
		sbis PIN_TEC,6
	rjmp TRABA_OCHO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO8

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_1000
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA8
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR8

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO8:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA8:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR8:
			rjmp COMPROBAR

NUEVE:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_NUEVE:
		sbis PIN_TEC,5
	rjmp TRABA_NUEVE
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO9

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_1001
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA9
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR9

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO9:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA9:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR9:
			rjmp COMPROBAR

C:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_C:
		sbis PIN_TEC,4
	rjmp TRABA_C
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOC

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOC:
			rjmp CERRARCANDADO


// Fila 3
ASTERISCO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_ASTERISCO:
		sbis PIN_TEC,7
	rjmp TRABA_ASTERISCO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOASTERISCO

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOASTERISCO:
			rjmp CERRARCANDADO

CERO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_CERO:
		sbis PIN_TEC,6
	rjmp TRABA_CERO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADO0

		// Operacion de corrimiento
			// Parte 1
				swap R20
				swap R21
			// Parte 2
				andi R20, 0b1111_0000
				ldi R22, 0b0000_1111
				and R22, R21
				or R20, R22
				andi R21, 0b1111_0000
			// Parte 3
				ori R21, 0b0000_0000
		// Comprobar combinacion para alarma (2->3)
			cpi R18, 1
			breq MandarACOMPROBARCOMBINACIONALARMA0
		// Comprobar combinacion de 4
			inc R19
			cpi R19, 4
			breq MandarACOMPROBAR0

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADO0:
			rjmp CERRARCANDADO
		MandarACOMPROBARCOMBINACIONALARMA0:
			rjmp COMPROBARCOMBINACIONALARMA
		MandarACOMPROBAR0:
			rjmp COMPROBAR

GATO:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_GATO:
		sbis PIN_TEC,5
	rjmp TRABA_GATO
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOGATO

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOGATO:
			rjmp CERRARCANDADO

D:
	// Código al presionar

	rcall RETARDO				//	50 milis
	TRABA_D:
		sbis PIN_TEC,4
	rjmp TRABA_D
	rcall RETARDO				//	50 milis
	//	Código al soltar
		// Cerrar cerradura
			cpi R17, 1
			breq MandarACERRARCANDADOD

	rjmp TECLADO
	//Funciones lejanas
		MandarACERRARCANDADOD:
			rjmp CERRARCANDADO






RETARDO:
	          ldi  R30, $63
	WGLOOP0:  ldi  R31, $64
	WGLOOP1:  dec  R31
			  brne WGLOOP1
			  dec  R30
			  brne WGLOOP0
			  ldi  R30, $01
	WGLOOP2:  dec  R30
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







