# Entrega 1 del proyecto WP01 <!-- omit in toc -->

**INTEGRANTES**
- Miguel Fabian Duarte Diaz
- Santiago Marín Becerra
- Juan David Palacios Chavez
- María Alejandra Pérez Petro

**TABLA DE CONTENIDO**
- [1. Objetivo](#1-objetivo)
- [2. Especificación](#2-especificación)
  - [2.1  Botones Mínimos](#21--botones-mínimos)
  - [2.2 Sistema de Sensado](#22-sistema-de-sensado)
  - [2.3 Sistema de Visualización](#23-sistema-de-visualización)
  - [2.4 Lógica de estados](#24-lógica-de-estados)
- [3. Diagrama de caja negra/funcional](#3-diagrama-de-caja-negrafuncional)
  - [3.1 Diagrama de Caja Negra](#31-diagrama-de-caja-negra)
  - [3.2 Diagrama de Flujo](#32-diagrama-de-flujo)
  - [3.3 Diagrama de Moore](#33-diagrama-de-moore)
- [4. Propuesta Inicial de Arquitectura](#4-propuesta-inicial-de-arquitectura)
  - [4.1 Botones](#41-botones)
  - [4.2 Sensor de Movimiento](#42-sensor-de-movimiento)
  - [4.3  Sensor de Sonido y Buzzer](#43--sensor-de-sonido-y-buzzer)
  - [4.4 Matriz 8x8](#44-matriz-8x8)
  - [4.5 Pantalla LCD 16x2](#45-pantalla-lcd-16x2)

# 1. Objetivo
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción incorporando sensores, botones y sistemas de visualización que permitan al usuario interactuar con la mascota virtual.

# 2. Especificación

## 2.1  Botones Mínimos
La interacción usuario-sistema se realizará mediante los siguientes cinco botones:

- **Reset:** Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
- **Test:** Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación.
- **Alimentar:** Permite alimentar a la mascota virtual. Cada pulsación aumenta un valor de "alimentación" en el sistema. Si la alimentación es insuficiente, la mascota virtual puede entrar en un estado de "hambre".
- **Jugar:** Permite jugar con la mascota virtual. Cada pulsación aumenta un valor de "Felicidad" en el sistema. Si la diversión es insuficiente, la mascota virtual puede entrar en un estado de "Tristeza".
- **Cambiar display 16x2:** Permite circular las estadísticas a mostrar en el display LCD 16x2. Cada pulsación cicla entre unas estadísticas a mostrar dando así al usuario el control para ver distintas estadísticas de la mascota virtual.

## 2.2 Sistema de Sensado
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporará el sensor de movimiento MPU5050. Con este sensor el Tamagotchi podrá ejercitarse. La mascota tendrá tres formas de ejercitarse:
- **Caminar:** El usuario debe desplazarse (movimiento lineal en x) para darle la sensación de caminar al Tamagochi.
- **Levantar pesas:** El usuario debe levantar y bajar sus brazos (movimiento lineal en y) para darle la sensación de levantar pesas al Tamagochi.
- **Estirar:** El usaurio debe girar (movimiento angular en z) para darle la sensación de estirarse al Tamagochi.
 

Además se utilizará el sensor de sonido analógico y digital KY038. Se utilizará la salida digital del sensor, permitiendo que al detectar que se "habla" con el Tamagotchi, este "responda" con un buzzer integrando sonidos de distintas frecuencias. Los sonidos variarán dependiendo del estado de la mascota:

- **Feliz:** Cuando la mascota está feliz, el buzzer emitirá un sonido de alta frecuencia.
- **Triste:** Cuando la mascota está triste, el buzzer emitirá un sonido de baja frecuencia.
- **Hambriento:** Cuando la mascota tiene hambre, el buzzer emitirá un sonido de frecuencia media.
  
## 2.3 Sistema de Visualización

Se integrarán dos pantallas para la visualización de elementos del Tamagotchi. La primera es un display de 8x8 que se utilizará para mostrar la mascota virtual y sus distintos estados, proporcionando una representación visual de la mascota y sus emociones. La segunda es una pantalla LCD 16x2 que permitirá la visualización de los valores numéricos de las estadísticas de la mascota virtual. Esta pantalla mostrará información detallada sobre la salud, la felicidad, el hambre y otros aspectos de la mascota, permitiendo al usuario entender mejor las necesidades de su mascota virtual y responder en consecuencia.

 ## 2.4 Lógica de estados
El Tamagotchi tendrá una lógica de estados interna que reflejará las diversas necesidades y condiciones de la mascota. Los ocho estados principales son los siguientes:

| Estado     | Binario | Decimal | Descripción                                       |
| ---------- | ------- | ------ | -------------------------------------------------- |
| Ideal  | 000     | 0      | Estado inicial tras el reinicio. Estadisticas optimas. |
| Neutro  | 001     | 1      | La mascota está en buen estado. |
| Hambriento | 010     | 2      | La mascota necesita ser alimentada.   |
| Tristeza   | 011     | 3      | La mascota se encuentra en mal estado. |
| Agotado   | 100     | 4      | La mascota necesita Descansar. |
| Aburrido  | 101   |   5      | La mascota necesita jugar. |
| Enfermo    | 110     | 6      | La mascota no está saludable. |
|Muerto | 111 | 7 | La mascota murió.

Estos estados fluctuarán en base a las estadísticas individuales de cada atributo de la mascota, proporcionando una experiencia dinámica e interactiva para el usuario. Esta relación entre los atributos de la mascota y sus estados se puede visualizar en la siguiente imagen.

![Estados](./Img/Estados.jpeg)

Con estos estados, se pueden visualizar en la pantalla diversas expresiones de la mascota. Estas expresiones permiten al usuario comprender fácilmente el estado actual de la mascota. Las siguientes ilustraciones proporcionan una representación visual de cada estado, facilitando así la interacción del usuario con la mascota virtual.

![Caras](./Img/Caras.jpeg)

#  3. Diagrama de caja negra/funcional

## 3.1 Diagrama de Caja Negra

## 3.2 Diagrama de Flujo

El siguiente diagrama de flujo proporciona una visión detallada de la funcionalidad integral del sistema Tamagotchi. Ilustra la interacción entre los diversos componentes del sistema, así como el procesamiento de las entradas y salidas. Este diagrama es esencial para entender cómo cada componente del sistema contribuye al funcionamiento general del Tamagotchi.

![DiagramaFuncional](./Img/DiagramaFuncional.jpeg)

## 3.3 Diagrama de Moore

El siguiente diagrama de Moore es una representación gráfica de la lógica de estados del Tamagotchi. Este diagrama detalla cómo el estado del Tamagotchi cambia en respuesta a los atributos de la mascota y las acciones del usuario. Es una herramienta valiosa para entender cómo las acciones del usuario y los atributos de la mascota influyen en el estado del Tamagotchi.

![DiagramaMoore](./Img/DiagramaMoore.jpeg)




#  4. Propuesta Inicial de Arquitectura
 
## 4.1 Botones

Se propone utilizar pulsadores como interfaz de interacción con los botones del Tamagotchi. Estos pulsadores estarán conectados a entradas del FPGA, permitiendo al sistema detectar las pulsaciones del usuario. Se utilizarán resistencias de pull-up para garantizar un estado definido en las entradas cuando no se estén pulsando los botones.

## 4.2 Sensor de Movimiento

El sensor de movimiento MPU6050 se conectará al FPGA mediante la interfaz I2C. El FPGA leerá los datos del sensor, incluyendo la aceleración y el giroscopio, para determinar el movimiento del usuario. Estos datos se procesarán para determinar si el usuario está caminando, levantando pesas o estirando, en base a los patrones de movimiento detectados. Por lo que, en la descripción de hardware con vHDL se implementaran dos modulos uno para la comunicacion I2C y otro para el procesamiento de datos del giroscopio. Los dos módulos VHDL se integrarán en un sistema completo que gestione la comunicación con el sensor MPU6050, procese sus datos y determine el movimiento del usuario. La salida del módulo de procesamiento de datos se utilizará para actualizar el estado del Tamagotchi.

## 4.3  Sensor de Sonido y Buzzer
Para integrar el sensor de sonido KY038 y el buzzer en el sistema Tamagotchi, se propone un módulo VHDL que gestione la interacción con estos componentes. Este módulo será responsable de:

1. Lectura del sensor de sonido: Leer la señal digital del sensor KY038 para detectar la presencia o ausencia de sonido.

2. Control del buzzer: Generar una señal de onda cuadrada de la frecuencia adecuada en función del estado de la mascota virtual (feliz, triste o hambriento). Asi como, controlar la duración del sonido emitido por el buzzer.
   
## 4.4 Matriz 8x8
Para mostrar el Tamagotchi en una matriz LED 8x8, se propone un módulo VHDL que gestione la comunicación con la matriz mediante protocolo SPI y la visualización de las diferentes caras del tamagotchi.

## 4.5 Pantalla LCD 16x2
Se utilizará una pantalla LCD 16x2 para mostrar las estadísticas de la mascota virtual. La pantalla se conectará al FPGA mediante protocolo SPI. El FPGA enviará los datos de las estadísticas a la pantalla para que se muestren en el formato correspondiente.