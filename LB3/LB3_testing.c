/*
 * File:   LB3_testing.c
 * Author: CORP NIKOLAS
 *
 * Created on June 2, 2019, 10:30 PM
 */

#pragma config PLLDIV = 1       // PLL Prescaler Selection bits (No prescale (4 MHz oscillator input drives PLL directly))
#pragma config CPUDIV = OSC1_PLL2// System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
#pragma config FOSC = XTPLL_XT  // Oscillator Selection bits (XT oscillator, PLL enabled (XTPLL))
#pragma config PWRT = ON        // Power-up Timer Enable bit (PWRT enabled)
#pragma config BOR = OFF        // Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
#pragma config BORV = 3         // Brown-out Reset Voltage bits (Minimum setting 2.05V)
#pragma config WDT = OFF        // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
#pragma config WDTPS = 32768    // Watchdog Timer Postscale Select bits (1:32768)
#pragma config CCP2MX = ON      // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
#pragma config PBADEN = OFF     // PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
#pragma config MCLRE = ON       // MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
#pragma config LVP = OFF        // Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)

#include <xc.h>
#include "LCD.h"
#define _XTAL_FREQ 48000000UL

int digdmi = 0;
int digmil = 0;
int digcen = 0;
int digdec = 0;
int diguni = 0;
int temporal = 0;
int temporal2 = 0;
int temporal3 = 0;
int aux = 0;
int i_cont = 0;
int id = 0;
int veces = 0;

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
//Hora preconfigurada 00:00:00
int minu = 0;
int segu = 0;
int dseg = 0;




void main(void){
    //Configuracion del LCD
    __delay_ms(500);
    TRISD = 0x00;       //Puerto donde esta conectado el LCD
    LCD_CONFIG();       //Configuracion inicial del LCD
    __delay_ms(15);
    CURSOR_ONOFF(OFF);     //Cursor apagao
    /******/
    TRISBbits.RB0 = 0;
    // configuracion de prioridades
    RCONbits.IPEN = 1;     
    // altas prioridades
    IPR1bits.CCP1IP = 1;
    // baja prioridades
    INTCON3bits.INT1IP = 0;
    INTCON2bits.TMR0IP = 0;
    /******/
    INTCON3bits.INT1E = 1; //Habilitando interruptor de INT1
    PIE1bits.CCP1IE = 1;//Habilitando interruptor de CCP1
    INTCONbits.TMR0IE = 1; // habilitando interrupcion de TMR0
    /*****/
    // configuracion de CCP1 + TMR1
    T1CON = 0x8A;   //Oscilador 32.768KHz con PSC 1:1 0x8A
    CCP1CON = 0x0B; //CCP en comparador evento especial de disparo
    CCPR1H = 0x01;
    CCPR1L = 0x48;  //Valor de comparacion entre CCP1 y Timer1
    // configuracion TMR0
    T0CON = 0x81 ;
    TMR0H = 0xF8 ;
    TMR0L = 0xF7 ;
    LATBbits.LATB0 = 1;
    
    
    INTCONbits.GIEH = 1;    // ACTIVA INTERRUP DE HIG PRIORITY
    INTCONbits.GIEL = 1 ;  //ACTIVA INTERRUP DE LOW PRIORITY
    
    
    
    
    // inicio:
    CURSOR_HOME();
    ESCRIBE_MENSAJE(" CAMPANA: TILIN ",16);
    while(1){
        if (((segu == 15 || segu == 30 || segu == 45) & dseg == 0 ) || id == 1) {
            id = 1;
            if (i_cont == 15){
            
        
              aux=0;
              i_cont = 0;
              id = 0;
              
                
                }
            
            else {
                aux = 1;
                i_cont++;
            }
        }            
        
        
        
        else if ((minu > 0 & segu == 0 & dseg == 0 ) || id == 2 ){
            id = 2;
            if (veces <= 15){
                
                if (i_cont == 15){
                          
                            aux=0;
                            i_cont = 0;
                            
              
                            
                }
            
                else {
                    aux = 1;
                    i_cont++;
                    veces++;
                    
                }
                
            }
            
            else if (veces <=36  & veces > 15) {
            if (i_cont == 20){
                          
                            aux=1;
                            i_cont = 0;
                            
              
                            
                }
            
                else {
                    aux = 0;
                    i_cont++;
                    veces++;
                }
            
            
            }
            
            else if (veces > 36 ){
            if (i_cont == 15){
                          
                            aux=0;
                            i_cont = 0;
                            id = 0;
                            veces = 0;
                            
                }
            
                else {
                    aux = 1;
                    veces++;
                    i_cont++;
                }
            
            
                }
                   
            }        
            
        
        POS_CURSOR(2,0);
        ESCRIBE_MENSAJE("Hora:   ",8);
        DIGITOS(minu);
        ENVIA_CHAR(digdec+0x30);    //Impresion de la hora en el LCD
        ENVIA_CHAR(diguni+0x30);
        ENVIA_CHAR(':');
        DIGITOS(segu);        
        ENVIA_CHAR(digdec+0x30);    //Impresion de los minutos en el LCD
        ENVIA_CHAR(diguni+0x30);
        ENVIA_CHAR(':');        
        DIGITOS(dseg);        
        ENVIA_CHAR(digdec+0x30);    //Impresion de los segundos en el LCD
        ENVIA_CHAR(diguni+0x30);
        
        
               
        
        
        
    }
    
}

void __interrupt(high_priority) CCP1ISR(void){
    if(dseg == 99){
        dseg = 0;
        if(segu == 59){
            segu = 0;
            if(minu == 59){
                minu = 0;
            }
            else{
                minu++;
            }
        }
        else{
            segu++;
        }
    }
    else{
        dseg++;
    }
     PIR1bits.CCP1IF = 0;    //Bajamos la bandera de interrupcion del CCP1
    
}

void __interrupt(low_priority) button(void){
    if (INTCON3bits.INT1F){
                    
            if (T1CONbits.TMR1ON){
                T1CONbits.TMR1ON = 0;        
                                 }
            else {
                T1CONbits.TMR1ON = 1;
                 }
        
            INTCON3bits.INT1F = 0;
            aux = 0;
            i_cont = 0;
    }
    
            else {
                
                if (aux == 0) {
                if (PORTBbits.RB0 == 1){
                LATBbits.LATB0 = 0;

                TMR0H = 0x1C ;
                TMR0L = 0xA7 ; 

                }
                else {
                LATBbits.LATB0 = 1;

                TMR0H = 0xF8 ;
                TMR0L = 0xF7 ; 
                }

                }

                else {
                    
                    if (PORTBbits.RB0 == 1){
                    LATBbits.LATB0 = 0;

                    TMR0H = 0x27 ;
                    TMR0L = 0x34 ; 


                    }
                    else {
                    LATBbits.LATB0 = 1;

                    TMR0H = 0xEE ;
                    TMR0L = 0x6B ;

                    }
                    }
                }
                
                INTCONbits.TMR0IF = 0;

        
    }