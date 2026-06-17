LIST P=16F887
    #INCLUDE <p16f887.inc>

    __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    __CONFIG _CONFIG2, _BOR40V & _WRT_OFF

; DEFINICIÓN DE VARIABLES
W_TEMP      EQU 0x70    
STATUS_TEMP EQU 0x71

    CBLOCK 0x20
    ; Contadores
        MS_CONT_L        
        MS_CONT_H           
        BEAT_CONT        
    ; Variables para displays
        UNIDADES         
        DECENAS          
        CENTENAS         
        DISP_ACTIVO      
    ; Resto 
        AUX          
        ESTADO_PULSO
        BEEP_TIMER
        BPM    
    ; Variables UART y ADC continuos
        CMD             
        FLAG_ADC        
        UART_TEMP       ; Reemplaza W_TEMP en subrutinas para no romper ISR
        UART_DELAY      ; Pre-escaler para no saturar el envío por TX
    ENDC

; VECTORES DE INICIO E INTERRUPCIÓN

    ORG 0x0000          
    GOTO INICIO

    ORG 0x0004          
ISR:
    ;Guardar contexto
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP

    ; CHEQUEO RX UART (Recepción de Comandos)
    BANKSEL PIR1
    BTFSS PIR1, RCIF
    GOTO CHK_TMR0

    BANKSEL RCREG
    MOVF RCREG, W
    MOVWF CMD           ; Guardo comando recibido

    MOVLW 'A'
    XORWF CMD, W
    BTFSC STATUS, Z
    GOTO CMD_LED_ON

    MOVLW 'B'
    XORWF CMD, W
    BTFSC STATUS, Z
    GOTO CMD_LED_OFF

    MOVLW 'C'
    XORWF CMD, W
    BTFSC STATUS, Z
    GOTO CMD_ADC_START

    MOVLW 'D'
    XORWF CMD, W
    BTFSC STATUS, Z
    GOTO CMD_ADC_STOP
    GOTO CHK_TMR0

CMD_LED_ON:
    BANKSEL PORTB
    BSF PORTB, 4
    CALL UART_SendOK
    GOTO CHK_TMR0

CMD_LED_OFF:
    BANKSEL PORTB
    BCF PORTB, 4
    CALL UART_SendOK
    GOTO CHK_TMR0

CMD_ADC_START:
    BANKSEL FLAG_ADC
    BSF FLAG_ADC, 0
    CALL UART_SendOK
    GOTO CHK_TMR0

CMD_ADC_STOP:
    BANKSEL FLAG_ADC
    BCF FLAG_ADC, 0
    CALL UART_SendOK
    GOTO CHK_TMR0

    ; CHEQUEO TIMER0 (1ms Multiplexado y Tiempos)
CHK_TMR0:
    BANKSEL INTCON
    BTFSS INTCON, T0IF
    GOTO CHK_ADC        

    BCF INTCON, T0IF    ; Limpiar bandera
    MOVLW d'6'          ; Recargar Timer0 (1ms)
    MOVWF TMR0

    ; Actualizar contadores de 10s
    BANKSEL MS_CONT_L
    INCF MS_CONT_L, F
    BTFSC STATUS, Z
    INCF MS_CONT_H, F
   
    ; Lógica del BUZZER
    BANKSEL BEEP_TIMER
    MOVF BEEP_TIMER, F
    BTFSC STATUS, Z
    GOTO BUZZER_OK
    DECFSZ BEEP_TIMER, F
    GOTO BUZZER_OK	; Me salteo el resto hasta que se tenga q apagar
    BANKSEL PORTB
    BCF PORTB, 0        ; Apagar buzzer al llegar a 0

BUZZER_OK:
    ; Arranco conversión ADC
    BANKSEL ADCON0
    BSF ADCON0, GO

    ; MULTIPLEXADO DISPLAYS
    BANKSEL PORTC
    CLRF PORTC          

    BANKSEL DISP_ACTIVO
    MOVF DISP_ACTIVO, W
    XORLW D'0'
    BTFSC STATUS, Z
    GOTO MOSTRAR_CENTENAS

    MOVF DISP_ACTIVO, W
    XORLW D'1'
    BTFSC STATUS, Z
    GOTO MOSTRAR_DECENAS
    
    MOVF DISP_ACTIVO, W
    XORLW D'2'
    BTFSC STATUS, Z
    GOTO MOSTRAR_UNIDADES
    
    GOTO MOSTRAR_LETRA_L

MOSTRAR_CENTENAS:
    MOVF CENTENAS, W
    CALL TABLA_7SEG          
    MOVWF PORTD                
    MOVLW B'00000001'   ; Enciende Display 1 (RC0)
    MOVWF PORTC                
    MOVLW D'1'
    MOVWF DISP_ACTIVO          
    GOTO CHK_ADC

MOSTRAR_DECENAS:
    MOVF DECENAS, W
    CALL TABLA_7SEG
    MOVWF PORTD                
    MOVLW B'00000010'   ; Enciende Display 2 (RC1)
    MOVWF PORTC                
    MOVLW D'2'
    MOVWF DISP_ACTIVO          
    GOTO CHK_ADC

MOSTRAR_UNIDADES:
    MOVF UNIDADES, W
    CALL TABLA_7SEG
    MOVWF PORTD                
    MOVLW B'00000100'   ; Enciende Display 3 (RC2)
    MOVWF PORTC            
    MOVLW D'3'          
    MOVWF DISP_ACTIVO          
    GOTO CHK_ADC
    
MOSTRAR_LETRA_L:
    MOVLW 0x38          ; L 
    MOVWF PORTD         
    MOVLW B'00001000'   ; Enciende Display 4 (RC3)
    MOVWF PORTC
    CLRF DISP_ACTIVO    
    
    ; CHEQUEO ADC (Fin de conversión)
CHK_ADC:
    BANKSEL PIR1
    BTFSS PIR1, ADIF
    GOTO END_ISR        
    BCF PIR1, ADIF      

    ; ENVÍO UART 
    BANKSEL FLAG_ADC
    BTFSS FLAG_ADC, 0
    GOTO ANALIZAR_PULSO

    ; Enviamos datos cada 50ms para no saturar TX
    BANKSEL UART_DELAY
    DECFSZ UART_DELAY, F
    GOTO ANALIZAR_PULSO
    MOVLW d'10'
    MOVWF UART_DELAY

    BANKSEL ADRESH
    MOVF ADRESH, W
    CALL UART_SendDecimal

ANALIZAR_PULSO:
    ; Evaluamos si hay latido (ADC 8 bits, ADFM=0, Umbral 0x80 = 2.5V)
    BANKSEL ADRESH
    MOVF ADRESH, W
    SUBLW 0x7F          ; Si ADRESH >= 128 (0x80)
    BTFSS STATUS, C
    GOTO ONDA_ALTA       
    GOTO ONDA_BAJA       

ONDA_ALTA:
    BANKSEL ESTADO_PULSO
    MOVF ESTADO_PULSO, W
    XORLW D'1'
    BTFSC STATUS, Z
    GOTO END_ISR        ; Ya estaba alto

    ; Latido nuevo
    INCF BEAT_CONT, F
    MOVLW D'1'
    MOVWF ESTADO_PULSO  
    
    ; Activar BUZZER
    MOVLW D'50'         ; Duración pitido
    MOVWF BEEP_TIMER
    BANKSEL PORTB
    BSF PORTB, 0
    GOTO END_ISR

ONDA_BAJA:
    BANKSEL ESTADO_PULSO
    CLRF ESTADO_PULSO   

END_ISR:
    ; Restaurar contexto
    BANKSEL PORTA
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE

; RUTINAS UART Y CÁLCULOS

UART_SendByte:
    BANKSEL TXSTA
_wait_tx:
    BTFSS TXSTA, TRMT
    GOTO _wait_tx
    BANKSEL TXREG
    MOVWF TXREG
    RETURN

UART_SendOK:
    MOVLW 'O'
    CALL UART_SendByte
    MOVLW 'K'
    CALL UART_SendByte
    MOVLW 0x0A
    CALL UART_SendByte
    RETURN

UART_SendDecimal:
    MOVWF CMD             

    CLRF UART_TEMP
_cent_loop:
    MOVLW .100
    SUBWF CMD, W
    BTFSS STATUS, C
    GOTO _send_cent
    MOVWF CMD
    INCF UART_TEMP, F
    GOTO _cent_loop
_send_cent:
    MOVFW UART_TEMP
    ADDLW '0'
    CALL UART_SendByte

    CLRF UART_TEMP
_dec_loop:
    MOVLW .10
    SUBWF CMD, W
    BTFSS STATUS, C
    GOTO _send_dec
    MOVWF CMD
    INCF UART_TEMP, F
    GOTO _dec_loop
_send_dec:
    MOVFW UART_TEMP
    ADDLW '0'
    CALL UART_SendByte
  
    MOVFW CMD
    ADDLW '0'
    CALL UART_SendByte
  
    MOVLW 0x0A
    CALL UART_SendByte
    RETURN

TABLA_7SEG:
    ANDLW 0x0F         
    ADDWF PCL, F
    RETLW 0x3F ; 0
    RETLW 0x06 ; 1
    RETLW 0x5B ; 2
    RETLW 0x4F ; 3
    RETLW 0x66 ; 4
    RETLW 0x6D ; 5
    RETLW 0x7D ; 6
    RETLW 0x07 ; 7
    RETLW 0x7F ; 8
    RETLW 0x67 ; 9

DESCOMPONER_NUMERO:
    CLRF CENTENAS
    CLRF DECENAS
    MOVF BPM, W
    MOVWF UNIDADES            
LOOP_100:
    MOVLW D'100'              
    SUBWF UNIDADES, W         
    BTFSS STATUS, C           
    GOTO PREP_10
    MOVWF UNIDADES            
    INCF CENTENAS, F          
    GOTO LOOP_100
PREP_10:
    MOVLW D'10'               
    SUBWF UNIDADES, W         
    BTFSS STATUS, C           
    RETURN                    
    MOVWF UNIDADES            
    INCF DECENAS, F           
    GOTO PREP_10

; PROGRAMA PRINCIPAL

INICIO:
    ; Puertos y Periféricos
    BANKSEL TRISA
    BSF TRISA, 0        ; RA0 entrada analógica
    CLRF TRISD          ; PORTD Salida (7seg)
    CLRF TRISC          
    BSF TRISC, 7        ; RX
    BCF TRISC, 6        ; TX

    BANKSEL TRISB
    BCF TRISB, 0        ; RB0 Buzzer Salida
    BCF TRISB, 4        ; RB4 LED Salida

    ; Limpiar salidas compartidas
    BANKSEL PORTB
    BCF PORTB, 0
    BCF PORTB, 4

    ; ADC (Configurado a 8-Bits Justificado Izquierda)
    BANKSEL ANSEL
    BSF ANSEL, 0        
    BANKSEL ADCON1
    BCF ADCON1, ADFM    ; ADFM=0 (Izquierda para fácil envío UART)
    BANKSEL ADCON0
    MOVLW b'01000001'   ; Fosc/8, CH0, ADC ON
    MOVWF ADCON0

    ; UART Config
    BANKSEL SPBRG
    MOVLW .12
    MOVWF SPBRG
    BANKSEL TXSTA
    MOVLW b'00100100'     
    MOVWF TXSTA
    BANKSEL RCSTA
    MOVLW b'10010000'     
    MOVWF RCSTA

    ; Timer0 Config
    BANKSEL OPTION_REG
    MOVLW b'11010001'   ; Prescaler 1:4 (1ms ticks)
    MOVWF OPTION_REG

    ; Inicializar Variables
    BANKSEL PORTA       
    CLRF MS_CONT_L
    CLRF MS_CONT_H
    CLRF BEAT_CONT
    CLRF DISP_ACTIVO
    CLRF FLAG_ADC
    CLRF ESTADO_PULSO
    CLRF BEEP_TIMER
    MOVLW d'50'
    MOVWF UART_DELAY

    ; Habilitar Interrupciones
    BANKSEL PIE1
    BSF PIE1, ADIE      ; ADC
    BSF PIE1, RCIE      ; UART RX
    BANKSEL INTCON
    BSF INTCON, T0IE    ; Timer0
    BSF INTCON, PEIE    ; Periféricos
    BSF INTCON, GIE     ; Globales

    ; Mensaje de Listo UART
    MOVLW 'R'
    CALL UART_SendByte
    MOVLW 'D'
    CALL UART_SendByte
    MOVLW 'Y'
    CALL UART_SendByte
    MOVLW 0x0A
    CALL UART_SendByte

LOOP:
    ; Verificación 10000ms (0x2710)
    BANKSEL MS_CONT_H
    MOVF MS_CONT_H, W
    SUBLW 0x27
    BTFSS STATUS, Z
    GOTO LOOP            
    
    MOVF MS_CONT_L, W
    SUBLW 0x10
    BTFSC STATUS, C
    GOTO LOOP

    ; Cálculo BPM (latidos en 10s * 6)
    BCF INTCON, GIE     
    
    MOVF BEAT_CONT, W
    MOVWF AUX
    BCF STATUS, C
    RLF AUX, F     ; x2
    MOVF AUX, W
    MOVWF BPM    
    BCF STATUS, C
    RLF AUX, F     ; x4
    MOVF AUX, W
    ADDWF BPM, F   ; x6

    ; Reinicio de variables para el siguiente ciclo
    CLRF MS_CONT_L
    CLRF MS_CONT_H
    CLRF BEAT_CONT
    
    ; Pasar a BCD para displays
    CALL DESCOMPONER_NUMERO

    BSF INTCON, GIE  

    MOVLW 'B'
    CALL UART_SendByte
    MOVLW 'P'
    CALL UART_SendByte
    MOVLW 'M'
    CALL UART_SendByte
    MOVLW ':'
    CALL UART_SendByte
    
    MOVF BPM, W         ; Cargar el valor del BPM
    CALL UART_SendDecimal
    
    GOTO LOOP

    END