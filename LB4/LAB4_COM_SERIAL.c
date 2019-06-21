#pragma config PLLDIV = 1 // PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly)) 
#pragma config CPUDIV = OSC1_PLL2// System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2]) 
#pragma config FOSC = XTPLL_XT // Oscillator Selection bits (XT oscillator, PLL enabled (XTPLL)) 
#pragma config PWRT = ON // Power-up Timer Enable bit (PWRT enabled) 
#pragma config BOR = OFF // Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software) 
#pragma config WDT = OFF // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit)) 
#pragma config CCP2MX = ON // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1) 
#pragma config PBADEN = OFF // PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset) 
#pragma config MCLRE = ON // MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled) 
#pragma config LVP = OFF // Single-Supply ICSP Enable bit (Single-Supply ICSP disabled) 

#include <xc.h>
#include "Serial.h"
//#include "LCD.h"
#include "lib_converter.h"
#include "DHT11_libreria.h"
#define _XTAL_FREQ 48000000UL

int digdmi = 0;
int digmil = 0;
int digcen = 0;
int digdec = 0;
int diguni = 0;
int temporal = 0;
int temporal2 = 0;
int temporal3 = 0;

int hum,dhum,temp,dtemp,status,chekin;
int enter,opc,aux;
float temper,y;
int x ;
int aux_temp = 0, aux_hum = 0;
void DIGITOS(int valor){
    
    digdmi = valor / 10000;
    temporal3 = valor - (digdmi * 10000);
    digmil = temporal3 / 1000;
    temporal = temporal3 - (digmil * 1000);
    digcen = temporal / 100;
    temporal2 = temporal - (digcen * 100);
    digdec = temporal2 / 10;
    diguni = temporal2 - (digdec * 10);        
}







void main(void) {
    
    Abrir_Serial(_19200);
    
    TRISBbits.RB1 = 0; // salida del servo 
    TRISDbits.RD0 = 0;
    // configuracion de prioridades
    RCONbits.IPEN = 1;     
    // altas prioridades
    INTCON2bits.TMR0IP = 1;  //alta prioridad para la temperatura 
    IPR1bits.TMR1IP = 1;  // baja prioridad para el servomotor 
    // baja prioridades
    
    IPR1bits.RCIP = 0;  // baja prioridad para RX
    
    /****************/
    PIE1bits.TMR1IE = 1; // habilitando interrupcion TMR1
    INTCONbits.TMR0IE = 1; // habilitando interrupcion de TMR0
    PIE1bits.RCIE = 1; // Habilitado interrupcion de RCIE
    
    /***************/
    // configuracion  de TMR0 para temperatura 
     T0CON = 0x87;  // encendido tmr0
     TMR0H = 0x48; //48
     TMR0L = 0xE4; //E4
    // configuracion inicial de TMR1 para servo
     T1CON = 0xB1;  
     TMR1H = 0xF1; 
     TMR1L = 0x58;
     LATBbits.LATB1 = 1;
     INTCONbits.GIEH = 1;    // ACTIVA INTERRUP DE HIG PRIORITY
     INTCONbits.GIEL = 1 ;  //ACTIVA INTERRUP DE LOW PRIORITY
    
    __delay_ms(1000);
    while (1){
        
        if (opc == 3){
            aux = 1;
            __delay_ms(500);
            aux = 0;
            __delay_ms(500);
        
        }
       
    }
    
    
    
    
}

void __interrupt(high_priority) TEMP(void){
    
    
    if (INTCONbits.TMR0IF == 1 & PIR1bits.TMR1IF == 0){
    status = 0;
    chekin = 0;
    
    DHT11_init();
    status = DHT11_CheckResponse();
    
        if (status == 1){
            
            chekin = DHT11_ReadData(&hum,&dhum,&temp,&dtemp);
                         
        }
    
        if (opc == 1){
    
            converter_temptoservo (temp,dtemp,8);  
            
            aux_temp = 1;
    
            }
        
        else if (opc == 2){
        converter_humtoservo (hum, 8);
        
        aux_hum = 1;
        
        
        }
      
        
        INTCONbits.TMR0IF = 0;  
    }
    else {
    
        if (opc == 1 & aux_temp == 1){
            
            if (PORTBbits.RB1 == 1) {
                LATBbits.LATB1 = 0;
                
                TMR1H = OFF_mas;
                TMR1L = OFF_menos;
            
            
            
            }
            else {
                LATBbits.LATB1 = 1;
                
                TMR1H = ON_mas;
                TMR1L = ON_menos;
            
            
            }
            
        
        }
        
        else if (opc == 2 & aux_hum ==1){
            
            if (PORTBbits.RB1 == 1) {
                LATBbits.LATB1 = 0;
                
                TMR1H = OFFh_mas;
                TMR1L = OFFh_menos;
            
            
            
            }
            else {
                LATBbits.LATB1 = 1;
                
                TMR1H = ONh_mas;
                TMR1L = ONh_menos;
            
            
            }
            
        
        
        }
        
        else if (opc == 3){
            if (aux == 1){
            
            if (PORTBbits.RB1 == 1) {
                LATBbits.LATB1 = 0;
                TMR1H = 0x99;
                TMR1L = 0x75;
            
            
            
            }
            else {
                LATBbits.LATB1 = 1;
                TMR1H = 0xFD;
                TMR1L = 0x11;
            
            
            }
                
                
            }
            else {
                
            if (PORTBbits.RB1 == 1) {
                LATBbits.LATB1 = 0;
                
                TMR1H = 0x99;
                TMR1L = 0x74;
            
            
            
            }
            else {
                LATBbits.LATB1 = 1;
                
                TMR1H = 0xF1;
                TMR1L = 0x58;
            
            
            }
            
            
            
            
            
            }
        
        
        }
        
        else {
           if (PORTBbits.RB1 == 1) {
                LATBbits.LATB1 = 0;
                
                TMR1H = 0x99;
                TMR1L = 0x74;
            
            
            
            }
            else {
                LATBbits.LATB1 = 1;
                
                TMR1H = 0xF1;
                TMR1L = 0x58;
            
            
            }
        
        }
    
      
    
    
    PIR1bits.TMR1IF = 0;
    }
        
    
        
        
}

void __interrupt(low_priority)  USART_SERVO(void){
    
    if (PIR1bits.RCIF == 1){
        opc = 0;
        
        if (RCREG ==0x0D){

                TX_MENSAJE_EUSART("\fMicrocontroladores",19);
                TX_MENSAJE_EUSART("\n\rBienvenidos al LB4",20);
                TX_MENSAJE_EUSART("\n\rLa final de finales",21);
                TX_MENSAJE_EUSART("\n\rOpciones del menu:",20);
                TX_MENSAJE_EUSART("\n\r(A) - Visualizar en consola la temperatura",45);
                TX_MENSAJE_EUSART("\n\r(B) - Visualizar en consola la humedad",40);
                TX_MENSAJE_EUSART("\n\r(C) - Visualizar en servo la temperatura",42);
                TX_MENSAJE_EUSART("\n\r(D) - Visualizar en servo la humedad",38);
                TX_MENSAJE_EUSART("\n\r(E) - (Opcional) Mover el servo como limpiabrisas de auto",59);
                

                enter = 1;
        }
        
        if (enter == 1 ) {          
            
            
            if (RCREG == 'A'){

                if (status == 1 & chekin == 1 ) {
                    TX_MENSAJE_EUSART("\n\rTEMPERATURA: ",15);
                    DIGITOS(temp);
                    TX_CHAR_EUSART(digdec+0x30);
                    TX_CHAR_EUSART(diguni+0x30);
                    TX_CHAR_EUSART(0x2E);
                    DIGITOS(dtemp);
                    TX_CHAR_EUSART(diguni+0x30);
                    TX_CHAR_EUSART(0xDF);
                    TX_CHAR_EUSART(0x43);
                    
                    
                    
                }
                else if (status == 0 & chekin == 0){
                
                    TX_MENSAJE_EUSART("\n\rERROR DE CONEXION",19);
                
                }
                else if (status == 1 & chekin == 0){
                
                    TX_MENSAJE_EUSART("\n\rERROR DE CHECKSUM",19);
                
                
                }
                

            }
            else if (RCREG == 'B'){


                    if (status == 1 & chekin == 1 ) {
                    TX_MENSAJE_EUSART("\n\rHUMEDAD: ",11);
                    DIGITOS(hum);
                    TX_CHAR_EUSART(digdec+0x30);
                    TX_CHAR_EUSART(diguni+0x30);
                    TX_CHAR_EUSART(0x2E);
                    DIGITOS(dhum);
                    TX_CHAR_EUSART(diguni+0x30);
                    TX_CHAR_EUSART(0x25);
                    
                    
                    
                    
                }
                else if (status == 0 & chekin == 0){
                
                    TX_MENSAJE_EUSART("\n\rERROR DE CONEXION",19);
                
                }
                else if (status == 1 & chekin == 0){
                
                    TX_MENSAJE_EUSART("\n\rERROR DE CHECKSUM",19);
                
                
                }
                


            }
            else if (RCREG == 'C'){
                  if (status == 1 & chekin == 1 ) {
                      opc = 1;
                    
                    
                    
                }
                else if (status == 0 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CONEXION",19);
                
                }
                else if (status == 1 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CHECKSUM",19);
                
                
                }

                
            }
            else if (RCREG == 'D'){
                
                  if (status == 1 & chekin == 1 ) {
                      opc = 2;
                    
                    
                    
                }
                else if (status == 0 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CONEXION",19);
                
                }
                else if (status == 1 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CHECKSUM",19);
                
                
                }

                
            }
            else if (RCREG == 'E'){
                
                  if (status == 1 & chekin == 1 ) {
                      opc = 3;
                    
                    
                    
                }
                else if (status == 0 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CONEXION",19);
                
                }
                else if (status == 1 & chekin == 0){
                    opc = 0;
                    TX_MENSAJE_EUSART("\n\rERROR DE CHECKSUM",19);
                
                
                }
                
            }
        }
        PIR1bits.RCIF = 0 ;
    }
      
    
    
    
    

}