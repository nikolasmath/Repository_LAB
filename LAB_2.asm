#include "p18f4550.inc"
  CONFIG  FOSC = XT_XT          ; Oscillator Selection bits (EC oscillator, CLKO function on RA6 (EC))
  CONFIG  PWRT = ON            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOR = ON              ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown-out Reset Voltage bits (Minimum setting 2.05V)
  CONFIG  WDT = OFF              ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PBADEN = OFF           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
  CONFIG  LVP = OFF 
  cblock 0x60
 ;#####################
  ; variables para temp
  bin_temper
  incre    ; una variable que ayuda al algoritmo
  aux_aux   ; ayuda a tener en forma decimal los °C
  punto_5   ; para saber si tiene .5°C o .0°C
  centigrados
  lm35_temp
  decimal
  ;######################
  ; variables para potenciometros
  v_potL  ; para ADRESL
  v_potH   ; para ADRESH
  
  modo_off_p1
  modo_off_p2
  salidac ; salida en C
  salidap ; salida de punto decimal
  
  pcont
  aux_off
  aux_para_pot
  
  cpot1  ; variables comparables para pot1
  ppot1 ; variables comparables de .5 o .0 pot1
  cpot2 ; variables comparables para pot2
  ppot2  ;variables comparables de .5 o .0 pot2
  
  ;############################
  ;variables de teclado
  cont_te
  valor0
  valor1
  valor2
  valor3
  valor4
  valor5
  valor6
  valor7
  aux_fila
  msg
  
  ;####################################
  ;para convertir a codigo ascii
  unid
  dece
  cent
  converter
  mostrar_punto
  mostrar_punto_1
  pos
  pos_1
  
 ; ####################
 ; sin titileo
 static_msg1
 static_msg2
 static_msg3
 static_msg4
 static_msg5
 
 aux_sat
 aux_msg
  endc
  
  org 0x0000
    goto configuracion
  org 0x0008
    goto teclado
    
  org 0x0020
configuracion:
    
    ;#############################
    ;configuracion de LCD
    clrf TRISD
    call DELAY15MSEG
    call LCD_CONFIG
    call CURSOR_OFF
    ;############################
    ; configuracion de ADCON
    movlw 0x0C
    movwf ADCON1 ; AN0, AN1, AN2 como A/D, lo demas puertos digital
    movlw 0xFC   ;  FC
    movwf ADCON2 ; 20TAD con reloj de 1us
       
    ;######################################
    ;puertos de salida
    clrf TRISC
    bcf TRISE,0  ; salida led
    bcf TRISE,1  ; salida buzzer
    ;##########################################
    ; teclado
    movlw 0xF0   ; b'11110000'
    movwf TRISB  ; salida B0,B1,B2,B3  entrada B4,B5,B6,B7
    bcf INTCON2, RBPU   ; pull - up B4,B5,B6,B7
    bsf INTCON, RBIE    ; activacion de puerto RB
    bsf INTCON, GIE   ; ACTIVA INTERRUP 
    clrf aux_msg
inicio:
    movf aux_msg,w
    cpfseq msg
    call reinicia_fabrica
       
    conversion_temper:
    movlw .1
    movwf ADCON0; ADC ON para AN0
    temperatura:
    bsf ADCON0,1
    btfsc ADCON0,1    ; esperamos que sea 0
    goto temperatura ; sigo esperando
    movff ADRESL, bin_temper ; muevo a una variable
    call convertidor_cent ; me va devolver un numero que esta en Centigrados y el otro valor sera .5 o .0, para comparar
    movff centigrados, lm35_temp;me da salida centigrados
    movff punto_5, decimal              ; me da salida punto_5
    

    conversion_pot1:
    movlw .5
    movwf ADCON0; ADC ON para AN1
    pot1:
    bsf ADCON0,1
    btfsc ADCON0,1    ; esperamos que sea 0
    goto pot1 ; sigo esperando
    movff ADRESL, v_potL ; muevo a una variable
    movff ADRESH, v_potH
    call convertidor_pot ; me va devolver un numero que esta en Centigrados y el otro valor sera .5 o .0, para comparar
    movff salidac,cpot1
    movff salidap,ppot1
    movff aux_off, modo_off_p1
    
    
    conversion_pot2:
    movlw .9
    movwf ADCON0; ADC ON para AN1
    pot2:
    bsf ADCON0,1
    btfsc ADCON0,1    ; esperamos que sea 0
    goto pot2 ; sigo esperando
    movff ADRESL, v_potL ; muevo a una variable
    movff ADRESH, v_potH ; muevo a una variable
    call convertidor_pot ; me va devolver un numero que esta en Centigrados y el otro valor sera .5 o .0, para comparar
    movff salidac,cpot2
    movff salidap,ppot2
    movff aux_off, modo_off_p2
    
    movlw .0
    cpfseq modo_off_p1
    goto pregunta_por_op3
    
    movlw .0
    cpfseq modo_off_p2
    goto op2
    
    ;########################################
    op1:
    
    movf cpot2,w
    cpfslt cpot1
    goto si_es_igual
    call ambos
    goto mensajes
    
    si_es_igual:
    movf cpot2,w
    cpfseq cpot1
    goto sigue_op1
    
    call ambos
    goto mensajes
    
    sigue_op1:
    movf lm35_temp,w
    cpfsgt cpot1
    goto pregunton_op1a  ; W mayor o igual 
    ; W eres menor
    goto op1b
       
    pregunton_op1a:
    movf lm35_temp,w ; es mayor
    cpfseq cpot1
    goto alarma_op1a
    
    
    
    movf decimal,w
    cpfsgt ppot1
    goto mayor_o_igual_op1a       ; W mayor o igual
    ; W es menor
    call off_off
    goto mensajes 
    
    mayor_o_igual_op1a:
    movf ppot1,w
    cpfseq decimal
    goto alarma_op1a  ; W  es mayor
    call off_off
    goto mensajes
    
    alarma_op1a:
    call buzzer
    goto mensajes 
    
    op1b:
    movf lm35_temp,w
    cpfslt cpot2
    goto pregunton_op1b  ; W menor o igual 
    ; W eres mayor
    call off_off
    goto mensajes
    
    pregunton_op1b:
    movf lm35_temp,w ; es mayor
    cpfseq cpot2
    goto prende_led_op1b
    
    movlw .3
    cpfseq decimal
    goto adelante_op1b
    
    movlw .2
    addwf decimal,f
    
    adelante_op1b:
    movf decimal,w
    cpfslt ppot2
    goto menor_o_igual_op1b        ; W menor o igual
    ; W es mayor
    call off_off
    goto mensajes 
    
    menor_o_igual_op1b:
    movf ppot2,w
    cpfseq decimal
    goto prende_led_op1b ; W  es menor
    call off_off
    goto mensajes
    
    prende_led_op1b:
    call prende_led
    goto mensajes
    
    
    
   
    
    ;#############################################
    
    op2:
    movf lm35_temp,w
    cpfsgt cpot1
    goto pregunton_op2  ; W mayor o igual 
    ; W eres menor
    call off_off
    goto mensajes
    
    pregunton_op2:
    movf lm35_temp,w ; es mayor
    cpfseq cpot1
    goto alarma
    
    
    movf decimal,w
    cpfsgt ppot1
    goto mayor_o_igual_op2        ; W mayor o igual
    ; W es menor
    call off_off
    goto mensajes 
    
    mayor_o_igual_op2:
    movf ppot1,w
    cpfseq decimal
    goto alarma  ; W  es mayor
    call off_off
    goto mensajes
    
    alarma:
    call buzzer
    goto mensajes 
    
    
    ;###################################
    pregunta_por_op3:
    movlw .0
    cpfseq modo_off_p2
    goto op4
    
    op3:
    movf lm35_temp,w
    cpfslt cpot2
    goto pregunton_op3  ; W menor o igual 
    ; W eres mayor
    call off_off
    goto mensajes
    
    pregunton_op3:
    movf lm35_temp,w ; es mayor
    cpfseq cpot2
    goto prende_led_op3
    movlw .3
    cpfseq decimal
    goto adelante_op3
    
    movlw .2
    addwf decimal,f
    adelante_op3:
    movf decimal,w
    cpfslt ppot2
    goto menor_o_igual_op3        ; W menor o igual
    ; W es mayor
    call off_off
    goto mensajes 
    
    menor_o_igual_op3:
    movf ppot2,w
    cpfseq decimal
    goto prende_led_op3  ; W  es menor
    call off_off
    goto mensajes
    
    prende_led_op3:
    call prende_led
    goto mensajes 
    
    ;############################################
    op4:
    call off_off
    ;goto mensajes
    
    
    
   
    
mensajes:
    
    movlw .0
    cpfseq msg
    goto preg_msg_2
    
    movf static_msg1,w
    cpfseq bin_temper
    goto msg_1_continua
    goto inicio
    
    msg_1_continua:
    movf lm35_temp,w
    call converter_LCD
    movlw .2                     ; para evitar titileo
    movwf pos
                        ; para evitar titileo
    movwf pos_1
    call mensaje_1_LCD
    clrf aux_msg
    goto inicio
    
    preg_msg_2:
    
    clrf aux_sat
    movf cpot1,w
    addwf aux_sat,f
    movf ppot1,w
    addwf aux_sat,f
    
    movlw .1
    cpfseq  msg
    goto preg_msg_3
    
    movf static_msg2,w
    cpfseq aux_sat
    goto msg_2_continua
    goto inicio
     
    msg_2_continua:
    
    movf cpot1,w
    call converter_LCD
    movlw .1                     ; para evitar titileo
    movwf pos
    
    ; para evitar titileo
    movlw .0
    movwf pos_1
    call mensaje_2_LCD
    movlw .1
    movwf aux_msg
    goto inicio
    
    preg_msg_3:
    
    clrf aux_sat
    movf cpot2,w
    addwf aux_sat,f
    movf ppot2,w
    addwf aux_sat,f
    
    movlw .2
    cpfseq msg
    goto preg_msg_4
    
    movf static_msg3,w
    cpfseq aux_sat
    goto msg_3_continua
    goto inicio
    
    msg_3_continua:
    movf cpot2,w
    call converter_LCD	
    ; evitar titileo
    movlw .1                     ; para evitar titileo
    movwf pos
    
    clrf pos_1
    call mensaje_3_LCD
    movlw .2
    movwf aux_msg
    goto inicio
    
    preg_msg_4:
        
    movlw .3
    cpfseq msg
    goto es_msg_5
    
    movf static_msg4,w
    cpfseq modo_off_p1
    goto msg_4_continua  
    goto inicio
    
    msg_4_continua:        ; evitar titileo
    movlw .1
    movwf pos
    movlw .6
    movwf pos_1
    
    call mensaje_4_LCD
    movlw .3
    movwf aux_msg
    goto inicio
    
    es_msg_5:
			; evitar titileo

    movf static_msg5,w
    cpfseq modo_off_p2
    goto msg_5_continua  
    goto inicio
    
          ; evitar titileo		
    msg_5_continua:
    movlw .1
    movwf pos
    movlw .6
    movwf pos_1
    call mensaje_5_LCD
    movlw .4
    movwf aux_msg
    goto inicio
    
    
    
    mensaje_1_LCD:
    movff bin_temper,static_msg1
    movlw .0
    cpfseq punto_5
    goto uno
    
    movlw 0x30
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    goto display
    uno:
    movlw 0x35
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    display:
    
    call BORRARLINEAS_TEMP
    movlw 'T'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 'M'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw ':'
    call  ENVIA_CHAR
    
    movf cent,w
    call  ENVIA_CHAR
    
    movf dece,w
    call  ENVIA_CHAR
    
    movf unid,w
    call  ENVIA_CHAR
    
    movlw '.'
    call  ENVIA_CHAR
    
    movf  mostrar_punto,w
    call  ENVIA_CHAR
    
    movf  mostrar_punto_1,w
    call  ENVIA_CHAR
    
    movlw 0xDF
    call  ENVIA_CHAR
    
    movlw 'C'
    call  ENVIA_CHAR
    
    
    ; call BORRARLINEAS_2
    movlw .0
    call  POS_CUR_FIL2
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movf pos_1,w
    call  POS_CUR_FIL2
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw 0x31
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    
    
    movlw 0x2B
    call  ENVIA_CHAR
    
    movlw 0x2F
    call  ENVIA_CHAR
    
    movlw 0x2D
    call  ENVIA_CHAR
    
    movlw 0x30
    call  ENVIA_CHAR
    
    movlw '.'
    call  ENVIA_CHAR
    movlw 0x35
    
    call  ENVIA_CHAR
    
    movf  mostrar_punto_1,w
    call  ENVIA_CHAR
    movlw 0xDF
    call  ENVIA_CHAR
    movlw 'C'
    call  ENVIA_CHAR
    
    
    return

 
    mensaje_2_LCD:
    
    movff aux_sat,static_msg2
    ;clrf aux_sat
    movlw .0
    cpfseq ppot1
    goto uno_dos
    
    movlw 0x30
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    
    goto display_2
    uno_dos:
    movlw .3
    cpfslt ppot1 
    goto tres_4_5
    
    movlw 0x32
    movwf mostrar_punto
    movlw 0x35
    movwf mostrar_punto_1
    goto display_2
    
    tres_4_5:
    movlw .6
    cpfslt ppot1 
    goto seis_7
    
    movlw 0x35
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    goto display_2
    
    seis_7:
    
    
    movlw 0x37
    movwf mostrar_punto
    movlw 0x35
    movwf mostrar_punto_1
    ;goto display_2
    
    
    
    display_2:
    
    movlw .0
    call  POS_CUR_FIL1
    
    movf pos_1,w
    call  POS_CUR_FIL1
    
    movlw 'L'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'M'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'T'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 'S'
    call  ENVIA_CHAR
    
    movlw 'U'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    ;movlw .0
    ;call  POS_CUR_FIL2
    movlw .13
    call  POS_CUR_FIL2
    movlw 0xFE
    call  ENVIA_CHAR
      
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    
    movf pos_1,w
    call  POS_CUR_FIL2
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw 0x32
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
        
    
    movf cent,w
    call  ENVIA_CHAR
    
    movf dece,w
    call  ENVIA_CHAR
    
    movf unid,w
    call  ENVIA_CHAR
    
    movlw '.'
    call  ENVIA_CHAR
    
    movf  mostrar_punto,w
    call  ENVIA_CHAR
    
    movf  mostrar_punto_1,w
    call  ENVIA_CHAR
    movlw 0xDF
    call  ENVIA_CHAR
    movlw 'C'
    call  ENVIA_CHAR
    
    return
    
    mensaje_3_LCD:
    movff aux_sat,static_msg3
    ;clrf aux_sat
    
    movlw .0
    cpfseq ppot2
    goto uno_dos_b
    
    movlw 0x30
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    
    goto display_3
    uno_dos_b:
    movlw .3
    cpfslt ppot2 
    goto tres_4_5_b
    
    movlw 0x32
    movwf mostrar_punto
    movlw 0x35
    movwf mostrar_punto_1
    goto display_3
    
    tres_4_5_b:
    movlw .6
    cpfslt ppot2
    goto seis_7_b
    
    movlw 0x35
    movwf mostrar_punto
    movlw 0x30
    movwf mostrar_punto_1
    goto display_3
    
    seis_7_b:
    
    
    movlw 0x37
    movwf mostrar_punto
    movlw 0x35
    movwf mostrar_punto_1
    ;goto display_3
    
    
    
    display_3:
    
    
    movlw .0
    call  POS_CUR_FIL1
    
    movlw 'L'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'M'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'T'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'N'
    call  ENVIA_CHAR
    
    movlw 'F'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    movlw .13
    call  POS_CUR_FIL2
    movlw 0xFE
    call  ENVIA_CHAR
      
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    
    movf pos_1,w
    call  POS_CUR_FIL2
    
     movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw 0x33
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    
    
    movf cent,w
    call  ENVIA_CHAR
    
    movf dece,w
    call  ENVIA_CHAR
    
    movf unid,w
    call  ENVIA_CHAR
    
    movlw '.'
    call  ENVIA_CHAR
    
    movf  mostrar_punto,w
    call  ENVIA_CHAR
    
    movf  mostrar_punto_1,w
    call  ENVIA_CHAR
    movlw 0xDF
    call  ENVIA_CHAR
    movlw 'C'
    call  ENVIA_CHAR
    
    return
    
    mensaje_4_LCD:
    
    movff modo_off_p1,static_msg4
    
    ;display_4:
    
    
    call BORRARLINEAS
    movlw 'L'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'M'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'T'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 'S'
    call  ENVIA_CHAR
    
    movlw 'U'
    call  ENVIA_CHAR
    
    movlw 'P'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    
    movlw .1
    cpfseq modo_off_p1
    goto encendido
    goto apagado
    
    mensaje_5_LCD:
    
    movff modo_off_p2,static_msg5
    
    ;display_5:
    
    
    call BORRARLINEAS
    movlw 'L'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'M'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'T'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 0xFE
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'N'
    call  ENVIA_CHAR
    
    movlw 'F'
    call  ENVIA_CHAR
    
    movlw 'E'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    movlw 'I'
    call  ENVIA_CHAR
    
    movlw 'O'
    call  ENVIA_CHAR
    
    movlw 'R'
    call  ENVIA_CHAR
    
    
    movlw .1
    cpfseq modo_off_p2
    goto encendido
    ;goto apagado
    
    
    
    
    
    
    apagado:
    call BORRARLINEAS_2
    
    
    
    movlw 'O'
    call  ENVIA_CHAR
    movlw 'F'
    call  ENVIA_CHAR
    movlw 'F'
    call  ENVIA_CHAR
    
    
    return
    
    encendido:
    
    call BORRARLINEAS_2
    
    
    
    movlw 'O'
    call  ENVIA_CHAR
    movlw 'N'
    call  ENVIA_CHAR
    
    
    
    return
    
    
    
    
BORRARLINEAS:
    
    movlw .0
    call  POS_CUR_FIL1
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    
    movf pos,w 
    call  POS_CUR_FIL1
    return   

BORRARLINEAS_2:
    
    movlw .0
    call  POS_CUR_FIL2
    movlw 0xFE
    call  ENVIA_CHAR
   movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movlw 0xFE
    call  ENVIA_CHAR
    movf pos_1,w
    call  POS_CUR_FIL2
    return   
  
 BORRARLINEAS_TEMP:
    movlw .0
    call  POS_CUR_FIL1
    movlw 0xFE
    call  ENVIA_CHAR
    movlw .1
    call  POS_CUR_FIL1
    movlw 0xFE
    call  ENVIA_CHAR
    movlw .15
    call  POS_CUR_FIL1
    movlw 0xFE
    call  ENVIA_CHAR
    
    movf pos,w 
    call  POS_CUR_FIL1
    return     
    
    
    
 convertidor_cent:
    clrf incre
    clrf aux_aux
    clrf punto_5
    clrf centigrados
    
    
    
    movlw .206
    cpfslt bin_temper
    goto cien_grados
    
    
    
    ; 6°C 
    movlw .12
    cpfsgt bin_temper
    goto compara_igual_12  ; si es menor o igual 
    decf bin_temper,f     ; si es mayor  resta en 1
    goto para_2_5
    
    compara_igual_12:
    movlw .12
    cpfseq bin_temper
    goto algoritmo
    decf bin_temper,f 
    goto algoritmo
    
    ;####################################
    ; 25°
    para_2_5: 
    movlw .51
    cpfsgt bin_temper
    goto compara_igual_51  ; si es menor o igual 
    decf bin_temper,f     ; si es mayor  resta en 1
    goto para_4_5
    
    compara_igual_51:
    movlw .51
    cpfseq bin_temper
    goto algoritmo
    decf bin_temper,f 
    goto algoritmo
    ;####################################
    ;45°
    para_4_5:
    movlw .92
    cpfsgt bin_temper
    goto compara_igual_92  ; si es menor o igual 
    decf bin_temper,f     ; si es mayor  resta en 1
    goto para_6_5
    
    compara_igual_92:
    movlw .92
    cpfseq bin_temper
    goto algoritmo
    decf bin_temper,f 
    goto algoritmo 
    ;###################################
    ; 65°
    para_6_5:
    movlw .133
    cpfsgt bin_temper
    goto compara_igual_133  ; si es menor o igual 
    decf bin_temper,f     ; si es mayor  resta en 1
    goto para_8_5
    
    compara_igual_133:
    movlw .133
    cpfseq bin_temper
    goto algoritmo
    decf bin_temper,f 
    goto algoritmo
    ;################################
    ; 85°
    para_8_5:
    movlw .174
    cpfsgt bin_temper
    goto compara_igual_174  ; si es menor o igual 
    decf bin_temper,f     ; si es mayor  resta en 1
    goto algoritmo
    
    compara_igual_174:
    movlw .174
    cpfseq bin_temper
    goto algoritmo
    decf bin_temper,f 
    
    ;################################
    
    algoritmo:
    movf incre,w
    cpfseq bin_temper
    goto incrementa
    goto obtener_cent
    
    incrementa:
    incf incre,f   
    call cambiante ; para saber si esta en punto decimal C.5°
    goto algoritmo
    
    
             
   ;######################################
    cambiante:
    movlw .0
    cpfseq punto_5
    goto cambia_a_cero
    movlw .3
    movwf punto_5
    return
    cambia_a_cero:
    movlw .0
    movwf punto_5
    return
    ;#####################################
    
    obtener_cent:
    movf incre,w
    cpfslt aux_aux
    goto salida_en_C ; si es mayor o igual
    ; si es menor
    ;incrementacion:
    movlw .2
    addwf aux_aux,f
    incf centigrados,f
    goto obtener_cent
    
    salida_en_C:
    movf incre,w
    cpfseq aux_aux
    goto resta
    return
    
    resta:
    decf centigrados,f
    return
    
    cien_grados:
    movlw .100
    movwf centigrados
    clrf punto_5
    
    return
    
    
    
convertidor_pot:  
    clrf salidac
    clrf salidap
    clrf pcont
    clrf aux_off
    clrf aux_para_pot
    
   
    
    movlw .3
    cpfseq v_potH
    goto preg_val_2
    goto agrega_71C
    
    preg_val_2:
    movlw .2
    cpfseq v_potH
    goto preg_val_1
    goto agrega_39C
    
    preg_val_1:
    movlw .1
    cpfseq v_potH
    goto ninguno
    goto agrega_7C
    
    
    agrega_71C:
    
    movlw .233
    cpfslt v_potL
    goto cien_grados_pot
    
    movlw .71
    addwf salidac,f
    goto inicias_cont
    
    agrega_39C:
    movlw .39
    addwf salidac,f
    goto inicias_cont
    
    
    agrega_7C:
    movlw .7
    addwf salidac,f
    goto inicias_cont
    
    ninguno:
    movlw .200
    cpfslt v_potL
    goto mode_on          ; si es mayor o igual
    goto mode_off         ; si es menor  
    
    mode_on:
    clrf aux_off
    movlw .200
    addwf pcont,f
    movlw .200
    addwf aux_para_pot,f
    goto inicias_cont 
    
    mode_off:
    
    movlw .1
    movwf aux_off
    return 
    
    inicias_cont:
    
    movf pcont,w
    cpfseq v_potL
    goto pincrementa
    return
    
    pincrementa:
    incf pcont,f   
    call cambiante_pot ; para saber si esta en punto decimal C.5°
    goto inicias_cont
    
    
    
    
     ;######################################
    cambiante_pot:
    
    movlw .7
    cpfseq salidap
    goto increm_pot
    clrf salidap
    incf salidac,f ; aumenta los centigrados
    
    return
    increm_pot:
    incf salidap,f   
    return
    ;#####################################
        
    
    
    cien_grados_pot:
    movlw .100
    movwf salidac
    clrf salidap
    clrf aux_off
    return
    
    
    
    
    

teclado: ;lectura de entrada matriz
        
    
    call seteador
    
    call identificarf_c ; algoritmo matricial para saber que boton
			; se presiono
    movlw .1	    ; si se ha presionado mas de un boton   
    cpfseq cont_te     ; marcara error saliendo de la 
    goto salida     ; interrupcion y clrf variable cont y  aux_fila
    ;#####################################################
    ; aqui colocar condiciones
    fila1:
    movlw .1
    cpfseq valor0
    goto fila2
    
    movlw .1
    cpfseq valor4
    goto sigue1_2
    goto button1
    
    sigue1_2:
    movlw .2
    cpfseq valor5
    goto sigue1_3
    goto button2
    
    sigue1_3:
    movlw .3
    cpfseq valor6
    goto fila2
    goto button3
    
    
    
    fila2:
    ;... aqui se agregan las 14 condiciones faltantes de los botones matriciales
    movlw .2
    cpfseq valor1
    goto fila3
    
    movlw .1
    cpfseq valor4
    goto sigue2_2
    goto button5
    
    sigue2_2:
    movlw .2
    cpfseq valor5
    goto fila4
    goto button6
    
    fila3:
    ;... fila por fila
    fila4:
    
    goto salida
 
    
    
    
    
    ;####################################################
    ; aqui colocar un looper para recibir un alto
    ; sirve para que el usuario al dejar de presionar
    ; el boton reciba la instruccion en el codigo
    
    button1:
    
    ;####################################
    ;aqui es la instruccion que recibira tu codigo para
    ;diferentes variables en codigo principal
    btfss PORTB,4
    goto button1
    
    clrf msg
    ;####################################
    goto salida
    
    button2:
    btfss PORTB,5
    goto button2
    
    movlw .1
    movwf msg
    
    
    goto salida
    
    button3:
    btfss PORTB,6
    goto button3
    
    movlw .2
    movwf msg
    goto salida
    
    ;#############################3
    button5:
    btfss PORTB,4
    goto button5
    
    
    movlw .3
    movwf msg
    
    
    goto salida
    
    
    ;......
    button6:
    btfss PORTB,5
    goto button6
    
    movlw .4
    movwf msg
    
    goto salida
    
    
    
    
    
    ;#################################################
   
    salida:
    clrf cont_te
    clrf aux_fila
    
    bcf INTCON, RBIF   ; baja bandera de interrupcion RB
    retfie

    
identificarf_c:
    ;##############################
    call row_0111
    
    call array1
    
    
    ;################################
    call row_1011
    
    call array2
    
        
     ;##############################
    call row_1101
    
    call array3
    
    ;################################
    
    call row_1110
    
    call array4
    
    ;#######################################
    
    call row_0000
       
    return
;##########################################
  
    
array1:
   
    movlw .1
    movwf valor0
    call arrayx_x
    
    movlw .0
    cpfseq aux_fila
    return
    clrf valor0
    
    return
    
array2:
    
    movlw .2
    movwf valor1
    call arrayx_x
    
    movlw .0
    cpfseq aux_fila
    return
    clrf valor1
    
    return

array3:
    
    movlw .3
    movwf valor2
    call arrayx_x
    
    movlw .0
    cpfseq aux_fila
    return
    clrf valor2
    return
    
array4:
   
    movlw .4
    movwf valor3
    call arrayx_x
    
    movlw .0
    cpfseq aux_fila
    return
    clrf valor3
    return
    
    
arrayx_x:
    btfss PORTB,4
    call array_1
    
    btfss PORTB,5
    call array_2
    
    btfss PORTB,6
    call array_3
    
    btfss PORTB,7
    call array_4
    
    
    return 
    
array_1:
    movlw .1
    movwf valor4
    incf cont_te
    incf aux_fila
    
    return 
    
array_2:
    movlw .2
    movwf valor5
    incf cont_te
    incf aux_fila
    return
    
array_3:
    movlw .3
    movwf valor6
    incf cont_te
    incf aux_fila
    
    return
    
array_4:
    movlw .4
    movwf valor7
    incf cont_te
    incf aux_fila
    return
    
;###################################   

row_0111:
    bcf LATB,0
    bsf LATB,1
    bsf LATB,2
    bsf LATB,3
    return
   
row_1011:
    bsf LATB,0
    bcf LATB,1
    bsf LATB,2
    bsf LATB,3
    return
    
row_1101:
    bsf LATB,0
    bsf LATB,1
    bcf LATB,2
    bsf LATB,3
    return
    
row_1110:
    bsf LATB,0
    bsf LATB,1
    bsf LATB,2
    bcf LATB,3
    return
    
row_0000:
   
    bcf LATB,0
    bcf LATB,1
    bcf LATB,2
    bcf LATB,3
    
    return
    

  seteador:
    clrf valor4
    clrf valor5
    clrf valor6
    clrf valor7
  return
      
   
prende_led:
    bsf LATE,0
    bcf LATE,1
    return
buzzer:
    bcf LATE,0
    bsf LATE,1
    return
off_off:
    bcf LATE,0
    bcf LATE,1
    return
ambos:
    bsf LATE,0
    bsf LATE,1
    return

    
converter_LCD:
    clrf cent
    clrf dece
    clrf unid
    clrf converter
    movwf converter
    
    
    centenas1:
       movlw .100                 ;W=d'100'
       cpfslt converter       ; pregunta si es menor
       goto resta_cent            ; si es mayor o igual
       goto prev_decenas1                 ; si es menor
       resta_cent:
       incf cent,f 
       movlw .100
       subwf converter,f
       goto centenas1
    
    prev_decenas1:
    movlw .0
    cpfseq cent
    goto decenas1
    ;goto mueve
    ;mueve:
    movlw 0xFE ; espacio en blanco
    movwf cent
    
    decenas1:
       movlw .10                 ;W=d'100'
       cpfslt converter       ; pregunta si es menor
       goto resta_dec            ; si es mayor o igual
       goto prev_unidades1       ; si es menor
       resta_dec:
       incf dece,f 
       movlw .10
       subwf converter,f
       goto decenas1
       
    prev_unidades1:
    
      
    movlw .0
    cpfseq dece
    goto unidades1
    
    movlw 0xFE
    cpfseq cent
    goto unidades1
       
    
    movlw 0xFE ; espacio en blanco
    movwf dece
    
    unidades1:
       movf converter,w      ;El resto son la Unidades BCD
       movwf unid
       
    codigo_ascii:
       movlw 0x30 
       iorwf cent,f      
       iorwf dece,f
       iorwf unid,f      
       return 
       
 reinicia_fabrica:
    movlw .300 ; numero  fuera de cuentas
    movwf aux_sat
    movwf static_msg1
    movwf static_msg2
    movwf static_msg3
    movwf static_msg4
    movwf static_msg5
    return
    
 #include "LCD_LIB.asm" 
    END
    
    
    
    
    
    
    
    
    
    

    
   