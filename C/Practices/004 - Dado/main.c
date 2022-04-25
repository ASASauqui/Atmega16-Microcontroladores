/*
 * Dado.c
 *
 * Created: 08/02/2022 03:24:58 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

#define  F_CPU 1000000

#include <avr/io.h>
#include <stdio.h>			// Tiene variables tipo uint8_t
#include <util/delay.h>		// Para poder hacer retardos
#include <avr/interrupt.h>
#include <stdlib.h>
#include <time.h>

// Vector interrupcion
#define INT0_vect _VECTOR(1)


// Protipado de funciones
uint8_t cero_en_bit(volatile uint8_t *pine, uint8_t noBit);


int main(void)
{
	// Configuracion del puerto D
	DDRD = 0b00000000;			// D entrada
	PORTD = 0b11111111;			// D con Pull-Ups
	
	// Configuracion del puerto  A y B
	DDRA = 0b11111111;			// A es de salida
	PORTA = 0b00000000;			// A saca ceros al principio
	
	DDRB = 0b11111111;			// B es de salida
	PORTB = 0b00000000;			// B saca ceros al principio
	
	sei();						// Activar interrupciones
	
	GIFR = 0b11100000;
	MCUCR = 0b00000010;
	GICR = 0b01000000;
	
	srand(time(0));
	
	while (1)
	{
		
	}
}

uint8_t cero_en_bit(volatile uint8_t *pine, uint8_t noBit){
	return !(*pine & (1<<noBit));
}

ISR(INT0_vect){
	_delay_ms(50);
	while(cero_en_bit(&PIND, 2)){
		
	}
	_delay_ms(50);
	
	 volatile uint8_t random_number = (rand() % (6 - 1 + 1)) + 1;
	 
	 if(random_number == 1){
		 PORTA = 0b00000000;
		 PORTB = 0b00000001;
	 }
	 else if(random_number == 2){
		 PORTA = 0b00100100;
		 PORTB = 0b00000000;
	 }
	 else if(random_number == 3){
		 PORTA = 0b10000001;
		 PORTB = 0b00000001;
	 }
	 else if(random_number == 4){
		 PORTA = 0b10100101;
		 PORTB = 0b00000000;
	 }
	 else if(random_number == 5){
		 PORTA = 0b10100101;
		 PORTB = 0b00000001;
	 }
	 else if(random_number == 6){
		 PORTA = 0b11100111;
		 PORTB = 0;
	 }
}






