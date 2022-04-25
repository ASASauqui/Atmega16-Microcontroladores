;
; Operaciones.asm
;
; Created: 19/10/2021 12:42:21 p. m.
; Author : Alan Samuel Aguirre Salazar
;






// -----------------------IMPORTANTE-REGISTROS RESULTADO----------------------------
/*
	El registro que al final guarda la suma o la resta que se mostrara en los displays, 
	es el R24. Este se puede observar en las funciones SUMA y RESTA cuando se le manda 
	al PORT para que muestre el resultado correcto.
*/
//----------------------------------------------------------------------------------








.include "m16adef.inc"     
 
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

		ldi R16, 0b0000_1111
		out DDR_TEC, R16		//	Configuré el puerto del teclado SALIDAS:ENTRADAS
	//CONFIGURAR LO DEMÁS QUE HAGA FALTA...

	// Congiguracion de los puertos
		ldi R16, 0b1111_1111
		out DDRB, R16
		out DDRC, R16
		out DDRD, R16
		ldi R16, 0b0000_0000
		out PORTB, R16
		out PORTC, R16
		out PORTD, R16

	// Registros a utilizar
		ldi R19, 0				// Registro de lleva o no 1 para hacer las sumas y restas
		ldi R20, 0b000_1010		// Registro de 10
		ldi R21, 1				// Registro contador
		ldi R22, 0				// Registro guardador de subresultados
		ldi R23, 0				// Numero del boton presionado
		ldi R24, 0				// Display azul izquierda
		ldi R25, 0				// Display azul derecha
		ldi R26, 0				// Display verde izquieda
		ldi R27, 0				// Display verde derecha
		ldi R28, 0				// 0 = Resta, 1 = Suma

	rjmp TECLADO



TECLADO:

	ldi R16, 0b1111_1111

	out PORT_TEC, R16			// Pongo 5V en las salidas, y pull ups en las entradas.

	sbis PIN_TEC,7				// Reset
	rjmp RESETEAR

	cbi PORT_TEC, 0				// Pone un 0 en el pin 0 del puerto del teclado.
	nop							// Pierde un ciclo de reloj
	nop							// Pierde un ciclo de reloj
	sbis PIN_TEC,6
	rjmp GATO
	sbis PIN_TEC,5
	rjmp CERO
	sbis PIN_TEC,4
	rjmp ASTERISCO

	sbi PORT_TEC, 0				// Pongo 5V en el pin 0 del puerto del teclado.
	cbi PORT_TEC, 1				// Pone un 0 en el pin 1 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,6
	rjmp NUEVE
	sbis PIN_TEC,5
	rjmp OCHO
	sbis PIN_TEC,4
	rjmp SIETE
	

	sbi PORT_TEC, 1				// Pongo 5V en el pin 1 del puerto del teclado.
	cbi PORT_TEC, 2				// Pone un 0 en el pin 2 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,6
	rjmp SEIS
	sbis PIN_TEC,5
	rjmp CINCO
	sbis PIN_TEC,4
	rjmp CUATRO

	sbi PORT_TEC, 2				// Pongo 5V en el pin 2 del puerto del teclado.
	cbi PORT_TEC, 3				// Pone un 0 en el pin 3 del puerto del teclado.
	nop
	nop
	sbis PIN_TEC,6
	rjmp TRES
	sbis PIN_TEC,5
	rjmp DOS
	sbis PIN_TEC,4
	rjmp UNO

	rjmp TECLADO



RESETEAR:
	// Traba
		rcall RETARDO				//	30 milis
		TRABA_RESET:
			sbis PIN_TEC,7
		rjmp TRABA_RESET
		rcall RETARDO				//	30 milis

	// Puertos
		ldi R16, 0b0000_0000
		out PORTB, R16
		out PORTC, R16
		out PORTD, R16
	
	// Registros
		ldi R19, 0					// Registro de lleva o no 1 para hacer las sumas y restas
		ldi R21, 1					// Registro contador
		ldi R22, 0					// Registro guardador de subresultados
		ldi R23, 0					// Numero del boton presionado
		ldi R24, 0					// Display azul izquierda
		ldi R25, 0					// Display azul derecha
		ldi R26, 0					// Display verde izquieda
		ldi R27, 0					// Display verde derecha
		ldi R28, 0					// 0 = Resta, 1 = Suma

		rjmp TECLADO
	

PonerAzulIzquierdo:
	// Impresion
		inc R21
		or R24, R23
		swap R23
		out PORTC, R23
		rjmp TECLADO 

PonerAzulDerecho:
	// Impresion
		inc R21
		or R25, R23
		swap R24
		or R23, R24
		swap R24
		out PORTC, R23


	rjmp TECLADO

PonerVerdeIzquierdo:
	// Impresion
		inc R21
		or R26, R23
		swap R23
		out PORTD, R23
		rjmp TECLADO 

PonerVerdeDerecho:
	// Impresion
		inc R21
		or R27, R23
		swap R26
		or R23, R26
		swap R26
		out PORTD, R23

	rjmp ImprimirResultado

ImprimirResultado:
	cpi R28, 0
		breq RESTA
	cpi R28, 1
		breq SUMA


SUMA:
	add R25, R27				// Suma de los numeros de la derecha
	cpi R25, 10
		brge QuitarleDiez
	add R24, R26				// Suma de los numeros de la izquierda
	swap R24
	or R24, R25					// Combinar numeros
	out PORTB, R24
	rjmp TECLADO

	QuitarleDiez:
		subi R25, 10			// Restarle 10 a la derecha
		ldi R19, 1
		add R24, R26			// Suma de los numeros de la izquierda
		add R24, R19			// Suma del 1
		swap R24
		or R24, R25				// Combinar numeros
		out PORTB, R24
		rjmp TECLADO
		
RESTA:
	or R22, R25
	sub R22, R27				// Resta de los numeros de la derecha
	cpi R22, 0
		brlt SumarleDiez
	sub R24, R26				// Resta de los numeros de la izquierda
	swap R24
	or R24, R22					// Combinar numeros
	out PORTB, R24
	rjmp TECLADO

	SumarleDiez:
		add R25, R20			// Sumarle 10 al primero de la derecha
		sub R25, R27			// Resta de los numeros de la derecha
		ldi R19, 1
		sub R24, R19			// Resta del 1
		sub R24, R26			// Resta de los numeros de la izquierda
		swap R24
		or R24, R25				// Combinar numeros
		out PORTB, R24
		rjmp TECLADO
	



// Fila 0
UNO:
	// Código al presionar
	
	rcall RETARDO				//	30 milis
	TRABA_UNO:
		sbis PIN_TEC,4
	rjmp TRABA_UNO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0001
		cpi R21, 1
		breq IrAPonerAzulIzquierdo1
		cpi R21, 2
		breq IrAPonerAzulDerecho1
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo1
		cpi R21, 5
		breq irAPonerVerdeDerecho1

	rjmp TECLADO
	IrAPonerAzulIzquierdo1:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho1:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo1:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho1:
		rjmp PonerVerdeDerecho


DOS:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_DOS:
		sbis PIN_TEC,5
	rjmp TRABA_DOS
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0010
		cpi R21, 1
		breq IrAPonerAzulIzquierdo2
		cpi R21, 2
		breq IrAPonerAzulDerecho2
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo2
		cpi R21, 5
		breq irAPonerVerdeDerecho2

	rjmp TECLADO
	IrAPonerAzulIzquierdo2:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho2:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo2:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho2:
		rjmp PonerVerdeDerecho

TRES:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_TRES:
		sbis PIN_TEC,6
	rjmp TRABA_TRES
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0011
		cpi R21, 1
		breq IrAPonerAzulIzquierdo3
		cpi R21, 2
		breq IrAPonerAzulDerecho3
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo3
		cpi R21, 5
		breq irAPonerVerdeDerecho3

	rjmp TECLADO
	IrAPonerAzulIzquierdo3:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho3:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo3:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho3:
		rjmp PonerVerdeDerecho


// Fila 1
CUATRO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_CUATRO:
		sbis PIN_TEC,4
	rjmp TRABA_CUATRO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0100
		cpi R21, 1
		breq IrAPonerAzulIzquierdo4
		cpi R21, 2
		breq IrAPonerAzulDerecho4
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo4
		cpi R21, 5
		breq irAPonerVerdeDerecho4

	rjmp TECLADO
	IrAPonerAzulIzquierdo4:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho4:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo4:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho4:
		rjmp PonerVerdeDerecho

CINCO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_CINCO:
		sbis PIN_TEC,5
	rjmp TRABA_CINCO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0101
		cpi R21, 1
		breq IrAPonerAzulIzquierdo5
		cpi R21, 2
		breq IrAPonerAzulDerecho5
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo5
		cpi R21, 5
		breq irAPonerVerdeDerecho5

	rjmp TECLADO
	IrAPonerAzulIzquierdo5:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho5:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo5:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho5:
		rjmp PonerVerdeDerecho

SEIS:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_SEIS:
		sbis PIN_TEC,6
	rjmp TRABA_SEIS
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0110
		cpi R21, 1
		breq IrAPonerAzulIzquierdo6
		cpi R21, 2
		breq IrAPonerAzulDerecho6
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo6
		cpi R21, 5
		breq irAPonerVerdeDerecho6

	rjmp TECLADO
	IrAPonerAzulIzquierdo6:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho6:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo6:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho6:
		rjmp PonerVerdeDerecho



// Fila 2
SIETE:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_SIETE:
		sbis PIN_TEC,4
	rjmp TRABA_SIETE
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0111
		cpi R21, 1
		breq IrAPonerAzulIzquierdo7
		cpi R21, 2
		breq IrAPonerAzulDerecho7
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo7
		cpi R21, 5
		breq irAPonerVerdeDerecho7

	rjmp TECLADO
	IrAPonerAzulIzquierdo7:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho7:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo7:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho7:
		rjmp PonerVerdeDerecho

OCHO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_OCHO:
		sbis PIN_TEC,5
	rjmp TRABA_OCHO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_1000
		cpi R21, 1
		breq IrAPonerAzulIzquierdo8
		cpi R21, 2
		breq IrAPonerAzulDerecho8
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo8
		cpi R21, 5
		breq irAPonerVerdeDerecho8

	rjmp TECLADO
	IrAPonerAzulIzquierdo8:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho8:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo8:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho8:
		rjmp PonerVerdeDerecho

NUEVE:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_NUEVE:
		sbis PIN_TEC,6
	rjmp TRABA_NUEVE
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_1001
		cpi R21, 1
		breq IrAPonerAzulIzquierdo9
		cpi R21, 2
		breq IrAPonerAzulDerecho9
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo9
		cpi R21, 5
		breq irAPonerVerdeDerecho9

	rjmp TECLADO
	IrAPonerAzulIzquierdo9:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho9:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo9:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho9:
		rjmp PonerVerdeDerecho


// Fila 3
ASTERISCO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_ASTERISCO:
		sbis PIN_TEC,4
	rjmp TRABA_ASTERISCO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		cpi R21, 3
		breq IrASuma
	rjmp TECLADO
	IrASuma:
		ldi R28, 1
		inc R21
		rjmp TECLADO

CERO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_CERO:
		sbis PIN_TEC,5
	rjmp TRABA_CERO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		ldi R23, 0b0000_0000
		cpi R21, 1
		breq IrAPonerAzulIzquierdo0
		cpi R21, 2
		breq IrAPonerAzulDerecho0
		cpi R21, 4
		breq IrAPonerVerdeIzquierdo0
		cpi R21, 5
		breq irAPonerVerdeDerecho0

	rjmp TECLADO
	IrAPonerAzulIzquierdo0:
		rjmp PonerAzulIzquierdo
	IrAPonerAzulDerecho0:
		rjmp PonerAzulDerecho
	IrAPonerVerdeIzquierdo0:
		rjmp PonerVerdeIzquierdo
	irAPonerVerdeDerecho0:
		rjmp PonerVerdeDerecho

GATO:
	// Código al presionar

	rcall RETARDO				//	30 milis
	TRABA_GATO:
		sbis PIN_TEC,6
	rjmp TRABA_GATO
	rcall RETARDO				//	30 milis
	//	Código al soltar
		cpi R21, 3
		breq IrAResta
	rjmp TECLADO
	IrAResta:
		ldi R28, 0
		inc R21
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









