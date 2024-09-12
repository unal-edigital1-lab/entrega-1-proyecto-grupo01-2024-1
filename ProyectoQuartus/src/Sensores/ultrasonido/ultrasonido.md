# Sensor de Distancia: HC-SR04

El HC-SR04 es un sensor de distancia ultrasónido utilizado para medir distancias entre el sensor y un objeto con una precisión muy alta ya que s capaz de medir distancias a nivel de milimetros, centimetros y hasta los 4 metros de manera satisfactoria, esto lo hace enviando una señal de ultrasonido a través de un transductor, la onda golpea al objeto que tiene al frente y se refleja para ser detectada por el transductor receptor, se mide el tiempo de la onda y se calcula la distancia a la que se encuentra el objeto.

## Descripción de hardware

El ultrasonido cuenta con 4 pines (VCC, GND, ECHO, TRIG) cada uno cumple su respectiva función en el desempeño del dispositivo.

VCC corresponde a la alimentación del dispositivo que debe ser de 5V DC y consecuentemente el GND se debe conectar a tierra, el HC-SR04 no cuenta con ningún led ni indicador que pueda dar certeza de que se encuentra en operación lo cual dificulta un poco el trabajo a la hora se usar el dispositivo.

# ECHO

el ECHO es un output del dispositivo es decir es un input en el dispositivo de control que se esté manejando, por este canal es por el que se va a enviar la señal que refleja el objeto, y con esta es con la que se debe calcular la distancia y se hace con la siguiente ecuación:

$$
\text{distancia} = \frac{\text{velocidad del sonido} X \text{duración de onda}}{2}
$$



## Simulación

## Implementación
