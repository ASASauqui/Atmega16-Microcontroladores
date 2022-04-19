/*
 * Teclado matricial.c
 *
 * Created: 03/02/2022 03:31:22 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

#define  F_CPU 1000000
#define PINT PINA
#define PORTT PORTA
#define DDRT DDRA

#include <avr/io.h>
#include <stdio.h>			// Tiene variables tipo uint8_t
#include <util/delay.h>		// Para poder hacer retardos


// Protipado de funciones
uint8_t cero_en_bit(uint8_t *pine, uint8_t noBit);
uint8_t teclado();

int main(void)
{
	// Configuracion del puerto A
	DDRT = 0b00001111;			// A salida-entrada
	PORTT = 0b11111111;			// A sacando 1s y con Pull-Ups
	
	// Configuracion del puerto  C
	DDRC = 0b11111111;			// C es de salida
	PORTC = 0b00000000;			// C saca ceros al principio
	
	// Configuracion del puerto  D
	DDRD = 0b11111111;			// D es de salida
	PORTD = 0b00000000;			// D saca ceros al principio
	
	// Inicializacion de variables
	
	
	
	uint8_t tecla = 0, displayC = 0, displayD = 0;
	while (1)
	{
		tecla = teclado();
		
		if(tecla == 15){
			PORTC = 0;
			PORTD = 0;
			displayC = 0;
			displayD = 0;
		}
		else if(tecla >= 0 && tecla <= 9){
			displayD = 0;
			displayD = displayC >> 4;
			
			displayC = displayC << 4;
			displayC = displayC | tecla;
			
			PORTC = displayC;
			PORTD = displayD;
		}
		
	}
}


uint8_t cero_en_bit(uint8_t *pine, uint8_t noBit){
	if(!(*pine & (1<<noBit))){
		return 1;
	}
	return 0;
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



