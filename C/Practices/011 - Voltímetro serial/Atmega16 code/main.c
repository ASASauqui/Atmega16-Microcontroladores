/*
 * Voltimetro por puerto serial.c
 *
 * Created: 03/04/2022 09:03:59 p. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 

// CPU
	#define F_CPU 1000000

// Definiciones del puerto serial
	#define BAUD 4800
	#define MYUBRR F_CPU/16/BAUD-1

// Librerias
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos
	#include <stdint.h>
	#include <stdlib.h>
	#include <avr/interrupt.h>
	#include <time.h>
	
// Vectores
#define ADC_vect _VECTOR(14)
	
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
	
// Esqueletos de comunicacion serial
	void USART_Init(uint16_t ubrr);
	void USART_Transmit(uint8_t data);
	uint8_t USART_Receive(void);
	
// Esqueletos de funciones utiles
	uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT);
		

int main(void)
{
	/*
	// Inicializacion del LCD
	LCD_init();
	LCD_wr_instruction(0b10000000); //posición cero!
	*/
	
	// Configuracion del puerto A
	DDRA = 0b00000000;			
	PORTA = 0b00000000;	
	
	// Inicializacion del puerto serial
	USART_Init(MYUBRR);
	
	// Interrupciones
	sei();
	
	// Configuracion del Timer0 (CTC)
	OCR0 = 97;
	TCNT0 = 0;
	TCCR0 = 0b00001101;
	
	// Banderas
	TIFR = 0b00000011;
	TIMSK = 0b00000010;
	
	// ADC
	ADMUX = 0b01100010;
	SFIOR = 0b01100000;
	ADCSRA = 0b10111011;
	
	
	
	while (1)
	{
		
	}
}

ISR(ADC_vect){
	uint8_t resADC = ADCH;
	
	// LCD_wr_instruction(0b10000000); //posición cero!
	// printValues(ADCH);
	
	USART_Transmit(resADC);
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



// Funciones del puerto serial
void USART_Init(uint16_t ubrr){
	// Entradas y salidas
	DDRD |= 0b00000010;
	
	// Set baud rate
	UBRRH = (uint16_t) (ubrr >> 8);
	UBRRL = (uint16_t) ubrr;
	
	// Enable receiver and transmitter
	UCSRB = (1<<RXEN) | (1<<TXEN) | (1<<RXCIE); // (recep, trans, int)
	// Set frame format: 8data, 2stop bit
	UCSRC = (1<<URSEL) | (1<<USBS) | (3<<UCSZ0);
}

void USART_Transmit(uint8_t data){
	// Wait for empty transmit buffer
	while( !(UCSRA & (1<<UDRE)) ) {}
	
	// Put data into buffer, sends the data
	UDR = data;
}

uint8_t USART_Receive(void){ // Esta se utiliza cuando no se ocupa la interrupcion de recepcion
	// Wait for data to be received
	while( !(UCSRA & (1<<RXC)) ) {}
	
	// Get and return received data from buffer
	return UDR;
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
