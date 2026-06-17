# TP-FINAL-ED2_Pulsometro-digital
Asignatura: Electrónica Digital II - Universidad Nacional de Córdoba


Integrantes: Cabrera Valentina, Lavena Santiago, Pagani Catalina

Profesor: Marcos Blasco

# 1.Descripcion del proyecto
El proyecto consiste en el desarrolo de un pulsometro usando un microcontrolador (PIC 16F887).
El sistema adquiere la señal a traves de un sensor de pulso cardíaco (HW827), procesa la informacion y calcula la frecuencia cardiaca en Latidos Por Minuto (BPM)
El resultado se muestra en los displays multiplexados. Ademas se genera una indicacion sonora cada vez que se detecta un latido, mediante un buzzer

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
 Hardware e Interconexión
Diagrama de Bloques realizado en KiCad

Esquemático del Circuito: 

<img width="1417" height="827" alt="image" src="https://github.com/user-attachments/assets/e5cb7dc0-813c-4cf3-a3ca-f22e26fcb2bf" />

Descripción del Circuito y Consideraciones de Diseño: 
El sistema está basado en un microcontrolador PIC16F887 alimentado a 5 V. La señal proveniente del sensor óptico infrarrojo es adquirida a través del canal analógico AN0 y convertida a formato digital mediante el módulo ADC interno de 10 bits. El firmware procesa continuamente las muestras para detectar los cruces por umbral asociados a cada latido cardíaco y calcular la frecuencia cardíaca en pulsaciones por minuto (BPM).
Como consideraciones de diseño, se utilizó una resistencia de pull-up en el pin MCLR para garantizar un arranque confiable del microcontrolador y un cristal externo de 4 MHz para proporcionar una referencia de reloj estable. La multiplexación de los displays se implementó mediante interrupciones periódicas del Timer0, permitiendo una visualización continua sin afectar la adquisición de datos del sensor. El procesamiento de la señal incluye un umbral de detección y un período refractario por software para reducir falsas detecciones causadas por ruido o fluctuaciones de la señal óptica.

💻 Arquitectura de Software (Firmware)

La programación y validación se realizaron mediante simulación en Proteus y en KiCad.
Diagrama de Flujo o Máquina de Estados: [Inserte aquí la imagen del diagrama que explica el lazo principal o el comportamiento del sistema] ![Diagrama de Flujo / Máquina de Estados](docs/diagrama_software.png)

# 3. Especificaciones Eléctricas, Alimentación y Entorno

Parámetros de Alimentación y Consumo

Tensión de operación del sistema: 5V 

Método de alimentación: Alimentacion por USB

Consumo estimado o medido: * En modo activo (máxima carga, relés/motores encendidos):XX mA

En modo bajo consumo (si aplica):XX uA ?????????????????

Herramientas de software: MPLAB X IDE v5.35 y compilador XC8

Hardware de Programación/Depuración: Bootloader

Configuración de Bits (Fusibles Críticos):
<img width="890" height="128" alt="image" src="https://github.com/user-attachments/assets/841cf87b-bb6b-43e2-9882-74494807fd3d" />

Oscilador: Cristal externo de 4MHz

Temporizador de vigilancia (WDT): Watchdog timer OFF

Borrado maestro (MCLRE): ENCENDIDO

Periféricos Internos Utilizados: [Ej: Timer0, ADC, EUSART, PWM].

Gestión de Interrupciones:

La identificación de la fuente se realiza mediante polling de las banderas correspondientes dentro de la ISR.

En primer lugar se evalúa la bandera del Timer0 (T0IF), ya que este temporizador es responsable de mantener la base de tiempos del sistema, actualizar los contadores de tiempo y realizar el multiplexado de los displays. Posteriormente se verifica la bandera de finalización de conversión ADC (ADIF), utilizada para procesar las muestras provenientes del sensor cardíaco.

# 4. Proceso de Integración y Desarrollo (Común)

Etapa 1 (Validación inicial)
Configuración del oscilador externo de 4 MHz, prueba de funcionamiento básico del PIC16F887 y validación del multiplexado de los displays de siete segmentos.

Etapa 2 (Adquisición y Comunicación)
Implementación y prueba del conversor ADC para la adquisición de la señal del sensor HW827. Configuración de la interfaz UART para transmisión de datos hacia una terminal serial.

Etapa 3 (Integración lógica)
Desarrollo del algoritmo de detección de latidos mediante umbral y período refractario. Implementación del cálculo de frecuencia cardíaca en BPM.

Etapa 4 (Sistema completo)
Integración del sensor, displays, buzzer y UART. Ajuste del umbral de detección, validación funcional del sistema completo y pruebas mediante simulación en Proteus.

#  5. Ensayos, Pruebas y Resultados (Común)

Pruebas Funcionales Realizadas:
Se probo el funcionamiento del sensor para poder configurar el umbral del codigo.
<img width="899" height="893" alt="1" src="https://github.com/user-attachments/assets/6b0be53d-9dfe-4b87-ab6b-ac4876f53a2a" />
<img width="899" height="869" alt="2" src="https://github.com/user-attachments/assets/b2e7cdbe-91ae-4591-b343-554c3bdf3f11" />

Se valido la conexion entre la interfaz realizada y ???
<img width="1208" height="744" alt="3" src="https://github.com/user-attachments/assets/b6491a22-2c63-409e-b307-af4fee8f83b8" />


Evidencia Fotográfica y Gráficos: * Capturas de instrumental: [Insertar capturas de Osciloscopio, Analizador Lógico o Terminal Serie]

Foto del Prototipo Real: [Insertar foto del hardware final cableado/armado en funcionamiento]

