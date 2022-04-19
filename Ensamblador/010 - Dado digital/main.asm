;
; Dado.asm
;
; Created: 14/10/2021 03:23:48 p. m.
; Author : Alan Samuel Aguirre Salazar
;

.include "m16def.inc"     
 
	.org 0x0000
	jmp RESET

	.org $02
	jmp INT0_vect ; IRQ1 Handler

RESET:
	;Primero inicializamos el stack pointer...
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16 

	ldi R16, 0b1111_1111
	out DDRA, R16 //	Configuré el puerto del teclado SALIDAS:ENTRADAS
	//CONFIGURAR LO DEMÁS QUE HAGA FALTA...

	ldi R16, 0b0000_0000
	out PORTA, R16

	sei 

	ldi R16, 0b0000_0010
	out MCUCR, R16

	ldi R16, 0b1110_0000
	out GIFR, R16

	ldi R16, 0b0100_0000
	out GICR, R16

	// Entrada
	ldi R16, 0b0000_0000
	out DDRD, R16

	ldi R16, 0b1111_1111
	out PORTD, R16

	ldi R16, 1

	rjmp CONTAR


CONTAR:
	rcall RETARDOMINI
	ldi R16, 0b0100_0000
	rcall RETARDOMINI
	ldi R16, 0b0001_0010
	rcall RETARDOMINI
	ldi R16, 0b0110_0001
	rcall RETARDOMINI
	ldi R16, 0b0010_1101
	rcall RETARDOMINI
	ldi R16, 0b0110_1101
	rcall RETARDOMINI
	ldi R16, 0b0011_1111
	rcall RETARDOMINI
	ldi R16, 0b0111_1111
	rjmp CONTAR




INT0_vect:
	rcall RETARDO
	TRABA:
		sbis PIND, 2
			rjmp TRABA

	out PORTA, R16
	rcall RETARDO
	reti




RETARDO:
          ldi  R30, $65
WGLOOP0:  ldi  R31, $A4
WGLOOP1:  dec  R31
          brne WGLOOP1
          dec  R30
          brne WGLOOP0
          ldi  R30, $01
WGLOOP2:  dec  R30
          brne WGLOOP2
          nop
          nop

	ret

RETARDOMINI:
          ldi  R30, $21
WGLOOP3:  ldi  R31, $64
WGLOOP4:  dec  R31
          brne WGLOOP4
          dec  R30
          brne WGLOOP3
          nop
ret





