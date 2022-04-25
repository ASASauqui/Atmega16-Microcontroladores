/*
 * Timer0 PWM.c
 *
 * Created: 10/02/2022 03:03:06 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 
 

#define  F_CPU 4000000
#define PINT PINA
#define PORTT PORTA
#define DDRT DDRA

#include <avr/io.h>
#include <stdio.h>			// Tiene variables tipo uint8_t
#include <util/delay.h>		// Para poder hacer retardos


// Protipado de funciones
uint8_t cero_en_bit(volatile uint8_t *pine, uint8_t noBit);
uint8_t teclado();

int main(void)
{
	// Configuracion del puerto A
	DDRT = 0b00001111;			// A salida-entrada
	PORTT = 0b11111111;			// A sacando 1s y con Pull-Ups
	
	// Configuracion del puerto  C
	DDRC = 0b11111111;			// C es de salida
	PORTC = 0b00000000;			// C saca ceros al principio
	
	// Configuracion del puerto  B
	DDRB = 0b11111111;			// B es de salida
	
	// Configuracion del timer
	TCNT0 = 0b00000000;
	OCR0 = 40;
	TCCR0 = 0b01101100;
	
	
	
	// Inicializacion de variables
	uint8_t contador = 0;
	uint8_t valores[10] = {0b00000000,
						   0b00001000,
						   0b00000100,
						   0b00001100,
						   0b00000010,
						   0b00001010,
						   0b00000110,
						   0b00001110,
						   0b00000001, 
						   0b00001001};
	uint8_t OCR0s[10] = {40, 37, 34, 31, 27, 24, 20, 17, 13, 10};
	
	
	
	uint8_t tecla = 0;
	while (1)
	{
		tecla = teclado();
		
		if(tecla == 9){
			if(contador < 9){
				contador++;
				
				PORTC = valores[contador] << 2;
			}
		}
		else if(tecla == 1){
			if(contador > 0){
				contador--;
				
				PORTC = valores[contador] << 2;
			}
			
		}
		else if(tecla == 13){
			OCR0 = OCR0s[contador];
		}
		
	}
}


uint8_t cero_en_bit(volatile uint8_t *pine, uint8_t noBit){
	return !(*pine & (1<<noBit));
}

uint8_t teclado(){
	// Numeros del teclado
	uint8_t numeros[4][4] = {{13,12,11,10},
							 {14, 9, 6, 3},
							 { 0, 8, 5, 2},
							 {15, 7, 4, 1}};
	
	// Checar teclado
	while(1){
		// For que deja de mandar corriente
		for(uint8_t i=0;i<4;i++){
			PORTT = ~(1<<i);
			asm("nop");
			
			// For que checa el boton de esa columna
			for(uint8_t j=4, k=0; j<8; j++, k++){
				if(cero_en_bit(&PINT, j)){
					_delay_ms(50);
					while(cero_en_bit(&PINT, j)){
						
					}
					_delay_ms(50);
					
					return numeros[i][k];
				}
			}
		}
	}
}


