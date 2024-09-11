`include "ultrasonido.v"
`timescale 1ns/1ns

module tb_ultrasonido;

    // Señales de prueba
    reg clk;
    reg reset_n;
    reg echo;
    reg boton;
    wire led;
    wire trigger;

    // Instanciar el módulo ultrasonido
    ultrasonido uut (
        .clk(clk),
        .reset_n(reset_n),
        .echo(echo),
        .boton(boton),
        .led(led),
        .trigger(trigger)
    );

    // Generar señal de reloj con un bloque always
    always begin
        #10 clk = ~clk; // Alternar el reloj cada 10 ns (50 MHz)
    end

    // Inicializar y ejecutar la prueba
    initial begin
        // Inicializar señales
        clk = 0;
        reset_n = 1;
        echo = 0;
        boton = 0;
        #5
        reset_n = 0;
        #10
        reset_n = 1;
        #10
        // Prueba con distancia que supera el umbral
        boton = 1;   // Activar el botón para empezar la medición
        #20;
        boton = 0;
        #100
        boton =1;

        // Simular una distancia que no supera el umbral (por ejemplo, 50 cm)
        #158000;
        echo = 1;    // Empezar a medir el eco
        #19925;        // Mantener el eco activo para simular 50 cm
        echo = 0;    // Terminar la señal de eco

        // Esperar un poco para que el módulo procese la distancia
        #500

        // Volver a inicializar las señales
        boton = 1;   // Activar el botón para empezar una nueva medición
        #20;
        //boton = 0;

        // Simular una distancia que no supera el umbral
        #480;
        echo = 1;    // Empezar a medir el eco
        #4925000;         // Mantener el eco activo
        echo = 0;    // Terminar la señal de eco

        // Esperar un poco para que el módulo procese la distancia
        #8000;
        // Finalizar simulación
        $finish;
    end

   initial begin
        $dumpfile("tb_ultrasonido.vcd");
        $dumpvars(0, tb_ultrasonido);
    end


endmodule
