
# Lab 5. Configuración de GPIO.

En este README se describe el material para la desarrollar practica 5 de la materia de Microcontroladores de la UAM Cuajimalpa trimestre 23I.

## Funcionamiento:

El siguiente programa sirve para configurar un microcontrolador embebido en la placa STM32F103C8T6 "bluepill" para que realice lo siguiente: 

El experimento consiste en generar un programa que controle el funcionamiento de una protoboard que debera tener conectados 5 Leds que se irán encendiendo dependiendo de 2 push buttons, el programa tiene 3 funcionalidades, un boton que incrementa la cuenta en una unidad en un rango de 0 hasta 31, un boton que decrementa la cuenta en 1 y si se presionan los 2 a la vez se reinicia el contador.

## Diagrama electronico:
Se debe seguir el siguiente diagrama para conectar correctamente la protoboard

![Logo](https://i.ibb.co/Zztsrt2/Diagrama-E.jpg)

## Procedimiento de compilación:

El experimento necesita de 3 archivos nombrados de la siguiente manera:

- leds.s 
Que es donde se encuentra el programa principal con la configuracion de toda la placa.
- gpio.inc
Que configura alias para facilitar la programación. 
- nvic.inc 

El archivo leds.s tiene los includes de gpio.inc y nvic.inc así que solo se debe compilar con las siguientes instrucciones:

    st-flash read dummy.bin 0 0xFFFF

Para comprobar si puede leerse la bluepill

    arm-as archivo.s -o archivo.o

Para generar el codigo objeto

    arm-objcopy -O binary archivo.o archivo.bin 

Para generar el archivo binario que se cargará en la bluepill

    st-flash write ‘archivo.bin’  0x8000000

Para grabar en la bluepill.


Una vez realizados estos pasos el proyecto debe funcionar como se describe arriba.

## Marcos de las funciones de leds.s




