# TP-FINAL-ED2_Pulsometro-digital
Asignatura: Electrónica Digital II - Universidad Nacional de Córdoba


Integrantes: Cabrera Valentina, Lavena Santiago, Pagani Catalina

Profesor: Marcos Blasco

# 1.Descripcion del proyecto
El proyecto consiste en el desarrolo de un pulsometro usando un microcontrolador (PIC 16F887).
El sistema adquiere la señal a traves de un sensor de pulso cardíaco (HW827), procesa la informacion y calcula la frecuencia cardiaca en Latidos Por Minuto (BPM)
El resultado se muestra en los displays multiplexados. Ademas se genera una indicacion sonora cada vez que se detecta un latido, mediante un buzzer  AGREGAR INTERFAZ

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

Esquemático del Circuito: 

<img width="1417" height="827" alt="image" src="https://github.com/user-attachments/assets/e5cb7dc0-813c-4cf3-a3ca-f22e26fcb2bf" />

Descripción del Circuito y Consideraciones de Diseño: Breve explicación de las etapas (ej: acoplamiento de señales, protecciones inductivas, filtrados, etc.).

💻 Arquitectura de Software (Firmware)
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

Gestión de Interrupciones: Al contar con un único vector de interrupción, expliquen la prioridad por software ( polling ) en la ISR: ¿Qué bandera ( flag) evalúan primero y por qué?

# 4. Proceso de Integración y Desarrollo (Común)
Etapa 1 (Validación inicial): [Ej: Configuración del oscilador/reloj y parpadeo de LED de estado].

Etapa 2 (Adquisición/Comunicación): [Ej: Implementación del ADC y envío de tramas crudas por UART].

Etapa 3 (Integración lógica): [Ej: Procesamiento de datos, lógica de control o montado sobre el RTOS].

Etapa 4 (Sistema Completo): [Ej: Acople de actuadores finales, calibración y pruebas de estrés].

#  5. Ensayos, Pruebas y Resultados (Común)

Pruebas Funcionales Realizadas:
Se probo el funcionamiento del sensor para poder configurar el umbral del codigo.
<img width="899" height="893" alt="1" src="https://github.com/user-attachments/assets/6b0be53d-9dfe-4b87-ab6b-ac4876f53a2a" />
<img width="899" height="869" alt="2" src="https://github.com/user-attachments/assets/b2e7cdbe-91ae-4591-b343-554c3bdf3f11" />

Se valido la conexion entre la interfaz realizada y ???
<img width="1208" height="744" alt="3" src="https://github.com/user-attachments/assets/b6491a22-2c63-409e-b307-af4fee8f83b8" />


Evidencia Fotográfica y Gráficos: * Capturas de instrumental: [Insertar capturas de Osciloscopio, Analizador Lógico o Terminal Serie]

Foto del Prototipo Real: [Insertar foto del hardware final cableado/armado en funcionamiento]

