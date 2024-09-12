# Módulo: FSM_Central.v

Este módulo constituye el cerebro de todo el tamagotchi y es quien controla el ciclo de vida del tamagotchi, la forma en la que el usuario puede interactuar con el tamagotchi y la forma en la que el transcurrir del tiempo lo afecta.

En el código [FSM_Central.v](./ProyectoQuartus/src/UnidadDeControl/FSM_Central.v). pueden encontrar lo siguiente:

**Definición de Entradas y Salidas**

En el fragmento de código adjunto a continuación, se puede observar el nombre que se le da al módulo de la máquina central del tamagotchi, se puede apreciar que se definen las entradas y salidas. Como entradas a este módulo se tienen las entradas de los botones y de los sensores. Despues de varias interaciones de diseño se llegó a lo siguente:

- El botonFeed va a ser la entrada de la señal del Utrasonido la cual indica cuando se coloca comida frente al tamagotchi.
- El botonAwake va a ser la señal proveniente del micrófono que indica que se hizo un ruido para despertar el tamagotchi.
- El botón 

```verilog
module FSM_Central#(parameter COUNT_MAX = 25000 , Ener = 1500000000, Feed = 500000000, Entert= 1000000000, CONTUNI = 10000000000)( //30s , 10s , 20s
// Entradas
	input clk,
	input rst,
	input botonSleep,
	input botonAwake,
	input botonFeed,
	input botonPlay,
	input giro,
	input botonTest,
	input [3:0] BpulseTest,
// Salidas
	output reg [3:0] face,
	output reg [2:0] energy,
	output reg [2:0] hunger,
	output reg [2:0] entertainment,
	output wire [3:0] led4
	);
```