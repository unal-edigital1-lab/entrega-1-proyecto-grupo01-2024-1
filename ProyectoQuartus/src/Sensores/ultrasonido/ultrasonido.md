# Sensor de Distancia: HC-SR04

El HC-SR04 es un sensor de distancia ultrasónido utilizado para medir distancias entre el sensor y un objeto con una precisión muy alta ya que s capaz de medir distancias a nivel de milimetros, centimetros y hasta los 4 metros de manera satisfactoria, esto lo hace enviando una señal de ultrasonido a través de un transductor, la onda golpea al objeto que tiene al frente y se refleja para ser detectada por el transductor receptor, se mide el tiempo de la onda y se calcula la distancia a la que se encuentra el objeto.

## Descripción de hardware

El ultrasonido cuenta con 4 pines (VCC, GND, ECHO, TRIG) cada uno cumple su respectiva función en el desempeño del dispositivo.

VCC corresponde a la alimentación del dispositivo que debe ser de 5V DC y consecuentemente el GND se debe conectar a tierra, el HC-SR04 no cuenta con ningún led ni indicador que pueda dar certeza de que se encuentra en operación lo cual dificulta un poco el trabajo a la hora se usar el dispositivo.

### ECHO

el ECHO es un output del dispositivo es decir es un input en el dispositivo de control que se esté manejando, por este canal es por el que se va a enviar la señal que refleja el objeto, y con esta es con la que se debe calcular la distancia y se hace con la siguiente ecuación:

$$
\text{distancia} = \frac{\text{Vel Sonido X}  \text{  ECHo}}{2}
$$

Para el codigo implementado se calcula con la velocidad del sonido en cm/s que sería igual a 3400 y ECHO s el tiempo que dura el ECHO activado, y esto se calcular con el periodo de la frecuencia a la cual trabaja la FPGA (50MHz) multiplicandolo por el numero de periodos que abarca el ECHO asi:

$$
\text{ECHO} = 2 \times 10^{-8} \times \text{número de ciclos}
$$

Todo este proceso de medida se realiza en la maquina de estados en el estado llamado "MEASURE_ECHO"

pero para que el Ultrasonido envie la onda, se debe hacer un proceso previo que se explica a continuación

###TRIG

Este pin es un Input del HC-SR04 es decir un Output de la unidad de control, este pin es el encargado de manejar el Ultrasonido ya que el ultrasonido solo enviará la onda ultrasonica solo si recibe antes mediante el pin del trigger una señal positiva de exactamente 10\mu S y solo enviará una onda ultrasonica cada vez que reciba esta señal antes mencionada, es decir que el codigo debe enviar la señal de trigger de 10\mu S repetidas veces para medir constantemente la distancia, así como es requerido en nuestra aplicación.

este proceso de enviar el trigger se hace en la maquina de estados en el estado "START" con un contador que cuenta 499 ciclos de la señal de CLOCK que es de 50MHz

## Simulación

## Implementación
