#include <xc.h>
#include "SPI.h"

void INICIO_SPI(char reloj,char modo, char smp)
{
	SSPSTATbits.SMP=smp;
	SSPCON1 = reloj;
	if(modo == 'A')
	{
		SSPSTATbits.CKE = 1;
		SSPCON1bits.CKP = 1;
	}
	else if(modo == 'B')
	{
		SSPSTATbits.CKE = 1;
		SSPCON1bits.CKP = 0;
	}
	else if(modo == 'C')
	{
		SSPSTATbits.CKE = 0;
		SSPCON1bits.CKP = 1;
	}	
	else if(modo == 'D')
	{
		SSPSTATbits.CKE = 0;
		SSPCON1bits.CKP = 0;
	}
	SSPCON1bits.SSPEN = 1;
}

void TX_SPI(char dato)
{
	SSPBUF = dato;
	while(PIR1bits.SSPIF == 0);
	PIR1bits.SSPIF = 0;

}

char RX_SPI(char dato)
{
	SSPBUF = dato;
	while(PIR1bits.SSPIF == 0);
	PIR1bits.SSPIF = 0;
	dato = SSPBUF;
	return(dato);
}