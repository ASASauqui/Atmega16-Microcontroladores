/*
 * ADC con disparador y Timer2.c
 *
 * Created: 10/03/2022 03:21:45 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

// Librerias
	#define F_CPU 1000000
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos
	#include <stdint.h>
	#include <stdlib.h>
	#include <math.h>
	#include <avr/interrupt.h>
	
// Vectores
	#define ADC_vect _VECTOR(14)
		

int main(void)
{
	// Configuracion del puerto A
	DDRA = 0b00000000;			
	PORTA = 0b00000000;	
	
	// Configuracion del puerto B
	DDRD = 0b11111111;
	PORTD = 0b00000000;	
	
	
	// Configuracion del Timer0 (CTC)
	TCNT0 = 0b00000000;
	OCR0 = 97;
	TCCR0 = 0b00001101;
	
	// Configuracion del Timer2 (Fast PWM)
	TCNT2 = 0b00000000;
	OCR2 = 0;
	TCCR2 = 0b01101001;
	
	// Banderas
	TIFR = 0b00000011;
	TIMSK = 0b00000010;
	
	// ADC
	ADMUX = 0b01000010;
	SFIOR = 0b01100000;
	ADCSRA = 0b10111011;
	
	// Interrupciones
	sei();
	
	while (1)
	{
		
	}
}

ISR(ADC_vect){
	uint16_t resADC = ADC;
	
	OCR2 = resADC >> 2;
	TCNT2 = 0;
}
