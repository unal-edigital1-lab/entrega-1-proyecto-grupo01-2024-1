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
- [4. Propuesta Inicial de Arquitectura](#4-propuesta-inicial-de-arquitectura)
  - [4.1 Botones](#41-botones)
  - [4.2 Sensor de Movimiento](#42-sensor-de-movimiento)
  - [4.3 Pantalla LCD](#43-pantalla-lcd)

# 1. Objetivo
Desarrollar un sistema de Tamagotchi en FPGA (Field-Programmable Gate Array) que simule el cuidado de una mascota virtual. El diseño incorporará una lógica de estados para reflejar las diversas necesidades y condiciones de la mascota, junto con mecanismos de interacción a través de un sensor de movimiento (MPU6050) y botones que permitan al usuario cuidar adecuadamente de ella.

# 2. Especificación

## 2.1  Botones Mínimos
La interacción usuario-sistema se realizará mediante los siguientes cuatro botones:

- **Reset:** Reestablece el Tamagotchi a un estado inicial conocido al mantener pulsado el botón durante al menos 5 segundos. Este estado inicial simula el despertar de la mascota con salud óptima.
- **Test:** Activa el modo de prueba al mantener pulsado por al menos 5 segundos, permitiendo al usuario navegar entre los diferentes estados del Tamagotchi con cada pulsación.
- **Alimentar:** Permite alimentar a la mascota virtual. Cada pulsación de 5 segundos de duración aumenta un valor de "alimentación" en el sistema. Si la alimentación es insuficiente, la mascota virtual puede entrar en un estado de "hambre".
- **Jugar:** Permite jugar con la mascota virtual. Cada pulsación  de 5 segundos de duración aumenta un valor de "Felicidad" en el sistema. Si la diversión es insuficiente, la mascota virtual puede entrar en un estado de "Tristeza".

## 2.2 Sistema de Sensado
Para integrar al Tamagotchi con el entorno real y enriquecer la experiencia de interacción, se incorporará el sensor de movimiento MPU5050. Con este sensor el Tamagotchi podrá ejercitarse. La mascota tendrá tres formas de ejercitarse:
- **Caminar:** El usuario debe desplazarse (movimiento lineal en x) para darle la sensación de caminar al Tamagochi.
- **Levantar pesas:** El usuario debe levantar y bajar sus brazos (movimiento lineal en y) para darle la sensación de levantar pesas al Tamagochi.
- **Estirar:** El usaurio debe girar (movimiento angular en z) para darle la sensación de estirarse al Tamagochi.
 
Al ejercitarse el Tamagochi obtiene puntos de ejercicio que aportan a su salud. Si el ejercicio es insuficiente, la mascota virtual puede entrar en un estado de "inactividad".
  
## 2.3 Sistema de Visualización

La interfaz de usuario del Tamagotchi se mostrará en una pantalla LCD **CORREGIR/ESPECIFICAR AQUI**. La pantalla mostrará lo siguiente:
- Estado actual de la mascota: despierta, hambrienta, triste, inactiva, enferma, saludable.
- Niveles de alimentación, diversión, ejercicio, energia y salud: Indicadores numéricos que representen los niveles actuales de estos parámetros mediante un puntaje.

 ## 2.4 Lógica de estados
El Tamagotchi tendrá una lógica de estados interna que reflejará las diversas necesidades y condiciones de la mascota. Los seis estados principales son los siguientes:

| Estado     | Binario | Decimal | Descripción                                                                                    |
| ---------- | ------- | ------ | ---------------------------------------------------------------------------------------------- |
| Despierto  | 000     | 0      | Estado inicial tras el reinicio. Simula el despertar de la mascota con salud óptima.                               |
| Saludable  | 001     | 1      | La mascota está en buen estado.                                                                |
| Hambriento | 010     | 2      | La mascota necesita ser alimentada.                                                            |
| Tristeza   | 011     | 3      | La mascota necesita jugar.                                                                     |
| Inactivo   | 100     | 4      | La mascota necesita ejercitarse.                                                               |
| Enfermo    | 101     | 5      | La mascota no está saludable, es decir, sufre por hambre, falta de ejercicio y/o juego. |


#  3. Diagrama de caja negra/funcional


#  4. Propuesta Inicial de Arquitectura
 

## 4.1 Botones

## 4.2 Sensor de Movimiento

## 4.3 Pantalla LCD