/*
 * Compra de productos.c
 *
 * Created: 01/03/2022 07:56:02 a. m.
 * Author : Alan Samuel Aguirre Salazar
 */ 


// Librerias
	#define F_CPU 8000000
	#include <avr/io.h>
	#include <util/delay.h>		// Para poder hacer retardos
	#include <stdint.h>
	#include <stdlib.h>
	#include <avr/interrupt.h>
	
/* External Interrupt Request 2 */ 
	#define INT2_vect _VECTOR(18)

// Definiciones del teclado
	#define PINT PINC
	#define PORTT PORTC
	#define DDRT DDRC

// Definiciones del LCD
	#define DDRLCD DDRA
	#define PORTLCD PORTA
	#define PINLCD PINA
	#define RS 7
	#define RW 6
	#define E 4
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
	uint8_t teclado();
	
// Esqueletos de funciones utiles
	uint8_t cero_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	uint8_t uno_en_bit(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_uno(volatile uint8_t *LUGAR, uint8_t BIT);
	void saca_cero(volatile uint8_t *LUGAR, uint8_t BIT);

// Esqueletos de funciones utilizadas
	void inicio();
	void cambio();
	void reseteoVariables();
	
	
// Variables
	volatile uint8_t tecla = 0;
	volatile uint8_t letra = 0;
	volatile uint8_t numero = 0;
	volatile uint8_t precios[2][2] = {{ 3, 9},
									  {23,31}};
	volatile uint8_t suma = 0;
	volatile uint8_t cambioDinero = 0;
	volatile uint8_t monedaElegida = 0;
	volatile uint8_t monedas[5] = {0,1,2,5,10};	
	volatile uint8_t introducirMonedas = 0;
		
	

	

	


int main(void)
{
	LCD_init();
	LCD_wr_instruction(0b10000000); //posición cero!
	
	// Configuracion del puerto B
	DDRB = 0b00001011;			
	PORTB = 0b11110111;		
	
	// Configuracion del puerto C
	DDRT = 0b00001111;			// C salida-entrada
	PORTT = 0b11111111;			// C sacando 1s y con Pull-Ups
	
	// Interrupciones
	sei();
	
	GIFR = 0b11100000;
	MCUCSR = 0b01000000;
	GICR = 0b00100000;
	
	inicio();
	
	while (1)
	{
		
	}
}

void inicio(){
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_string("Elige Producto");
	LCD_wr_instruction(0b11000000);
	LCD_wr_instruction(0b00001101); //Enciende el display con el cursos parpadeando
	
	// Letras
		do{
			tecla = teclado();
		}
		while( tecla != 10 && tecla != 11 );
		
		if(tecla == 10){
			letra = 0;
			LCD_wr_char('A');
		}
		else{
			letra = 1;
			LCD_wr_char('B');
		}
	// Numeros
		do{
			tecla = teclado();
		}
		while( tecla != 1 && tecla != 2 );
		
		
		if(tecla == 1){
			numero = 0;
			LCD_wr_char(1+48);
		}
		else{
			numero = 1;
			LCD_wr_char(2+48);
		}
		
	// Inserta
		LCD_wr_instruction(0b00001100); //Enciende el display con el cursos parpadeando
		LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
		LCD_wr_instruction(0b10000000);
		LCD_wr_string("Inserta $");
		
		if(precios[letra][numero] < 10){
			LCD_wr_char(precios[letra][numero] + 48);
		}
		else{
			LCD_wr_char( (precios[letra][numero]/10) + 48 );
			LCD_wr_char( (precios[letra][numero]%10) + 48 );
		}
		LCD_wr_string(".00");
		LCD_wr_instruction(0b11000000);
		
	// Tienes
	LCD_wr_instruction(0b11000000);
	LCD_wr_string("Tienes $00.00");
	introducirMonedas = 1;
	while(suma < precios[letra][numero]){	
		
	}
	introducirMonedas = 0;
	cambio();
		

}

void cambio(){
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_instruction(0b10000000);
	LCD_wr_string("Entregando...");
	LCD_wr_instruction(0b11000000);
	LCD_wr_string("Cambio ");
	
	cambioDinero = suma - precios[letra][numero];
	if(cambioDinero < 10){
		LCD_wr_string("$0");
		LCD_wr_char(cambioDinero + 48);
		LCD_wr_string(".00");
	}
	else{
		LCD_wr_string("$");
		LCD_wr_char( (cambioDinero/10) + 48 );
		LCD_wr_char( (cambioDinero%10) + 48 );
		LCD_wr_string(".00");
	}
	saca_uno(&PORTB,3);
	_delay_ms(2000);
	
	reseteoVariables();
	inicio();
}



ISR(INT2_vect){
	
	if(cero_en_bit(&PINB, 2)){
		while(cero_en_bit(&PINB, 2)){
			
		}
	}
	
	if(introducirMonedas == 1){
		monedaElegida = (PINB >> 4);
		if(monedaElegida >= 1 && monedaElegida <= 4){
			suma += monedas[monedaElegida];
			LCD_wr_instruction(0b11000111);
			
			if(suma < 10){
				LCD_wr_string("$0");
				LCD_wr_char(suma + 48);
				LCD_wr_string(".00");
			}
			else{
				LCD_wr_string("$");
				LCD_wr_char( (suma/10) + 48 );
				LCD_wr_char( (suma%10) + 48 );
				LCD_wr_string(".00");
			}
		}
	}
	

}

void reseteoVariables(){
	tecla = 0;
	letra = 0;
	numero = 0;
	suma = 0;
	cambioDinero = 0;
	monedaElegida = 0;
	introducirMonedas = 0;
	
	saca_cero(&PORTB,3);
	
	LCD_wr_instruction(LCD_Cmd_Clear); //limpia el display
	LCD_wr_instruction(0b10000000);
	
	return;
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

// Teclado
uint8_t teclado(){
	// Numeros del teclado
	uint8_t numeros[4][4] = {{15, 0,14,13},
							 { 1, 2, 3,12},
							 { 4, 5, 6,11},
							 { 7, 8, 9,10}};
								 
	
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











