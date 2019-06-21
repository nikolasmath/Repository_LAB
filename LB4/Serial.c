#include <xc.h>
#include "Serial.h"

void TX_CHAR_EUSART(char num)
{
	TXREG = num;
	while(TXSTAbits.TRMT == 0);
}

void Abrir_Serial(int velocidad)
{
	SPBRG = (unsigned char)velocidad;
	SPBRGH = velocidad>>8;
	TXSTAbits.SYNC = 0; //Modo asíncrono
	TXSTAbits.BRGH = 0;
	BAUDCONbits.BRG16 = 1;
	RCSTAbits.SPEN = 1; //Habilitar módulo EUSART
	TXSTAbits.TXEN = 1; //Habilitar la transmisión
	RCSTAbits.CREN = 1;
	PIE1bits.RCIE = 1; //Habilitar la interrupción por rx
	INTCONbits.PEIE = 1;
	INTCONbits.GIE = 1;
}

void TX_MENSAJE_EUSART(const unsigned char *vector,unsigned char pos)
{
	unsigned char i = 0;
	for(i = 0; i<pos; i++)
	{
		TX_CHAR_EUSART(vector[i]);
	}
}