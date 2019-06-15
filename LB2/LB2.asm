list p=18f4550
    #include <p18f4550.inc>

    CONFIG  FOSC = XT_XT          ; Oscillator Selection bits (XT oscillator (XT))
    CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
    CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
    CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
    CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
    CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
    
    cblock 0x0020
    T1
    var1
    var2
    MENSAJ01
    MENSAJ02
    MENSAJ03
    TECLA1
    TECLA2
    TECLA3
    TECLA1.1
    TECLA2.1
    TECLA3.1
    aux
    cont
    conta1
    conta2
    BCD0
    BCD1
    BCD2
    PASE_MENU1
    PASE_MENU2
    PASE_MENU3
    valor
    SUMA
    LED       
    BUZZER
    CLIMA
    endc
    
    org 0x1000
opcion1  db  0x74,0x65,0x6D,0x70,0x65 ,0x72 ,0x61 ,0x74 ,0x75 ,0x72 ,0x61 ,0x3A ,0x00
    org 0x1100
opcion2   db 0x4C,0x49 ,0x4D ,0x49 ,0x54 ,0x45,0x00,0x53,0x55,0x50,0x45,0x52,0x49,0x4F,0x52, 0x3A,0x31,0x30,0x30,0xDF,0x43 
    org 0x1200
opcion3  db  0x4C,0x49 ,0x4D ,0x49 ,0x54 ,0x45,0x00,0x49,0x4E,0x46,0x45,0x52,0x49,0x4F,0x52, 0x3A ,0x30,0xDF,0x43   
    
    org 0x000
    GOTO CONFIGURACION
    org 0x020
    
CONFIGURACION:
    CLRF TRISD		;puerto D como salida
    MOVLW 0xF0
    MOVWF TRISB
    BCF TRISC,0  ;RS
    BCF TRISC,1  ;ENABLE
    BCF TRISE,0  ;BUZZER
    BCF TRISE,1  ;LED
    ;#####CONFIGURACION DE LOS PUERTOS A/D
    BSF TRISA,0
    BSF TRISA,1
    BSF TRISA,2
    MOVLW 0x24
    MOVWF ADCON2    ;izquierda, 8TAD , FOSC/4
    MOVLW 0x1B
    MOVWF ADCON1    ;puerto SOLO AN0 HABILOTADO Y VREF+
    ;####
    CLRF MENSAJ01
    CLRF MENSAJ02
    CLRF MENSAJ03
    CLRF TECLA1
    CLRF TECLA2
    CLRF TECLA3
    CALL INICIO_DE_LCD
    ;######
    MOVLW B'00110000'
    MOVWF SUMA
MENU1:
    bsf ADCON1, VCFG0
    MOVLW 0x01
    MOVWF ADCON0    ;INICIAMOS EL ADC con AN0 HABIKITADO
    CALL BORRAR
    CALL MENSAJE1
    CLRF TECLA1
SUBMENU1:  
    bsf ADCON0, 1 ;SE INICIA LA CONVERSION
FALTA1:
    btfsc ADCON0, 1 
    GOTO FALTA1
    CALL SALTO
    CALL DELAY15MSEG
    movff ADRESH, valor
    rrcf valor, f
    bcf valor, 7
    movff valor,CLIMA
    movff valor,aux
    CALL CONVERTIDOR_BCD
    ;CENTENA
    MOVF SUMA ,W
    ADDWF BCD2,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;DECENA
    MOVF SUMA ,W
    ADDWF BCD1,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;UNIDAD
    MOVF SUMA ,W
    ADDWF BCD0,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;EL PUTNO XD
    MOVLW 0xDF
    MOVWF LATD
    CALL ENABLE
    ;LA LETRA C
    MOVLW 0x43
    MOVWF LATD
    CALL ENABLE
    ;HH
    GOTO HACE_CALOR
    GOTO INICIO
MENU2:
    bcf ADCON1, VCFG0
    MOVLW 0x05
    MOVWF ADCON0    ;INICIAMOS EL ADC con AN1 HABIKITADO
    CALL BORRAR
    CALL MENSAJE2 
    CLRF TECLA2
SUBMENU2:   
    bsf ADCON0, 1 ;SE INICIA LA CONVERSION
FALTA2:
    btfsc ADCON0, 1 
    GOTO FALTA2
    CALL SALTO
    CALL DELAY15MSEG
    movff ADRESH, valor
    rrcf valor, f
    bcf valor, 7
    movff valor,BUZZER
    movff valor,aux
    CALL CONVERTIDOR_BCD
    ;CENTENA
    MOVF SUMA ,W
    ADDWF BCD2,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;DECENA
    MOVF SUMA ,W
    ADDWF BCD1,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;UNIDAD
    MOVF SUMA ,W
    ADDWF BCD0,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;EL PUTNO XD
    MOVLW 0xDF
    MOVWF LATD
    CALL ENABLE
    ;LA LETRA C
    MOVLW 0x43
    MOVWF LATD
    CALL ENABLE
    ;HH
    GOTO INICIO
MENU3:  
    bcf ADCON1, VCFG0
    MOVLW 0x09
    MOVWF ADCON0    ;INICIAMOS EL ADC con AN2 HABIKITADO
    CALL BORRAR
    CALL MENSAJE3 
    CLRF TECLA3
SUBMENU3:
    bsf ADCON0, 1 ;SE INICIA LA CONVERSION
FALTA3:    
    btfsc ADCON0, 1 
    GOTO FALTA3
    CALL SALTO
    CALL DELAY15MSEG
    movff ADRESH, valor
    rrcf valor, f
    bcf valor, 7
    movff valor,LED
    movff valor,aux
    CALL CONVERTIDOR_BCD
    ;CENTENA
    MOVF SUMA ,W
    ADDWF BCD2,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;DECENA
    MOVF SUMA ,W
    ADDWF BCD1,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;UNIDAD
    MOVF SUMA ,W
    ADDWF BCD0,0
    MOVWF LATD
    CALL ENABLE
    CALL DELAY15MSEG
    ;EL PUTNO XD
    MOVLW 0xDF
    MOVWF LATD
    CALL ENABLE
    ;LA LETRA C
    MOVLW 0x43
    MOVWF LATD
    CALL ENABLE
    ;HH
    GOTO INICIO
;#############
;LED Y BUZZER INTENTO
HACE_CALOR:
    MOVF CLIMA,W
    SUBWF BUZZER,W
    BTFSS STATUS,C
    GOTO BUZZER_PRENDIDO
    GOTO BUZZER_APAGADO
BUZZER_PRENDIDO:
    BSF LATE,0
    GOTO HACE_FRIO
BUZZER_APAGADO: 
    BCF LATE,0
    GOTO HACE_FRIO
HACE_FRIO:
    MOVF CLIMA,W
    SUBWF LED,w
    BTFSC STATUS,C
    GOTO LED_PRENDIDO
    GOTO LED_APAGADO
LED_PRENDIDO:
    BSF LATE,1
    GOTO INICIO
LED_APAGADO:
    BCF LATE,1
    GOTO INICIO    
    
;#################################################33
;ACA ESTA LOS MENSAJES    
MENSAJE1:
    BSF PORTC,0
    BCF PORTC,1
    CALL RETARDO
    MOVLW HIGH opcion1  
    MOVWF TBLPTRH
    MOVLW LOW opcion1
    MOVWF TBLPTRL
SUBMENSAJE1:    
    CALL VISUAL1
    CALL ENABLE
    INCF MENSAJ01, f
    MOVLW .12       
    CPFSEQ MENSAJ01
    GOTO SUBMENSAJE1
    CLRF MENSAJ01
    RETURN
MENSAJE2:
    BSF PORTC,0
    BCF PORTC,1
    CALL RETARDO
    MOVLW HIGH opcion2  
    MOVWF TBLPTRH
    MOVLW LOW opcion2
    MOVWF TBLPTRL
SUBMENSAJE2:    
    CALL VISUAL2
    CALL ENABLE
    INCF MENSAJ02, f
    MOVLW .16       
    CPFSEQ MENSAJ02
    GOTO SUBMENSAJE2
    CLRF MENSAJ02
    RETURN
MENSAJE3:
    BSF PORTC,0
    BCF PORTC,1
    CALL RETARDO
    MOVLW HIGH opcion3  
    MOVWF TBLPTRH
    MOVLW LOW opcion3
    MOVWF TBLPTRL
SUBMENSAJE3:    
    CALL VISUAL3
    CALL ENABLE
    INCF MENSAJ03, f
    MOVLW .16       
    CPFSEQ MENSAJ03
    GOTO SUBMENSAJE3 
    CLRF MENSAJ03
    RETURN     
    
;##################################   
;TECLADO
INICIO:
    MOVLW .0
    CPFSEQ TECLA1
    GOTO MENU1
    MOVLW .0
    CPFSEQ TECLA2
    GOTO MENU2
    MOVLW .0
    CPFSEQ TECLA3
    GOTO MENU3
    GOTO VAMO_AVER
VAMO_AVER:
    BCF LATB,0
    BCF LATB,1
    BCF LATB,2
    BCF LATB,3
    ;#######PREGUHTAMOS LAS ENTRADAS
    BTFSS PORTB,4
    GOTO FILA1
    BTFSS PORTB,5
    GOTO FILA2
    BTFSS PORTB,6
    GOTO FILA3
    BTFSS PORTB,7
    GOTO FILA4
VEAMOS_EL_CAMBIO:
    MOVLW .0
    CPFSEQ TECLA1.1
    GOTO SUBMENU1
    MOVLW .0
    CPFSEQ TECLA2.1
    GOTO SUBMENU2
    MOVLW .0
    CPFSEQ TECLA3.1
    GOTO SUBMENU3
    GOTO INICIO
FILA1:
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,4
    GOTO NUM1
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,4
    GOTO NUM4
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    BTFSS PORTB,4
    GOTO NUM7
    GOTO ONOFF
FILA2:
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,5
    GOTO NUM2
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,5
    GOTO NUM5
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    BTFSS PORTB,5
    GOTO NUM8
    GOTO NUM0
FILA3:
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,6
    GOTO NUM3
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,6
    GOTO NUM6
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    BTFSS PORTB,6
    GOTO NUM9
    GOTO IGUAL 
FILA4:
    BCF LATB,0
    BSF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,7
    GOTO DIVISION
    BSF LATB,0
    BCF LATB,1
    BSF LATB,2
    BSF LATB,3
    BTFSS PORTB,7
    GOTO MULTIPLICACION
    BSF LATB,0
    BSF LATB,1
    BCF LATB,2
    BSF LATB,3
    BTFSS PORTB,7
    GOTO RESTA
    GOTO SUMAX
NUM1:
    CLRF TECLA2.1
    CLRF TECLA3.1
    MOVLW .1
    MOVWF TECLA1
    MOVLW .1
    MOVWF TECLA1.1
    CALL RETARDO1
    GOTO INICIO
NUM2:
    CLRF TECLA1.1
    CLRF TECLA3.1
    MOVLW .1
    MOVWF TECLA2
    MOVLW .1
    MOVWF TECLA2.1
    CALL RETARDO1
    GOTO INICIO
NUM3:
    CLRF TECLA1.1
    CLRF TECLA2.1
    MOVLW .1
    MOVWF TECLA3
    MOVLW .1
    MOVWF TECLA3.1
    CALL RETARDO1
    GOTO INICIO
NUM4:
    GOTO INICIO
NUM5:
    GOTO INICIO
NUM6:
    GOTO INICIO
NUM7:
    GOTO INICIO
NUM8:
    GOTO INICIO
NUM9:
    GOTO INICIO
NUM0:
    GOTO INICIO
ONOFF:
    GOTO INICIO
IGUAL:
    GOTO INICIO
SUMAX:
    GOTO INICIO
RESTA:
    GOTO INICIO
MULTIPLICACION:
    GOTO INICIO
DIVISION:
    GOTO INICIO
    
    
    
    
    
;###############################33
;APRTIR DE ACA ES LA WEA DEL LCD    
INICIO_DE_LCD:    
    BCF PORTC,0
    BCF PORTC,1
    CALL RETARDO
    MOVLW B'00111000'
    MOVWF PORTD
    CALL ENABLE
    MOVLW B'00001100'
    MOVWF PORTD
    CALL ENABLE
    MOVLW B'00000011'
    MOVWF PORTD
    CALL ENABLE
    MOVLW 0X01
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    RETURN 
BORRAR:
    BCF PORTC,0
    MOVLW 0x01
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    BCF PORTC,1
    RETURN 
SALTO:
    BCF PORTC,0
    MOVLW 0xC0
    MOVWF PORTD
    CALL ENABLE
    BSF PORTC,0
    BCF PORTC,1
    RETURN      
VISUAL1:  
    CLRF TBLPTRL
    MOVF MENSAJ01, W
    ADDWF TBLPTRL
    TBLRD*
    MOVFF TABLAT, LATD
    RETURN
VISUAL2:  
    CLRF TBLPTRL
    MOVF MENSAJ02, W
    ADDWF TBLPTRL
    TBLRD*
    MOVFF TABLAT, LATD
    RETURN
VISUAL3:  
    CLRF TBLPTRL
    MOVF MENSAJ03, W
    ADDWF TBLPTRL
    TBLRD*
    MOVFF TABLAT, LATD
    RETURN     
ENABLE:
    CALL RETARDO
    CALL RETARDO
    BSF PORTC,1
    CALL RETARDO
    CALL RETARDO 
    BCF PORTC,1
    CALL RETARDO
    RETURN
CONVERTIDOR_BCD:  
    ;movwf aux	;Se guarda el valor a convertir en aux
    clrf  cont	;cont=0x00
    clrf  BCD0	;BCD0=0x00	
    clrf  BCD1    ;BCD1=0x00
    clrf  BCD2	;BCD2=0x00
CONV:
    rlcf  aux,f	    ;Rotar a la izquierda cont (cifra original)
    rlcf  BCD0,f	;Rotar a la izquierda BCD0 (carga el carry de cont en el bit LSB)
    rlcf  BCD2,f    ;Rotar a la izquierda BCD2 (carga el carry de BCD0 en el bit LSB)
;Cargar el nibble alto de BCD0 a BCD2 y analizar	
    movf  BCD0,W	;W = BCD0
    movwf BCD1	;BCD1 = BCD0
    swapf BCD1,f	;Inversi?n de nibbles en BCD1
    movlw 0x0F		;W = 0x0F
    andwf BCD1,f	;BCD1 = BCD1 AND 0x0F
    andwf BCD0,f	;BCD0 = BCD0 AND 0x0F
    ;Se pregunta si ya se llegaron a rotar a la izquierda los 8 bits
    movlw .7		;W = .7
    cpfslt cont	;Salta si cont es menor a .7
    return			;Si cont = .7 retorna (FIN de la rutina)
    ;Averiguar si los nibbles de BCD0 y BCD1 son mayores que .4
    movlw .5		;W = .5
    subwf BCD0,W	;W = BCD0 - .5
    btfsc STATUS,C  ;Si BCD0>4 => Carry = 1
    call  SUMA3_BCD0;BCD0>4, hay que sumar 3
    movlw .5		;BCD0 <5, se comprueba BCD1
    subwf BCD1,W	;W = BCD1 - .5
    btfsc STATUS,C  ;Si BCD1>4 => Carry = 1
    call  SUMA3_BCD1;BCD1>4, hay que sumar 3 
    swapf BCD1,f    ;Inversi?n de nibbles en BCD1
    movf  BCD1,W	;W = BCD1
    iorwf BCD0		;BCD0 = BCD1 OR BCD0
    incf  cont,f  ;cont = cont + 1
    goto  CONV		;Se repite el proceso
SUMA3_BCD0:
    movlw .3		;W = .3
    addwf BCD0,f  ;BCD0 = BCD0 + .3
    return			;retorno del call
SUMA3_BCD1:
    movlw .3		;W = .3
    addwf BCD1,f  ;BCD1 = BCD1 + .3
    return			;retorno del call
;############3 
    
;;TIEMPOS
RETARDO1:
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
RETARDO:
    MOVLW .249
    MOVWF T1
LAZO01: NOP
    DECFSZ T1,F
    GOTO LAZO01
    RETURN
DELAY15MSEG:
    movlw .50
    movwf conta1
RETAR3:
    movlw .100
    movwf conta2
RETAR4:
    decfsz conta2,f
    goto   RETAR4
    decfsz conta1,f
    goto   RETAR3
    return    
;###############################################################################    
    END