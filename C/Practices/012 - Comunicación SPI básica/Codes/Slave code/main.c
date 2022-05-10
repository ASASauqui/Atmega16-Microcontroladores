/*
 * Slave.c
 *
 * Created: 10/05/2022 12:12:43 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

// CPU.
	#define F_CPU 8000000

// Librerías.
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos.
	#include <stdint.h>
	#include <stdlib.h>
	#include <avr/interrupt.h>
	#include <time.h>

// Esqueletos de funciones útiles.
	uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT);
	
// Esqueletos de funciones de comunicación SPI básica.
	void SPI_Slave_init();
	uint8_t SPI_Receive();

int main(void)
{	
	// Configuracion del puerto C.
	DDRC = 0b11111111;
	PORTC = 0b00000000;
	
	// Iniciar esclavo.
	SPI_Slave_init();
	
	// Variables
	uint8_t resultado;
	
    while (1) 
    {
		// Llamar para recibir dato.
		resultado = SPI_Receive();
		
		// Imprimir dato en el puerto C.
		PORTC = resultado;
		
		// Esperar un segundo.
		_delay_ms(1000);
		
		// Volver el puerto C a ceros.
		PORTC = 0b00000000;
    }
}

// Funciones de comunicación SPI básica.
void SPI_Slave_init(){
	// Configurar el puerto (MISO como salida, MOSI, SCK y SS como entrada).
	DDRB = 0b01000000;
	
	// Configurar SPCR (Habilitarlo y ponerlo como esclavo…), si hiciera falta también SPSR (para interrupciones o velocidad).
	SPCR = (1<<SPE) | (0<<MSTR) | (1 << SPR1) | (1 << SPR0);
	SPSR = 0b00000000;
}

uint8_t SPI_Receive(){	
	// Esperar hasta que el bit SPIF tenga un 1 (o bien hasta que se genere la interrupción).
	while(cero_en_bit(&SPSR, SPIF)){}
		
	// Leer el valor del SPDR.
	uint8_t data = SPDR;
	SPDR = 0b00000000;
	
	return data;
}



// Funciones útiles.
uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT){
	return (!(*LUGAR&(1<<BIT)));
}

uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT){
	return (*LUGAR&(1<<BIT));
}

void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT){
	*LUGAR=*LUGAR|(1<<BIT);
}

void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT){
	*LUGAR=*LUGAR&~(1<<BIT);
}


