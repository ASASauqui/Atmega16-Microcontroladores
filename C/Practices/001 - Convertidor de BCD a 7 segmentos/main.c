/*
 * Convertidor de BCD a 7 segmentos.c
 *
 * Created: 27/01/2022 03:40:07 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

#define  F_CPU 1000000

#include <avr/io.h>
#include <stdio.h>			// Tiene variables tipo uint8_t
#include <util/delay.h>		// Para poder hacer retardos


int main(void)
{
	// Configuracion del puerto A
		DDRA = 0b00000000;			// A es de entrada
		PORTA = 0b11111111;			// A con Pull-Ups
	
	// Configuracion del puerto  C
		DDRC = 0b11111111;			// C es de salida
		PORTC = 0b00000000;			// C saca ceros al principio
		
		uint8_t lectura = 0;
	
    while (1) 
    {
		lectura = PINA;
		
		switch(lectura)
		{
			case 0b11111111:			// Cero
				PORTC = 0b00111111;
				break;
			case 0b11101111:			// Uno
				PORTC = 0b00000110;
				break;
			case 0b11011111:			// Dos
				PORTC = 0b01011011;
				break;
			case 0b11001111:			// Tres
				PORTC = 0b01001111;
				break;
			case 0b10111111:			// Cuatro
				PORTC = 0b01100110;
				break;
			case 0b10101111:			// Cinco
				PORTC = 0b01101101;
				break;
			case 0b10011111:			// Seis
				PORTC = 0b01111101;
				break;
			case 0b10001111:			// Siete
				PORTC = 0b01000111;
				break;
			case 0b01111111:			// Ocho
				PORTC = 0b01111111;
				break;
			case 0b01101111:			// Nueve
				PORTC = 0b01100111;
				break;
			default:
				PORTC = 0b00000000;
				break;
				
		}
    }
}

