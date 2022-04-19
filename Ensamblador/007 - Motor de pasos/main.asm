;
; MotorAPasos.asm
;
; Created: 12/10/2021 04:14:16 p. m.
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
	out DDRB, R16			//B como entrada
	ldi R16, 0b0000_0011
	out PORTB, R16			//B con Pull Up
	ldi R16, 0b0000_1111
	out DDRA, R16			//A como salida
	ldi R16, 0b0000_0000
	out PORTA, R16			//Saca cero
	rjmp CICLO

CICLO:
	sbis PINB, 0
		rjmp RELOJ			// Hace si es 0
	sbis PINB, 1
		rjmp ANTIRELOJ		// Hace si es 0
	rjmp CICLO


RELOJ:
	rcall RETARDO
	ldi R16, 0b0000_0001
	rjmp RELOJ1

RELOJ1:
	sbis PINB, 0
		rjmp RELOJ2			// Hace si es 0
	rcall RETARDO
	rjmp CICLO

RELOJ2:
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsl R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsl R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsl R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsl R16
	ldi R16, 0b0000_0001

	rjmp RELOJ1


ANTIRELOJ:
	rcall RETARDO
	ldi R16, 0b0000_1000
	rjmp ANTIRELOJ1

ANTIRELOJ1:
	sbis PINB, 1
		rjmp ANTIRELOJ2			// Hace si es 0
	rcall RETARDO
	rjmp CICLO

ANTIRELOJ2:
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsr R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsr R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsr R16
	out PORTA, R16	
	rcall RETARDOMOTOR
	lsr R16
	ldi R16, 0b0000_1000

	rjmp ANTIRELOJ1



	

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

RETARDOMOTOR:
			  ldi  R20, $21
	WGLOOP3:  ldi  R21, $64
	WGLOOP4:  dec  R21
			  brne WGLOOP4
			  dec  R20
			  brne WGLOOP3
			  nop
	ret



/*RETARDOMOTOR:
			  ldi  R20, $AE
	WGLOOP3:  ldi  R21, $F8
	WGLOOP4:  dec  R21
			  brne WGLOOP4
			  dec  R20
			  brne WGLOOP3
			  ldi  R20, $07
	WGLOOP5:  dec  R20
			  brne WGLOOP5
			  nop
	ret*/