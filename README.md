# TP-FINAL-ED2_Pulsometro-digital
Asignatura: Electrónica Digital II - Universidad Nacional de Córdoba
Integrantes:Cabrera Valentina, Lavena Santiago, Pagani Catalina

Nombre Apellido Profesor: Marcos Blasco

# 1.Descripcion del proyecto
El proyecto consiste en el desarrolo de un pulsometro usando un microcontrolador PIC 16F887.
El sistema adquiere la señal a traves de un sensor infrarrojo, procesa la informacion y calcula la frecuencia cardiaca en Latidos Por Minuto (BPM)
El resultado se muestra en los displays multiplexados.Ademas se genera una indicacion sonora cada vez que se detecta un latido, mediante un buzzer  AGREGAR INTERFAZ

# 2.Alcances del proyecto  
Este sistema es capaz de: Utilizar interrupciones para temporización y adquisición periódica,transmitir información mediante comunicación UART,generar una señal sonora utilizando un buzzer al detectar un latido,adquirir señales utilizando el conversor Analógico-Digital (ADC) interno del PIC16F887 y calcular la frecuencia cardíaca en BPM.

El sistema no incluye: Almacenamiento permanente de datos,conectividad inalámbrica (Bluetooth o WiFi),registro histórico de mediciones o validación clínica del dispositivo.

# Lineas Futuras
Diseño e implementación de una placa PCB.
Implementación de filtros digitales para mejorar la calidad de la señal.
Incorporación de una pantalla.
Desarrollo de una aplicación de visualización en Python.
Alimentación mediante batería.

# 2. Arquitectura del Sistema: Hardware y Software

Aca va el diagrama de la simulacion pero en kicad 


 Hardware e Interconexión
Diagrama de Bloques: [Insertar imagen o enlace al diagrama de bloques del hardware]
Esquemático del Circuito: [Inserte aquí la captura de imagen/render del esquemático completo desarrollado en KiCad/Altium] ![Esquemático Completo](hardware/esquematico.png)
Descripción del Circuito y Consideraciones de Diseño: Breve explicación de las etapas (ej: acoplamiento de señales, protecciones inductivas, filtrados, etc.).
💻 Arquitectura de Software (Firmware)
Diagrama de Flujo o Máquina de Estados: [Inserte aquí la imagen del diagrama que explica el lazo principal o el comportamiento del sistema] ![Diagrama de Flujo / Máquina de Estados](docs/diagrama_software.png)

# 3. Especificaciones Eléctricas, Alimentación y Entorno

Parámetros de Alimentación y Consumo (Común a ambas materias)
Tensión de operación del sistema: [Ej: 5V / 3.3V]
Método de alimentación: [Ej: Fuente externa de 12V con regulador lineal LM7805 / Alimentación por USB]
Consumo estimado o medido: * En modo activo (máxima carga, relés/motores encendidos):XX mA
En modo bajo consumo (si aplica):XX uA
📌 [OPCIÓN A: Solo para alumnos de Electrónica Digital II (PIC16F887)]
Herramientas de software: MPLAB X IDE [vX.XX] y compilador XC8 [vX.XX].
Hardware de Programación/Depuración: [Ej: PICkit 3, PICkit 4].
Configuración de Bits (Fusibles Críticos):
Oscilador: [Ej: HS (Cristal externo de 20MHz) / INTRC (Interno 4MHz)]
Temporizador de vigilancia (WDT): [Ej: ON/OFF]
Borrado maestro (MCLRE): [Ej: ENCENDIDO (Pin externo) / APAGADO (E/S digital)]
Periféricos Internos Utilizados: [Ej: Timer0, ADC, EUSART, PWM].
Gestión de Interrupciones: Al contar con un único vector de interrupción, expliquen la prioridad por software ( polling ) en la ISR: ¿Qué bandera ( flag) evalúan primero y por qué?

# 4. Proceso de Integración y Desarrollo (Común)
Describen cronológicamente cómo fueron sumando y testeando las diferentes partes del proyecto (enfoque modular de ingeniería).

Etapa 1 (Validación inicial): [Ej: Configuración del oscilador/reloj y parpadeo de LED de estado].
Etapa 2 (Adquisición/Comunicación): [Ej: Implementación del ADC y envío de tramas crudas por UART].
Etapa 3 (Integración lógica): [Ej: Procesamiento de datos, lógica de control o montado sobre el RTOS].
Etapa 4 (Sistema Completo): [Ej: Acople de actuadores finales, calibración y pruebas de estrés].

#  5. Ensayos, Pruebas y Resultados (Común)
Demuestren con datos empíricos que el sistema funciona correctamente. Es obligatorio incluir registro visual .

Pruebas Funcionales Realizadas: Detallen los ensayos (Ej: "Se inyectó una señal controlada para medir la precisión del ADC...").
Evidencia Fotográfica y Gráficos: * Capturas de instrumental: [Insertar capturas de Osciloscopio, Analizador Lógico o Terminal Serie]
Foto del Prototipo Real: [Insertar foto del hardware final cableado/armado en funcionamiento]

