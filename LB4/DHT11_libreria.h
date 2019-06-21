#include <stdio.h>
#include <stdint.h>
#define _XTAL_FREQ 48000000UL


void DHT11_init(void)
{    
    TRISBbits.RB0 = 0;  // salida
    LATBbits.LATB0 = 0;  // pulso 0
    __delay_ms(18);  // espera 18 ms
    LATBbits.LATB0= 1;  // puslo 1
    __delay_us(20);  // espera 40 us
    TRISBbits.RB0 = 1;  // ahora como entrada
    
}

int DHT11_CheckResponse(void)
{
    int cont = 0;
    while(PORTBbits.RB0){
        cont ++;
        if (cont == 500){
        
            return 0;
        }
        
        
        
    };  // espera un 0 y se rompe
    cont = 0;
    while(PORTBbits.RB0==0 ){  // espera un 1 y se rompe
       cont ++;
        if (cont == 500){
        
            return 0;
        }
    };
    cont = 0;
    while(PORTBbits.RB0){  // espera un 0 y se rompe 
            cont ++;
        if (cont == 500){
        
            return 0;
        }
    };
    return 1; // conexion correcta 
}

int DHT11_ReadData(int *hum,int *dhum,int *temp, int *dtemp) {
    uint8_t bits[5];
    int data,cont_read;
    
    
    for (int i=0; i < 5; i++){
        data = 0;
    for(int j=0;j<8;j++)
    {   
        cont_read = 0;
        while(PORTBbits.RB0==0){
        cont_read ++;
        if (cont_read == 500){
        
            return 0;
        }
        
        };  // se rompe si es 1
        __delay_us(30);         // tiempo para concer si el bit es 1 o 0
        if(PORTBbits.RB0) { // si al pasar el tiempo sigue en 1 entonces es 1   
          data = ((data<<1) | 1);
        } 
        else{                  // si al sobrepasar el tiempo es 0 entonces es 0
          data = (data<<1);}
        cont_read = 0;
        while(PORTBbits.RB0){
        
        cont_read ++;
        if (cont_read == 500){
        
            return 0;
        }
        
        }; // se rompe si es 0
    }
        bits[i] = data;
    
    }
    
    if ((bits[0] + bits[1] + bits[2] + bits[3]) == bits[4])	//Pregunta por el chekin
	{
    
        *hum = bits[0];
        *dhum = bits[1];
        *temp = bits[2];
        *dtemp = bits[3];
        
        
        return 1;
        
    }
    return 0;
}

