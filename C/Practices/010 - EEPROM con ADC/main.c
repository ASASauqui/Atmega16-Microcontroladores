/*
 * ADC y EEPROM.c
 *
 * Created: 20/03/2022 04:19:53 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

// Librerias
	#define F_CPU 1000000
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos
	#include <stdint.h>
	#include <stdlib.h>
	#include <avr/interrupt.h>
	#include <time.h>
	
// Definiciones del teclado
	#define DDRT DDRD
	#define PORTT PORTD
	#define PINT PIND

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

// Esqueletos del EEPROM
	void EEPROM_write(volatile uint16_t dir, volatile uint8_t data);
	uint8_t EEPROM_read(uint16_t dir);

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
	uint8_t teclado();
	uint8_t tecladoI();
	
// Funciones a usar
	void inicio();
	void recorrerEEPROM();
	void printValues(uint8_t valor);
	void printValues16(uint16_t valor);
	
// Variables
	volatile uint16_t contEEPROM = 0;
	volatile uint16_t maxEEPROM = 0;
	volatile uint8_t lleno = 0;


int main(void)
{
	// Inicializacion del LCD
		LCD_init();
		LCD_wr_instruction(0b10000000); //posición cero!
	
	// Configuracion del puerto A (potenciometro)
		DDRA = 0b00000000;
		PORTA = 0b00000000;
	
	// Configuracion del puerto D (Teclado)
		DDRT = 0b00001111;
		PORTT = 0b11111111;
	
	
	
	// Configuracion del Timer0 (CTC)
		// OCR0
		OCR0 = 243; // 0.25
		// TCNT0
		TCNT0 = 0;
		// TCCR0
		TCCR0 = 0b00001101;
		
	// Banderas
		TIFR = 0b00000011;
		TIMSK = 0b00000010;
		
	// ADC
		ADMUX = 0b01100000;
		SFIOR = 0b01100000;
		ADCSRA = 0b10111011;
		
	// Interrupciones
		sei();
		

		
	
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_string("Sensando...");
	
	inicio();
	
	while (1)
	{
		
	}
}

void inicio(){
	while (1)
	{
		uint8_t tecla = tecladoI();
		if(tecla == 2){
			TCCR0 = 0;
			TCNT0 = 0;
				
			LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
			LCD_wr_instruction(0b10000000); //posición cero!
			LCD_wr_string("Ultimos val.");
			LCD_wr_instruction(0b11000000); //segundo renglon!
				
			recorrerEEPROM();
		}
	}
}

void recorrerEEPROM(){
	contEEPROM--;
	
	uint8_t memoria = EEPROM_read(contEEPROM);
	LCD_wr_instruction(0b11000000); //segundo renglon!
	printValues(memoria);
	LCD_wr_instruction(0b11000101); //segundo renglon!
	printValues16(contEEPROM);
		
	uint8_t tecla = 0;
		
	while(1){
		tecla = teclado();
			
		// Atras
		if(tecla == 1){
			if(contEEPROM > 0){
				contEEPROM--;
				memoria = EEPROM_read(contEEPROM);
				LCD_wr_instruction(0b11000000); //segundo renglon!

				printValues(memoria);
				
				LCD_wr_instruction(0b11000101); //segundo renglon!
				printValues16(contEEPROM);
				//LCD_wr_string("Menos");
			}
		}
		// Adelante
		else if(tecla == 3){
			if(contEEPROM < maxEEPROM){
				contEEPROM++;
				memoria = EEPROM_read(contEEPROM);
				LCD_wr_instruction(0b11000000); //segundo renglon!
					
				printValues(memoria);
				
				LCD_wr_instruction(0b11000101); //segundo renglon!
				printValues16(contEEPROM);
				//LCD_wr_string("Mas");
			}
		}
		// Sensar
		else if(tecla == 2){
			LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
			LCD_wr_instruction(0b10000000); //posición cero!
			LCD_wr_string("Sensando...");
				
			contEEPROM = 0;
			lleno = 0;
				
			// TCNT0
			TCNT0 = 0;
			// TCCR0
			TCCR0 = 0b00001101;
				
			inicio();
		}
	}
}

void printValues(uint8_t valor){
	uint8_t num[3] = {0};
	uint8_t i = 0;
	
	while(valor > 0){
		num[i] = valor%10;
		valor /= 10;
		i++;
	}
	
	for(int i=2;i>=0;i--){
		LCD_wr_char(num[i] + 48);
	}
}

void printValues16(uint16_t valor){
	uint16_t num[3] = {0};
	uint8_t i = 0;
	
	while(valor > 0){
		num[i] = valor%10;
		valor /= 10;
		i++;
	}
	
	for(int i=2;i>=0;i--){
		LCD_wr_char(num[i] + 48);
	}
}

ISR(TIMER0_COMP_vect){
	
}


ISR(ADC_vect){
	uint8_t resADC = ADCH;
	
	if(contEEPROM <= 511){
		maxEEPROM = contEEPROM;
		EEPROM_write(contEEPROM, resADC);
		
		contEEPROM++;
	}
	else{
		TCCR0 = 0;
		TCNT0 = 0;
		lleno = 1;
	}
	TCNT0 = 0;
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


// Funciones del EEPROM
void EEPROM_write(volatile uint16_t dir, volatile uint8_t data){
	while(uno_en_bit(&EECR, EEWE)){}
	
	EEAR = dir;
	EEDR = data;
	
	cli();
	EECR |= (1<<EEMWE);
	EECR |= (1<<EEWE);
	sei();
}

uint8_t EEPROM_read(uint16_t dir){
	while(uno_en_bit(&EECR, EEWE)){}

	EEAR = dir;
	
	EECR |= (1<<EERE);
	
	return EEDR;
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

// Funciones del teclado
uint8_t teclado(){
	// Numeros del teclado
	uint8_t teclado[4][4] = {{1, 2, 3,10},
							 {4, 5, 6,11},
							 {7, 8, 9,12},
							{14, 0,15,13}};
								
	// Checar teclado
	while(1){
		// For que deja de mandar corriente
		for(int i=0; i<4; i++){
			PORTT = ~(1<<i);
			asm("nop");
			
			// For que checa el boton de esa columna
			for(int j = 0; j<4; j++){
				if(cero_en_bit(&PINT, j+4)){
					_delay_ms(50);
					while(cero_en_bit(&PINT, j+4));
					_delay_ms(50);
					return teclado[i][j];
				}
			}
		}
	}
}

uint8_t tecladoI(){
	// Numeros del teclado
	uint8_t teclado[4][4] = {{1, 2, 3,10},
	{4, 5, 6,11},
	{7, 8, 9,12},
	{14, 0,15,13}};
		
	// Checar teclado
	while(1){
		// For que deja de mandar corriente
		for(int i=0; i<4; i++){
			PORTT = ~(1<<i);
			asm("nop");
			
			// For que checa el boton de esa columna
			for(int j = 0; j<4; j++){
				if(lleno == 1){
					LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
					LCD_wr_instruction(0b10000000); //posición cero!
					LCD_wr_string("EEPROM llena");
					LCD_wr_instruction(0b11000000); //segundo renglon!
								
					recorrerEEPROM();
				}
				
				if(cero_en_bit(&PINT, j+4)){
					_delay_ms(50);
					while(cero_en_bit(&PINT, j+4));
					_delay_ms(50);
					return teclado[i][j];
				}
			}
		}
	}
}


