LIST P=16F887
    #INCLUDE <p16f887.inc>
    
    ; Configuración de fusibles (Oscilador interno a 4MHz)
    __CONFIG _CONFIG2, _BOR40V & _WRT_OFF
    __CONFIG _CONFIG1, _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _LVP_OFF
;====================================================================
; DEFINICIÓN DE VARIABLES (Memoria RAM Bank 0)
;====================================================================
    CBLOCK 0x20
        W_TEMP          ; Respaldo de W para Interrupción
        STATUS_TEMP     ; Respaldo de STATUS para Interrupción
        
        MS_COUNT_L      ; Contador de milisegundos (Bajo)
        MS_COUNT_H      ; Contador de milisegundos (Alto)
        REFRACT_L       ; Contador refractario (Bajo)
        REFRACT_H       ; Contador refractario (Alto)
        
        BEAT_COUNT      ; Cantidad de latidos en 10 segundos
        BPM_RESULT      ; Resultado final (BPM)
	
        
        UNIDADES        ; Dígito de unidades para displays
        DECENAS         ; Dígito de decenas para displays
        CENTENAS        ; Dígito de centenas para displays
        DISP_ACTIVO     ; Estado del multiplexado (0, 1 o 2)
        TEMP_BIN        ; Variable temporal para matemática
	ESTADO_PULSO
	BEEP_TIMER
    ENDC

;====================================================================
; VECTORES DE INICIO E INTERRUPCIÓN
;====================================================================
    ORG 0x0000          ; Vector de Reset
    GOTO MAIN

    ORG 0x0004          ; Vector de Interrupción
    ; --- GUARDAR CONTEXTO ---
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP

    ; --- RUTINA DE TIMER0 (Cada 1ms) ---
    BTFSS INTCON, T0IF
    GOTO CHK_ADC        ; Si no fue Timer0, saltar a revisar ADC

    BCF INTCON, T0IF    ; Limpiar bandera del Timer0
    MOVLW d'6'          ; Recargar Timer0
    MOVWF TMR0

    ; 1. Actualizar contadores de tiempo para el cálculo de BPM
    INCF REFRACT_L, F
    BTFSC STATUS, Z
    INCF REFRACT_H, F

    INCF MS_COUNT_L, F
    BTFSC STATUS, Z
    INCF MS_COUNT_H, F
    
        ;=================================
    ; CONTROL DEL BUZZER
    ;=================================

    BANKSEL BEEP_TIMER

    MOVF BEEP_TIMER,F
    BTFSC STATUS,Z
    GOTO BUZZER_OK

    DECFSZ BEEP_TIMER,F
    GOTO BUZZER_OK

    BANKSEL PORTB
    BCF PORTB,0

BUZZER_OK

    ; 2. Iniciar nueva conversión ADC
    BSF ADCON0, GO

    ; 3. Multiplexado de Displays
    CLRF PORTC          ; Evita fantasmas en la transición

    MOVF DISP_ACTIVO, W
    XORLW D'0'
    BTFSC STATUS, Z
    GOTO MOSTRAR_CENTENAS

    MOVF DISP_ACTIVO, W
    XORLW D'1'
    BTFSC STATUS, Z
    GOTO MOSTRAR_DECENAS

    GOTO MOSTRAR_UNIDADES

MOSTRAR_CENTENAS:
    MOVF CENTENAS, W
    CALL GET_7SEG          
    MOVWF PORTD                
    MOVLW B'00000001'   ; Enciende Display 1 (RC0)
    MOVWF PORTC                
    MOVLW D'1'
    MOVWF DISP_ACTIVO          
    GOTO CHK_ADC

MOSTRAR_DECENAS:
    MOVF DECENAS, W
    CALL GET_7SEG
    MOVWF PORTD                
    MOVLW B'00000010'   ; Enciende Display 2 (RC1)
    MOVWF PORTC                
    MOVLW D'2'
    MOVWF DISP_ACTIVO          
    GOTO CHK_ADC

MOSTRAR_UNIDADES:
    MOVF UNIDADES, W
    CALL GET_7SEG
    MOVWF PORTD                
    MOVLW B'00000100'   ; Enciende Display 3 (RC2)
    MOVWF PORTC                
    CLRF DISP_ACTIVO          

CHK_ADC:
    ; --- RUTINA DE ADC ---
    BANKSEL PIR1
    BTFSS PIR1, ADIF
    GOTO END_ISR        ; Si no fue ADC, salir
    BCF PIR1, ADIF      ; Limpiar bandera

    ; Leer resultado de 10 bits (Umbral = 515)
    BANKSEL ADRESH
    MOVF ADRESH, W
    SUBLW 0x02          
    BTFSC STATUS, C
    GOTO CHECK_LOW_BYTE 
    GOTO ONDA_ALTA       

CHECK_LOW_BYTE:
    BTFSS STATUS, Z     
    GOTO ONDA_BAJA        
    BANKSEL ADRESL
    MOVF ADRESL, W
    SUBLW 0x03          
    BTFSC STATUS, C     
    GOTO ONDA_BAJA        

ONDA_ALTA:
    ; La señal superó el umbral. ¿Ya la habíamos contado?
    BANKSEL ESTADO_PULSO
    MOVF ESTADO_PULSO, W
    XORLW D'1'
    BTFSC STATUS, Z
    GOTO END_ISR        ; Si ya estaba en 1, ignorar. Seguimos en el mismo latido.

    ; ¡Es un latido NUEVO!
    INCF BEAT_COUNT, F
    MOVLW D'1'
    MOVWF ESTADO_PULSO  ; Levantamos la bandera (bloqueamos conteo extra)
    
    ; --- BEEP DEL BUZZER ---
    MOVLW D'50'
    MOVWF BEEP_TIMER

    BANKSEL PORTB
    BSF PORTB,0

    GOTO END_ISR

ONDA_BAJA:
    ; La señal cayó por debajo del umbral
    BANKSEL ESTADO_PULSO
    CLRF ESTADO_PULSO   ; Bajamos la bandera (listos para el próximo latido)

END_ISR:
    ; --- RESTAURAR CONTEXTO ---
    BANKSEL PORTA
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE

;====================================================================
; SUBRUTINAS (Fuera del Bucle Principal)
;====================================================================
GET_7SEG:
    ANDLW 0x0F          ; Máscara de seguridad
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
    MOVF BPM_RESULT, W
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
    RETURN                    ; Retorna al Main Loop
    MOVWF UNIDADES            
    INCF DECENAS, F           
    GOTO PREP_10

;====================================================================
; PROGRAMA PRINCIPAL
;====================================================================
MAIN:
    ; --- CONFIGURACIÓN DE HARDWARE ---
    BANKSEL TRISA
    BSF TRISA, 0        ; RA0 como entrada (Sensor)
    CLRF TRISD          ; PORTD como salida (7-Seg Data)
    CLRF TRISC          ; PORTC como salida (Control Mux)
    BANKSEL TRISB
    BCF TRISB,0
    CLRF ESTADO_PULSO 
    
    BANKSEL ANSEL
    BSF ANSEL, 0        ; RA0 analógico
    
    BANKSEL ADCON1
    BSF ADCON1, ADFM    ; Justificación derecha (10 bits)
    
    BANKSEL ADCON0
    MOVLW b'01000001'   ; Fosc/8, Canal 0, ADC Encendido
    MOVWF ADCON0

    BANKSEL OPTION_REG
    MOVLW b'11010001'   ; Reloj interno, Prescaler 1:4 a Timer0
    MOVWF OPTION_REG

    BANKSEL PIE1
    BSF PIE1, ADIE      ; Habilitar interrupción ADC
    BANKSEL INTCON
    BSF INTCON, T0IE    ; Habilitar interrupción Timer0
    BSF INTCON, PEIE    ; Habilitar interrupciones periféricas
    BSF INTCON, GIE     ; Habilitar interrupciones globales

    BANKSEL PORTA       ; Asegurar que estamos en Bank 0
    CLRF MS_COUNT_L
    CLRF MS_COUNT_H
    CLRF BEAT_COUNT
    CLRF DISP_ACTIVO

        BANKSEL PORTB
    BCF PORTB,0

    BANKSEL BEEP_TIMER
    CLRF BEEP_TIMER 
LOOP:
    ; Verificar si pasaron 10000 ms (Hex: 0x2710)
    MOVF MS_COUNT_H, W
    SUBLW 0x27
    BTFSS STATUS, Z
    GOTO LOOP           
    
    MOVF MS_COUNT_L, W
    SUBLW 0x10
    BTFSC STATUS, C
    GOTO LOOP

    ; --- CALCULAR BPM (x6) ---
    BCF INTCON, GIE     ; Deshabilitar interrupciones
    
    MOVF BEAT_COUNT, W
    MOVWF TEMP_BIN
    BCF STATUS, C
    RLF TEMP_BIN, F     ; x2
    MOVF TEMP_BIN, W
    MOVWF BPM_RESULT    
    BCF STATUS, C
    RLF TEMP_BIN, F     ; x4
    MOVF TEMP_BIN, W
    ADDWF BPM_RESULT, F ; x6

    ; Reiniciar para el próximo ciclo
    CLRF MS_COUNT_L
    CLRF MS_COUNT_H
    CLRF BEAT_COUNT
    
    ; --- LLAMAR A LA RUTINA BCD ---
    CALL DESCOMPONER_NUMERO

    BSF INTCON, GIE     ; Reactivar interrupciones
    GOTO LOOP
 
    END
