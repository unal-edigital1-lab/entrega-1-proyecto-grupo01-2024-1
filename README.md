# Entrega 1 del proyecto WP01 <!-- omit in toc -->

**INTEGRANTES**
- Miguel Fabian Duarte Diaz
- Santiago Marín Becerra
- Juan David Palacios Chavez
- María Alejandra Pérez Petro

**TABLA DE CONTENIDO**
- [1. Objetivo](#1-objetivo)
- [2. Descripción General](#2-descripción-general)
  - [2.1  Botones Mínimos](#21--botones-mínimos)
  - [2.2 Sistema de Sensado](#22-sistema-de-sensado)
  - [2.3 Sistema de Visualización](#23-sistema-de-visualización)
- [3. Arquitectura del Sistema](#3-arquitectura-del-sistema)
  - [3.1 Diagrama de Caja Negra](#31-diagrama-de-caja-negra)
  - [3.2 Diagrama de Flujo](#32-diagrama-de-flujo)
  - [3.3 Diagrama de Moore](#33-diagrama-de-moore)
  - [3.4 Descripción de Componentes](#34-descripción-de-componentes)
    - [3.4.1 Botones](#341-botones)
    - [3.4.2  Sensor de Sonido y Buzzer](#342--sensor-de-sonido-y-buzzer)
    - [3.4.3 Sensor Ultrasónico HC-SR04](#343-sensor-ultrasónico-hc-sr04)
      - [Señales](#señales)
      - [Especificaciones](#especificaciones)
      - [Funcionamiento](#funcionamiento)
    - [3.4.5 Pantalla LCD 16x2](#345-pantalla-lcd-16x2)
- [4. Especificaciones Detalladas de Diseño](#4-especificaciones-detalladas-de-diseño)
  - [4.1 Modos de Operación](#41-modos-de-operación)
    - [4.1.1 Modo Test](#411-modo-test)
    - [4.1.2 Modo Normal](#412-modo-normal)
  - [4.2 Estados y Transiciones](#42-estados-y-transiciones)
    - [4.2.1 Estados](#421-estados)
    - [4.2.2 Transiciones](#422-transiciones)

# 1. Objetivo
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción, tales como sensores, botones y sistema de visualización, los cuales permitan al usuario interactuar con la mascota virtual.

# 2. Descripción General

## 2.1  Botones Mínimos
La interacción usuario-sistema se realizará mediante los siguientes cinco botones:

- **Reset:** Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
- **Test:** Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación.
- **Jugar:** Una pulsación activa el modo juego, el cual permite a la mascota aumentar su estadística de "Entertainment" en el sistema. 
- **Dormir:**  Una pulsación de este botón activa el modo dormir que permite a la mascota aumentar su estadística de "Energy".

## 2.2 Sistema de Sensado
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporará lo siguiente:

- **sensor de ultra sonido HC-SR04:** con este sensor el Tamagotchi podrá jse podrá alimentar. Si se coloca un objeto a 10 cm del sensor durante un segundo el indicador de comida debería aumentar en un punto.
  
- **sensor de sonido analógico y digital KY038:** se utilizará la salida digital del sensor, permitiendo que al detectar un ruido del usuario, el Tamagotchi se despierte.

- **buzzer:** el Tamagotchi podrá interactuar con el usuario mediante un buzzer manifestando diferentes sonidos dependiendo de como se esté sintiendo. Cada estado del Tamagotchi emitirá una cantidad de pulsos auditivos diferentes. 

## 2.3 Sistema de Visualización

Se empleará una pantalla **LCD 16x2** para la visualización del Tamagochi. En ella se mostrará lo siguiente:
 - Representación visual de la mascota y sus emociones mediante gestos/caras. 
- Los valores numéricos junto con íconos de las estadísticas de la mascota virtual.  (1) Hunger, (2) Entertainment, y (3) Energy. 

De esta forma, el usuario podrá entender mejor las necesidades de su mascota virtual y responder en consecuencia.


#  3. Arquitectura del Sistema

El siguiente esquema representa el diagrama de caja negra inicial del proyecto. 
![image](https://github.com/user-attachments/assets/c3068f6b-6304-464e-a084-2c3531af8472)


## 3.1 Diagrama de Caja Negra

Este diagrama presenta la arquitectura del Tamagotchi. Dado que el desarrollo es un proceso iterativo, es probable que ajustemos este modelo para adaptarlo mejor a las necesidades emergentes y a los hallazgos obtenidos durante las etapas de pruebas e integración.
![DiagramaFuncional](./figs/diagrama_arquitectura.png)

## 3.2 Diagrama de Flujo

El siguiente diagrama de flujo proporciona una visión detallada de la funcionalidad integral del sistema Tamagotchi. Ilustra la interacción entre los diversos componentes del sistema, así como el procesamiento de las entradas y salidas. Este diagrama es esencial para entender cómo cada componente del sistema contribuye al funcionamiento general del Tamagotchi.

![DiagramaFuncional](figs/DiagramaFlujo.png)

## 3.3 Diagrama de Moore

El siguiente diagrama de Moore es una representación gráfica de la lógica de estados del Tamagotchi. Este diagrama detalla cómo el estado del Tamagotchi cambia en respuesta a los indicadores de la mascota y las acciones del usuario. 

![DiagramaMoore](./figs/Diagrama_de_Moore_Tamagotchi.png)

## 3.4 Descripción de Componentes

### 3.4.1 Botones

Se propone utilizar pulsadores como interfaz de interacción con los botones del Tamagotchi. Estos pulsadores estarán conectados a entradas del FPGA, permitiendo al sistema detectar las pulsaciones del usuario. Además se hará una descripción de hardware para mitigar el rebote mecánico de los botones mediante el módulo anti-rebote.


### 3.4.2  Sensor de Sonido y Buzzer
Para integrar el sensor de sonido KY038 y el buzzer en el sistema Tamagotchi, se propone un módulo que gestione la interacción con estos componentes. Este módulo será responsable de:

1. Lectura del sensor de sonido (micrófono): Leer la señal digital del sensor KY038 para detectar la presencia o ausencia de sonido.

2. Control del buzzer: Generar una señal que permita "interactuar" con el Tamagotchi, la cual variará en frecuencia de acuerdo al estado de animo del mismo.
![Mic](./figs/Mic.jpg)

### 3.4.3 Sensor Ultrasónico HC-SR04

El HC-SR04 es un sensor de ultrasonido ampliamente utilizado para medir distancias. Funciona emitiendo un pulso de sonido ultrasonico y midiendo el tiempo que tarda en rebotar en un objeto y regresar al sensor.

![HC-S04](./figs/HC-SR04.jpg)

Toda la información del dispositivo respecto a su uso e implementación en el tamagotchi están en el siguiente enlace:

https://github.com/unal-edigital1-lab/entrega-1-proyecto-grupo01-2024-1/blob/main/Documentacion/ultrasonido.md
   
### 3.4.5 Pantalla LCD 16x2
Se utilizará una pantalla LCD 16x2 para mostrar la mascota virtual y los puntajes de las estadisticas. Para ello, se implementará un modulo de LCD controller que reciba el estado actual de la mascota y sus puntajes y se encargue de enviarle a la pantalla las señales correspondientes de rs, rw, enable y data para lograr la visualización deseada.
![LCD](./figs/LCD16x2.jpg) 


#  4. Especificaciones Detalladas de Diseño 

## 4.1 Modos de Operación

### 4.1.1 Modo Test

El modo test se activa al presionar por 5 segundos el botón de test, posteriormente el usuario debe presionar un numero de veces determinado en un intervalo de tiempo de 5 segundos dependiendo el numero de veces que se presione el tamagotchi satará al estado correspondiente, siendo: NEUTRAL (1), TIRED (2), SLEEP (3), HUNGRY (4), SAD (5), PLAYING (6), BORED (7), DEAD (8). Ya cuando se salta a ese estado el tamagotchi funcionará de manera normal a partir del estado en el que se encuentre, es decir que junto al estado se cambiaran los valores de los indicadores de "hunger", "entertaiment" y "energy" a unos determinados según el estado al que se salte.

### 4.1.2 Modo Normal

La funcionalidad regular del Tamagotchi es la siguiente:

* Recién se enciende la FPGA y se carga la descripción de hardware el Tamagotchi entra a su estado inicial e ideal llamado "IDLE". En este estado, el Tamagotchi tiene todos sus indicadores al máximo, es decir "hunger = 5", "entertainment = 5" y "energy=5". Este estado inicial se puede visualizar en pantalla mediante una carita feliz. 

* Posteriormente y con el avance del tiempo, los indicadores van  ir disminuyendo, el de "hunger" disminuirá una unidad cada 10 segundos, el de "entertaiment" se reducirá una unidad cada 20 segundos y el de "energy" se reducirá una unidad cada 30 segundos. Cuando ya no están todos en 5 el Tamagotchi entra a un estado denominado "NEUTRAL". Este estado se presenta siempre que todos los niveles sean mayores a 2.

* Desde el estado anterior, el Tamagotchi puede cambiar a tres estados los cuales se dan cuando uno de los tres indicadores (hunger, entertainment o energy) se encuentra en un nivel menor o igual a 2. Los estados a los que puede entrar son: 

  * "BORED" cuando el nivel de "entertainment" es el  único indicador que está por debajo de 2. Se muestra una cara representando aburrimiento.

  * "TIRED" cuando el nivel de "energy" es el  único indicador que está por debajo de 2. Se muestra una cara representando somnolencia.

  * "HUNGRY" cuando el nivel de "hunger" es el único indicador que está por debajo de 2. Se muestra una cara representando hambre.

* Dado el caso en que mas de un nivel esté por debajo de 2 se entra a un estado denominado "SAD" en el cual el Tamagotchi muestra una cara triste e indica a el usuario que debe hacer algo para aumentar el nivel de los indicadores.

* Si el Tamagotchi se encuentra en el estado "SAD" lo suficiente para que un indicador llegue a 0. Este pasa el estado denominado "DEAD", en el cual el Tamagotchi muere y donde ya el usuario no puede interactuar con el mismo. La única manera para sacar al Tamagotchi de este estado es mediante la pulsación del botón de reset el cual regresa al Tamagotchi al estado de "IDLE".

* Si en cualquiera de los estados se presiona el botón de "sleep" y además no está presionado el botón play y además el nivel de energía es diferente de 5, el Tamagotchi entra el estado "SLEEP". En este estado el Tamagotchi recupera con el avance del tiempo su indicador de "energy" lo cual lo puede ayudar a salir de los estados "SAD" o "TIRED" y que llegue a un estado "NEUTRAL" o incluso "IDLE" (solo si todos los indicadores están en 5.) Para salir del estado sleep hay tres opciones:

  * Se hace algún ruido lo suficiente mente alto para que el micrófono lo detecte y se despierte el Tamagotchi, se presiona el botón de "feed" para que el Tamagotchi se despierte a comer, o el si el Tamagotchi ya durmió lo suficiente y el nivel de "energy =5". Una vez despierto, el Tamagotchi entrará al estado correspondiente, dependiendo del nivel de sus tres indicadores.

* Si en cualquiera de los estados se presiona el botón de "play" y además no está presionado el botón "sleep y además el nivel de entertainment es diferente de 5, el Tamagotchi entra al estado "PLAYING". En este estado el Tamagotchi recupera con el avance del tiempo su indicador de "entertainment" lo cual lo puede ayudar a salir de los estados "SAD" o "BORED" y que llegue a un estado "NEUTRAL" o incluso "IDLE" (solo si todos los indicadores están en 5) Para salir del estado playing se puede hacer presionando el botón de comer. El Tamagotchi también sale del estado "PLAYING" si el nivel de entertainment llega a 5. 

Finalmente es importante recalcar que el nivel de "hunger" se controla con el ultrasonido el cual al acercarle un objeto a 10cm durante 2 segundos, como si se le mostrara unas galletas al Tamagotchi y así el nivel de alimentación sube, es importante retirar y volver a mostrarle el objeto para que vuelva a subir el indicador, si no, solo subirá una unidad. Esto puede ayudar a que el Tamagotchi salga del estado de "HUNGRY". Con esto se concluye la descripción del modo normal de operación del Tamagotchi.

## 4.2 Estados y Transiciones

### 4.2.1 Estados 
Como se describió de manera detallada en el apartado anterior, el Tamagotchi tendrá una lógica de estados interna que reflejará las diversas necesidades y condiciones de la mascota. Los ocho estados principales son los siguientes:

| Estado     | Binario | Decimal |Descripción                                       |
| ---------- | ------- | ------ | -------------------------------------------------- |
| IDLE  | 0000     | 0      | Estado inicial tras reset. Estadisticas optimas. |
| NEUTRAL  | 0001     | 1      | La mascota está en buen estado. |
| TIRED   | 0010     | 2      | La mascota necesita dormir para descansar. |
| SLEEP   | 0011     | 3      | La mascota está dormida. |
| HUNGRY | 0100     | 4      | La mascota necesita ser alimentada.  |
| SAD   | 0101     | 5      | La mascota se encuentra en mal estado.  Sus niveles de alimentación, energia y diversión están bajos. |
| PLAYING  | 0110   |   6      | La mascota está jugando. |
| BORED  | 0111   |   7      | La mascota necesita jugar. |
| DEAD | 1000 | 8 | La mascota murió.|

Estos estados fluctuarán en base a los niveles de cada indicador de la mascota, proporcionando una experiencia dinámica e interactiva para el usuario. Por cada estado se visualizará en la pantalla LCD 16x2 diversas expresiones de la mascota.

![image](https://github.com/user-attachments/assets/151ad1c7-ee20-4f9f-8323-a36a114eaed3)


### 4.2.2 Transiciones 

**Temporizadores**

Existen tres temporizadores los cuales controlan cada uno de los indicadores del Tamagotchi. Los temporizadores son los siguientes:
  * **Ener**: Es el temporizador de energía, el cual indica que cada 30 segundos disminuye en 1 el nivel de energía o si está dormido, cada 30 segundos que esté dormido, aumenta el nivel de energía en 1.
  
  * **Feed**: Es el temporizador de hambre, el cual indica que cada 10 segundos disminuye en 1 el nivel de alimentación.

  * **Entert**: Es el temporizador de diversión, el cual indica que cada 20 segundos disminuye en 1 el nivel de entretenimiento o si está jugando, cada 20 segundos que esté jugando, aumenta el nivel de entretenimiento en 1.
  
**Interacciones**

El usuario interactúa con el Tamagotchi mediante los botones "Feed", "Sleep", "Play", "Test" y "Reset" y mediante lo sensores de Audio y Ultrasonido.

* Con el botón "Feed" aumenta el indicador de alimentación en 1 punto de 5 posible.
* Con el botón "Sleep" el Tamagotchi entra al estado dormir en donde cada 30 segundos aumenta en 1 el indicador de energía.
* Con el una interacción sonorá detectada por el micrófono el Tamagotchi sale del estado "SLEEP".
* Con el botón "PLAY" el Tamagotchi entra en el estado de jugar en el cual revisa si se está activado un switch para poder aumentar cada 20 segundos el nivel de entertainment.
* Una pulsación del botón reset regresa el Tamagotchi al estado "IDLE" en donde todos los indicadores regresan a su nivel máximo de 5.
* El botón test, hace que el Tamagotchi entre al modo test y pueda saltar al estado deseado como fue descrito anteriormente.

**Sistema de Niveles o Puntos**

El sistema de niveles o puntos se ilustra en la siguiente figura:

![Indicadores](./figs/Indicadores.png)


