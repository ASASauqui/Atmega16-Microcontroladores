/*
 * Timer0 LCD.c
 *
 * Created: 17/02/2022 04:20:24 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

// Librerias
	#define F_CPU 1000000
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos
	#include <stdint.h>
	#include <stdlib.h>
	#include <avr/interrupt.h>
	
/* TimerCounter0 Compare Match */
	#define TIMER0_COMP_vect _VECTOR(19)

// Definiciones del LCD
	#define DDRLCD DDRC
	#define PORTLCD PORTC
	#define PINLCD PINC
	#define RS 4
	#define RW 5
	#define E 6
	#define BF 3
	#define LCD_Cmd_Clear      0b00000001
	#define LCD_Cmd_Home       0b00000010
	//#define LCD_Cmd_Mode     0b000001 ID  S
	#define LCD_Cmd_ModeDnS	   0b00000110 //sin shift cursor a la derecha
	#define LCD_Cmd_ModeInS	   0b00000100 //sin shift cursor a la izquierda
	#define LCD_Cmd_ModeIcS	   0b00000111 //con shift desplazamiento a la izquierda
	#define LCD_Cmd_ModeDcS	   0b00000101 //con shift desplazamiento a la derecha
	//#define LCD_Cmd_OnOff    0b00001 D C B
	#define LCD_Cmd_Off		   0b00001000
	#define LCD_Cmd_OnsCsB	   0b00001100
	#define LCD_Cmd_OncCsB     0b00001110
	#define LCD_Cmd_OncCcB     0b00001111
	//#define LCD_Cmd_Shift    0b0001 SC  RL 00
	//#define LCD_Cmd_Function 0b001 DL  N  F  00
	#define LCD_Cmd_Func2Lin   0b00101000
	#define LCD_Cmd_Func1LinCh 0b00100000
	#define LCD_Cmd_Func1LinG  0b00100100
	//#define LCD_Cmd_DDRAM    0b1xxxxxxx


// Esqueletos de funciones del LCD
	void LCD_wr_inst_ini(uint8_t instruccion);
	void LCD_wr_char(uint8_t data);
	void LCD_wr_instruction(uint8_t instruccion);
	void LCD_wait_flag(void);
	void LCD_init(void);
	void LCD_wr_string(volatile uint8_t *s);
	
// Esqueletos de funciones utiles
	uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT);
	
	
// Variables
	volatile uint8_t letra = 'A';
	volatile uint8_t posicion = 0;
	volatile uint8_t sacarPosicion = 0;
	volatile int tiempoContado = 0;
	
	
	


int main(void)
{
	LCD_init();
	LCD_wr_instruction(0b10000000); //posición cero!
	
	// Configuracion del puerto A
	DDRA = 0b00000000;			// A entrada
	PORTA = 0b11111111;			// A con Pull-Ups
	
	// Interrupciones
	sei();
		
	// OCR0
	OCR0 = 124; // 0.001 -> 1000
		
	// TIFR
	TIFR = 0b00000011;
		
	// TIMSK
	TIMSK = 0b00000010;
		
	// TCNT0
	TCNT0 = 0;
	
	while (1)
	{
		if(tiempoContado > 1000){
			// TCCR0
			TCCR0 = 0;
			// TCNT0
			TCNT0 = 0;
		}
				
		if( cero_en_bit(&PINA, 0) ){
			// TCCR0
			TCCR0 = 0;
			// TCNT0
			TCNT0 = 0;
					
			_delay_ms(50);
			while(cero_en_bit(&PINA, 0)){
						
			}
			_delay_ms(50);
					
			if(tiempoContado <= 1000){
				tiempoContado = 0;
						
				sacarPosicion = 0b10000000 | posicion;
				LCD_wr_instruction(sacarPosicion);
				LCD_wr_char(letra);
				letra++;
						
				if(letra > (uint8_t)'Z'){
					letra = 'A';
				}
			}
					
			else{
				tiempoContado = 0;
						
				posicion++;
				letra = 'A';
						
				if(posicion <= 15){
					
					sacarPosicion = 0b10000000 | posicion;
					LCD_wr_instruction(sacarPosicion);
							
					LCD_wr_char(letra);
					letra++;
				}
				else{
					LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
					posicion = -1;
				}
						
			}
					
			// TCCR0
			TCCR0 = 0b00001010;
					
		}
	}
}

ISR(TIMER0_COMP_vect){
	tiempoContado++;
}

// Funciones utiles
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



// Funciones del LCD
void LCD_init(void){
	DDRLCD=(15<<0)|(1<<RS)|(1<<RW)|(1<<E); //DDRLCD=DDRLCD|(0B01111111)
	_delay_ms(15);
	LCD_wr_inst_ini(0b00000011);
	_delay_ms(5);
	LCD_wr_inst_ini(0b00000011);
	_delay_us(100);
	LCD_wr_inst_ini(0b00000011);
	_delay_us(100);
	LCD_wr_inst_ini(0b00000010);
	_delay_us(100);
	LCD_wr_instruction(LCD_Cmd_Func2Lin); //4 Bits, número de líneas y tipo de letra
	LCD_wr_instruction(LCD_Cmd_Off); //apaga el display
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_instruction(LCD_Cmd_ModeDnS); //Entry mode set ID S
	LCD_wr_instruction(LCD_Cmd_OnsCsB); //Enciende el display
}

void LCD_wr_char(uint8_t data){
	//saco la parte más significativa del dato
	PORTLCD=data>>4; //Saco el dato y le digo que escribiré un dato
	saca_uno(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//saco la parte menos significativa del dato
	PORTLCD=data&0b00001111; //Saco el dato y le digo que escribiré un dato
	saca_uno(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	saca_cero(&PORTLCD,RS);
	LCD_wait_flag();
}

void LCD_wr_inst_ini(uint8_t instruccion){
	PORTLCD=instruccion; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
}

void LCD_wr_instruction(uint8_t instruccion){
	//saco la parte más significativa de la instrucción
	PORTLCD=instruccion>>4; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//saco la parte menos significativa de la instrucción
	PORTLCD=instruccion&0b00001111; //Saco el dato y le digo que escribiré un dato
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	saca_uno(&PORTLCD,E);
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	LCD_wait_flag();
}


void LCD_wait_flag(void){
	//	_delay_ms(100);
	DDRLCD&=0b11110000; //Para poner el pin BF como entrada para leer la bandera lo demás salida
	saca_cero(&PORTLCD,RS);// Instrucción
	saca_uno(&PORTLCD,RW); // Leer
	while(1){
		saca_uno(&PORTLCD,E); //pregunto por el primer nibble
		_delay_ms(10);
		saca_cero(&PORTLCD,E);
		if(uno_en_bit(&PINLCD,BF)) {break;} //uno_en_bit para protues, 0 para la vida real
		_delay_us(10);
		saca_uno(&PORTLCD,E); //pregunto por el segundo nibble
		_delay_ms(10);
		saca_cero(&PORTLCD,E);
	}
	saca_uno(&PORTLCD,E); //pregunto por el segundo nibble
	_delay_ms(10);
	saca_cero(&PORTLCD,E);
	//entonces cuando tenga cero puede continuar con esto...
	saca_cero(&PORTLCD,RS);
	saca_cero(&PORTLCD,RW);
	DDRLCD|=(15<<0)|(1<<RS)|(1<<RW)|(1<<E);
}

void LCD_wr_string(volatile uint8_t *s){
	uint8_t c;
	while((c=*s++)){
		LCD_wr_char(c);
	}
}









