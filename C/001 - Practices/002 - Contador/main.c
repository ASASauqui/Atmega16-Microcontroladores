/*
 * Contador.c
 *
 * Created: 01/02/2022 03:09:19 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

#define  F_CPU 1000000

#include <avr/io.h>
#include <stdio.h>			// Tiene variables tipo uint8_t
#include <util/delay.h>		// Para poder hacer retardos


// Protipado de funciones


int main(void)
{
	// Configuracion del puerto A
	DDRA = 0b00000000;			// A es de entrada
	PORTA = 0b11111111;			// A con Pull-Ups
	
	// Configuracion del puerto  C
	DDRC = 0b11111111;			// C es de salida
	PORTC = 0b00000000;			// C saca ceros al principio
	
	// Inicializacion de variables
	uint8_t contador = 0;
	uint8_t unidades = 0, decenas = 0, imprimir = 0;
	
	// Imprimir ceros
	PORTC = 0;
	
	
	while (1)
	{
		if(!(PINA & (1<<0))){
			_delay_ms(50);
			if(contador < 99){
				contador++;
				
				// Traba
				while(!(PINA & (1<<0))){
					
				}
				
				unidades = contador%10;
				unidades = unidades<<4;
				
				decenas = contador/10;
				
				imprimir = unidades | decenas;
				
				PORTC = imprimir;
			}
			_delay_ms(50);
		}
		else if(!(PINA & (1<<7))){
			_delay_ms(50);
			if(contador > 0){
				contador--;
				
				// Traba
				while(!(PINA & (1<<7))){
					
				}
				
				unidades = contador%10;
				unidades = unidades<<4;
				
				decenas = contador/10;
				
				imprimir = unidades | decenas;
				
				PORTC = imprimir;
			}
			_delay_ms(50);
		}
	}
}

