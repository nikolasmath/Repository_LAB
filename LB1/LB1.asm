#include "p18F4550.inc"
 CONFIG FOSC = XT_XT
 CONFIG PWRT = ON
 CONFIG BOR = ON
 CONFIG BORV = 3
 CONFIG WDT = OFF
 CONFIG PBADEN = OFF
 CONFIG MCLRE = ON
  CBLOCK 0X0020
  var1
  var2
  var10
  var20
  MENSAJE			    
  CONFI ;VALOR INICIOAL AL INICIAR EL MENSAJE
  CONFI1
  CONFI2
  CONFI3
  DIS1
  DIS2	
  DIS3
  DIS4
  ENDC
 ORG 0x700
TABLA: db 0x00, 0x00, 0x37, 0x06, 0x39, 0x50, 0x3F, 0x39, 0x3F, 0x54, 0x78, 0x50, 0x3F, 0x38, 0x77, 0x5E, 0x3F, 0x50, 0x79, 0x6D, 0x00, 0x1C, 0x73, 0x39
 ORG 0x800
TABLA1: db 0x39, 0x06, 0x39, 0x38, 0x3F, 0x00, 0x5B, 0x3F, 0x06, 0x67 ,0x00 
 ORG 0x900
TABLA2: db 0x38,0x77,0x00,0x1C,0x06,0x5E,0x77,0x00,0x79,0x6D,0x00,0x3E,0x54,0x77,0x00,0x79,0x6D,0x73,0x79,0x39,0x06,0x79,0x00,0x5E,0x79,0x00 
 ORG 0x1000
TABLA3: db 0x7C,0x06,0x39,0x06,0x39,0x38,0x79,0x78,0x77,0x09,0x00,0x6D,0x06,0x00,0x67,0x3E,0x06,0x79,0x50,0x79,0x6D,0x00,0x37,0x77,0x54,0x78,0x79,0x54,0x79,0x50,0x78,0x79,0x00 
 ORG 0x1100
TABLA4: db 0x78,0x79,0x00,0x79,0x54,0x00,0x79,0x67,0x3E,0x06,0x38,0x06,0x7C,0x50,0x06,0x5C,0x00,0x5E,0x79,0x7C,0x79,0x6D,0x00,0x73,0x79,0x5E,0x77,0x38,0x79,0x77,0x50,0x00
 ORG 0x1200
TABLA5: db 0x74,0x77,0x39,0x06,0x77,0x00,0x77,0x5E,0x79,0x38,0x77,0x54,0x78,0x79,0x00
 ORG 0x1300
TABLA6: db 0x38,0x5C,0x00,0x67,0x3E,0x79,0x00,0x54,0x5C,0x00,0x37,0x79,0x00,0x37,0x77,0x78,0x77,0x04,0x00,0x37,0x79,0x00,0x77,0x38,0x06,0x37,0x79,0x54,0x78 
 ORG 0x1400
TABLA7: db 0x79,0x54,0x78,0x77,0x00
 org 0x00
 goto MAIN
 org 0x08
 goto RUT_ALTAP
 org 0x018
 goto RUT_INT_BAJA_PRIOR
 org 0x020
MAIN:
    CLRF TRISD
    CLRF LATB
    movlw 0xF0
    movwf TRISB
    bsf RCON,IPEN; Modo de dos prioridades
    bsf INTCON2,RBPU ;desabukito resistencias internas 
    bsf INTCON,RBIE ;habilita la inturrupcon de cambio  de puerto RB
    bsf INTCON,GIE ;habilitas las interreupcions desenmascaradas
    bsf INTCON,PEIE ;Habilita todas las interrupciones periféricas desenmascaradas
    bcf INTCON2,TMR0IP;Baja prioridad TMR0
    bsf INTCON,TMR0IE;Activa la interrp. TMR0
    bsf INTCON,INT0IF ;Ocurrió la interrupción externa INT0 (debe borrarse en el software)
    movlw 0x83   ;ACTIAVS EL DE 16 BITS, y el preescamle pos vos decide we solo cambie el 3 por un numero menor mas rapido o un nmero mayor mas velocidad .... no pos gg 
    movwf T0CON  ;pongo la confifuracion al tocon
    movlw .1 ;incia cuenta en 1
    movwf TMR0H   ;timer0
    BCF TRISA,0 ;SALIDA
    BCF TRISE,0  ;SALIDA
    BCF TRISE,1 ;SALIDA
    BCF TRISE,2 ;SALIDA
    CLRF DIS1   ;pongo en cero las variables
    CLRF DIS2
    CLRF DIS3
    CLRF DIS4
    CLRF MENSAJE
    CLRF CONFI
    CLRF CONFI1
    CLRF CONFI2
    CLRF CONFI3 ;hasta aca

INICIO: ;inicio la pregnta de  cual mensaje elegir
    CLRF CONFI3	
    CLRF CONFI2
    CLRF CONFI1
    CLRF CONFI
    CALL VISUAL
    MOVLW .0
    CPFSEQ MENSAJE
    GOTO GUGU
    GOTO MENSAJE0
GUGU:    
    MOVLW .1
    CPFSEQ MENSAJE
    GOTO GIGI
    GOTO MENSAJE1
GIGI:
    MOVLW .2
    CPFSEQ MENSAJE
    GOTO GEGE
    GOTO MENSAJE2
GEGE:
    MOVLW .3
    CPFSEQ MENSAJE
    GOTO GAGA
    GOTO MENSAJE3
GAGA:
    MOVLW .4
    CPFSEQ MENSAJE
    GOTO INICIO
    GOTO MENSAJE4     ;hasta aca (cabe mencionar que los valores que tendra MENSAJE lo optine del teclado en la iterrupcion alta , de ahi viene aca a comparar)
MENSAJE0:
    movlw HIGH TABLA   ;aca pos no muestra nada
    movwf TBLPTRH
    movlw LOW TABLA
    movwf TBLPTRL
    CLRF DIS1
    CLRF DIS2
    CLRF DIS3
    CLRF DIS4
    GOTO INICIO     ;no apreta el teclado todavia
MENSAJE1:
    MOVLW .0         ;aca si xd 
    CPFSEQ CONFI      ;variable para que solo pase una ves cuando la cuenta se inicia 
    GOTO SEGUIR
    movlw HIGH TABLA    ;elijo la tabla 1
    movwf TBLPTRH
    movlw LOW TABLA
    movwf TBLPTRL
    MOVLW .1
    MOVWF CONFI
    MOVLW .2
    MOVWF DIS1
    MOVLW .3
    MOVWF DIS2
    MOVLW .4
    MOVWF DIS3
    MOVLW .5
    MOVWF DIS4
SEGUIR:
    CALL VISUAL
    MOVLW .23       ;veo si llego asu climax we (ultimo valor de la tabla )
    CPFSEQ DIS4      
    GOTO MENSAJE1
    MOVLW .2       ;si llego pos todo regresa a asu valor inicial
    MOVWF DIS1
    MOVLW .3
    MOVWF DIS2
    MOVLW .4
    MOVWF DIS3
    MOVLW .5
    MOVWF DIS4
    GOTO INICIO       ;aca finaliza el mensaje1 lo demas es lo mismo menos de la 3 y 4 que :,v no da we
MENSAJE2:
    CALL VISUAL
    MOVLW .0
    CPFSEQ CONFI
    GOTO SEGUIR2
    movlw HIGH TABLA1
    movwf TBLPTRH
    movlw LOW TABLA1
    movwf TBLPTRL
    MOVLW .1
    MOVWF CONFI
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4
SEGUIR2:
    CALL VISUAL
    MOVLW .10
    CPFSEQ DIS4
    GOTO MENSAJE2
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4    
    GOTO INICIO
MENSAJE3:
    MOVLW .0
    CPFSEQ CONFI
    GOTO SEGUIR3
    MOVLW HIGH TABLA2
    MOVWF TBLPTRH
    MOVLW LOW TABLA2
    MOVWF TBLPTRL
    MOVLW .1
    MOVWF CONFI
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4 
SEGUIR3:
    CALL VISUAL
    MOVLW .25
    CPFSEQ DIS4
    GOTO MENSAJE3
SEGUIR3.0:
    movlw HIGH TABLA3
    movwf TBLPTRH
    movlw LOW TABLA3
    movwf TBLPTRL
    MOVLW .0
    CPFSEQ CONFI1
    GOTO SEGUIR3.1
    MOVLW .1
    MOVWF CONFI1
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4  
SEGUIR3.1:
    CALL VISUAL
    MOVLW .32
    CPFSEQ DIS4
    GOTO SEGUIR3.0
SEGUIR3.2: 
    movlw HIGH TABLA4
    movwf TBLPTRH
    movlw LOW TABLA4
    movwf TBLPTRL
    MOVLW .0
    CPFSEQ CONFI2
    GOTO SEGUIR3.3
    MOVLW .1
    MOVWF CONFI2
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4
SEGUIR3.3:
    CALL VISUAL
    MOVLW .31
    CPFSEQ DIS4
    GOTO SEGUIR3.2
SEGUIR3.4:
    movlw HIGH TABLA5
    movwf TBLPTRH
    movlw LOW TABLA5
    movwf TBLPTRL
    MOVLW .0
    CPFSEQ CONFI3
    GOTO SEGUIR3.5
    MOVLW .1
    MOVWF CONFI3
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4
SEGUIR3.5:
    CALL VISUAL
    MOVLW .14
    CPFSEQ DIS4
    GOTO SEGUIR3.4
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4
    GOTO INICIO
MENSAJE4:
    MOVLW .0
    CPFSEQ CONFI
    GOTO SEGUIR4
    movlw HIGH TABLA6
    movwf TBLPTRH
    movlw LOW TABLA6
    movwf TBLPTRL
    MOVLW .1
    MOVWF CONFI
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4 
SEGUIR4:
    CALL VISUAL
    MOVLW .28
    CPFSEQ DIS4
    GOTO MENSAJE4
SIGUE4.0:    
    movlw HIGH TABLA7
    movwf TBLPTRH
    movlw LOW TABLA7
    movwf TBLPTRL
    MOVLW .0
    CPFSEQ CONFI1
    GOTO SEGUIR4.1
    MOVLW .1
    MOVWF CONFI1
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4  
SEGUIR4.1:
    CALL VISUAL
    MOVLW .4
    CPFSEQ DIS4
    GOTO SIGUE4.0
    MOVLW .0
    MOVWF DIS1
    MOVLW .1
    MOVWF DIS2
    MOVLW .2
    MOVWF DIS3
    MOVLW .3
    MOVWF DIS4
    GOTO INICIO ;CREO QUE TERNINE
VISUAL:
    CALL VISU1    ;metodo para displayar
    CALL DISPLAY1
    CALL ESPERA
    CALL VISU2
    CALL DISPLAY2
    CALL ESPERA
    CALL VISU3
    CALL DISPLAY3
    CALL ESPERA
    CALL VISU4
    CALL DISPLAY4
    CALL ESPERA    ;hasta aca
    RETURN     
    
DISPLAY1:           ;esto es parte del codigo de multiplexacion 
    clrf TBLPTRL
    movf DIS1, W
    addwf TBLPTRL
    TBLRD*
    movff TABLAT, LATD
    RETURN
DISPLAY2:
    clrf TBLPTRL
    movf DIS2, W
    addwf TBLPTRL
    TBLRD*
    movff TABLAT, LATD
    RETURN
DISPLAY3:
    clrf TBLPTRL
    movf DIS3, W
    addwf TBLPTRL
    TBLRD*
    movff TABLAT, LATD
    RETURN
DISPLAY4:
    clrf TBLPTRL
    movf DIS4, W
    addwf TBLPTRL
    TBLRD*
    movff TABLAT, LATD
    RETURN
VISU1:
    BSF LATA,0
    BSF LATE,0 
    BSF LATE,1 
    BCF LATE,2
    RETURN
VISU2: 
    BSF LATA,0
    BSF LATE,0 
    BCF LATE,1 
    BSF LATE,2
    RETURN
VISU3:
    BSF LATA,0
    BCF LATE,0 
    BSF LATE,1 
    BSF LATE,2
    RETURN
VISU4:  
    BCF LATA,0
    BSF LATE,0 
    BSF LATE,1 
    BSF LATE,2
    RETURN   ;hasta aca 

RUT_ALTAP:
    
    bcf INTCON,RBIF    ;bajo la bandera
    btfss PORTB,4   ;metodo para lee el teclado 
    goto COL1
    btfss PORTB,5
    goto COL2
    btfss PORTB,6
    goto COL3
    btfss PORTB,7
    goto COL4
    retfie
COL1:
    CLRF LATB
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,4
    GOTO SIETE
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,4
    GOTO CUATRO
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    btfss PORTB,4
    GOTO UNO
    BSF LATB,0
    BSF LATB,1
    BSF LATB,2
    BCF LATB,3
    btfss PORTB,4
    GOTO ONOFF
    goto COL1 
COL2:
    CLRF LATB
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,5
    GOTO OCHO
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,5
    GOTO CINCO
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    btfss PORTB,5
    GOTO DOS
    BSF LATB,0
    BSF LATB,1
    BSF LATB,2
    BCF LATB,3
    btfss PORTB,5
    GOTO CERO
    goto COL2 
COL3:
    CLRF LATB
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,6
    GOTO NUEVE
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,6
    GOTO SEIS
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    btfss PORTB,6
    GOTO TRES
    BSF LATB,0
    BSF LATB,1
    BSF LATB,2
    BCF LATB,3
    btfss PORTB,6
    GOTO IGUAL
    goto COL3 
COL4:
    CLRF LATB
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,7
    GOTO DIVISION
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    btfss PORTB,7
    GOTO MULTIPLICACION
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    btfss PORTB,7
    GOTO RESTA
    BSF LATB,0
    BSF LATB,1
    BSF LATB,2
    BCF LATB,3
    btfss PORTB,7
    GOTO SUMA
    goto COL4 
SIETE:
    movlw .7
    GOTO SALIR
CUATRO:
    CLRF CONFI
    MOVLW .4
    MOVWF MENSAJE
    GOTO SALIR 
UNO:
    CLRF MENSAJE
    CLRF CONFI3	
    CLRF CONFI2
    CLRF CONFI1
    CLRF CONFI
    MOVLW .1
    MOVWF MENSAJE
    GOTO SALIR
DOS:
    CLRF MENSAJE
    CLRF CONFI
    MOVLW .2
    MOVWF MENSAJE
    GOTO SALIR
TRES:
    CLRF CONFI
    MOVLW .3
    MOVWF MENSAJE
    GOTO SALIR
CINCO:
    movlw .5
    GOTO SALIR 
SEIS:
    MOVLW .6
    GOTO SALIR
OCHO:
    MOVLW .8
    GOTO SALIR
NUEVE:
    MOVLW .9
    GOTO SALIR 
CERO:
    MOVLW .0
    GOTO SALIR
MULTIPLICACION:
    MOVLW .11
    GOTO SALIR
RESTA:
    MOVLW .12
    GOTO SALIR
SUMA:
    MOVLW .11
    GOTO SALIR 
DIVISION:
    MOVLW .12
    GOTO SALIR   
IGUAL:
    MOVLW .12
    GOTO SALIR     
ONOFF:
    movlw .10
    GOTO SALIR  
SALIR:
    CLRF LATB
    call RETARDO
    movlw 0xF0
    movwf TRISB
    bcf INTCON,RBIF
    retfie    ;ahsta aca 
RUT_INT_BAJA_PRIOR:
    movlw .1        ;wea del timer 0
    movwf TMR0H   ;16BITS YA NO USAR EL TMR0L CREO (PREGUNTAR)
    bcf  INTCON,TMR0IF
    incf DIS1, f
    incf DIS2, f
    incf DIS3, f
    incf DIS4, f
    retfie           ;hasta aca we 
RETARDO:
    movlw .100
    movwf var1
RET1:
    movlw .200
    movwf var2
RET2:
    decfsz var2,f
    goto RET2
    decfsz var1,f
    goto RET1
    return
ESPERA:
    movlw .20
    movwf var10
RET3:
    movlw .200
    movwf var20
RET4:
    decfsz var20,f
    goto RET4
    decfsz var10,f
    goto RET3
    return   
 END