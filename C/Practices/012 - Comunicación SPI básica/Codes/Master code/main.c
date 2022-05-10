/*
 * Master.c
 *
 * Created: 03/05/2022 04:22:52 p. m.
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
	void SPI_Master_init();
	uint8_t SPI_Transmit(uint8_t slavePin, uint8_t data);

int main(void)
{	
	// Configuracion del puerto C.
	DDRC = 0b00000000;
	PORTC = 0b00000001;
	
	// Iniciar maestro.
	SPI_Master_init();
	
	// Variables.
	uint8_t basura;
	
    while (1) 
    {
		// Cuando sea cero el pin del botón.
		if(cero_en_bit(&PINC, 0)){
			
			// Traba para el botón.
			_delay_ms(50);
			while(cero_en_bit(&PINC, 0)){}
			_delay_ms(50);
			
			// Transmitir al esclavo 6.
			basura = SPI_Transmit(6, 0b11111110);
			
			// Transmitir al esclavo 7.
			basura = SPI_Transmit(7, 0b11110000);
		}
    }
}

// Funciones de comunicación SPI básica.
void SPI_Master_init(){
	// Configuracion del puerto A para la elección de esclavos.
	DDRA = 0b11111111;
	
	// Poner un 1 en todos los bits SS de los esclavos.
	PORTA = 0b11111111;
	
	// Configurar el puerto (MOSI, SCK como salidas, MISO como entrada, los bits que irán a SS como salidas).
	DDRB = 0b10100000;
	
	// Configurar SPCR, si hiciera falta también SPSR (para interrupciones o velocidad).
	SPCR = (1<<SPE) | (1<<MSTR) | (1 << SPR1) | (1 << SPR0);
	SPSR = 0b00000000;
}

uint8_t SPI_Transmit(uint8_t slavePin, uint8_t data){
	// Seleccionar el esclavo con el que se quiere comunicar (poner un 0).
	saca_cero(&PORTA, slavePin);
	
	// Escribir el dato en SPDR.
	SPDR = data;
	
	// Esperar hasta que el bit SPIF se tenga un 1 (para garantizar que terminó la transmisión).
	while(cero_en_bit(&SPSR, SPIF)){}
		
	// Regresar el bit del esclavo a 1.
	saca_uno(&PORTA, slavePin);
		
	// Guardar dato.
	uint8_t res = SPDR;
	
	// Enviar dato.
	return res;
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

