/* This program turns on and off 5 leds embedded in a protoboard through. The leds are 
 * connected to the following pins: PA0, PA1, PA2, PA3, PA4. This pins works as a GPIO,
 * then they must be configured at assembly level, through the following registers:
 * 1) RCC register,
 * 2) GPIOC_CRL register, 
 * 3) GPIOC_CRH register, and
 * 4) GPIOC_ODR register.
 * 
 * Author: Brandon Chavez Salaverria.
 */

.include "gpio.inc" @ Includes definitions from gpio.inc file

.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"

addition:
        # Prologue
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp, #0
        str     r0, [r7, #4] @ backs up counter argument
        # Function body
        ldr     r0, [r7, #4] @ r0 <- counter
        adds    r0, r0, #1 
        str     r0, [r7, #4] @ counter++;
        ldr     r0, [r7, #4]
        mov     r1, #31 @ if counter < 31
        cmp     r0, r1
        ble     .ADDIT1
        bl      reset @ counter = 0;
        str     r0, [r7, #4] 

.ADDIT1:
        ldr     r0, [r7, #4]
        # Epilogue
        adds    r7, r7, #8
        mov     sp, r7
        pop     {r7, lr}
        bx      lr

subtraction:
        # Prologue
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp, #0
        str     r0, [r7, #4] @ backs up counter argument
        # Function body
        ldr     r0, [r7, #4] @ r0 <- counter
        subs    r0, r0, #1
        str     r0, [r7, #4] @ counter--;
        ldr     r0, [r7, #4]
        mov     r1, #0 @ if counter < 0
        cmp     r0, r1
        bge     .SUBTR1
        bl      reset @ counter = 0;
        str     r0, [r7, #4] 

.SUBTR1:
        ldr     r0, [r7, #4]
        # Epilogue
        adds    r7, r7, #8
        mov     sp, r7
        pop     {r7, lr}
        bx      lr

reset:
        # Prologue
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp, #0
        str     r0, [r7, #4] @ backs up counter
        # Function body
        mov     r0, #0
        str     r0, [r7, #4] @ resets counter to 0
        ldr     r0, [r7, #4]
        # Epilogue
        adds    r7, r7, #8
        mov     sp, r7
        pop     {r7, lr}
        bx      lr

delay:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Function body
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
        # for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
        # for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        # Epilogue
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr

read_button_input:
        @ Prologo
	push	{r7} @ respalda r7
	sub 	sp, sp, #12 @ respalda un marco de 16 bytes
	add	r7, sp, #0 @ actualiza r7
        @ Lectura de boton(es)
	str 	r0, [r7] @ respalda el argumento recibido desde loop (que boton se presiona o ambos)
        ldr     r1, =GPIOA_IDR @ carga la direccion base de GPIOA_IDR a r1 
        ldr     r1, [r1] @ carga el contenido de GPIOA_IDR a r1 (estado de los botones)
	ldr 	r0, [r7] @ carga en r0 el valor del argumento recibido desde loop (que boton se presiona o ambos)
	and	r1, r1, r0 @ aplica una and entre el estado actual de GPIOA_IDR y el argumento recibido desde loop
	cmp	r1, r0 
	beq	L10 @ si son iguales sale de la funcion junto con el valor respectivo (leido)
        @ si no se presiona nada devuelve 0
	mov	r0, #0 @ return 0
L10:
        @ Epilogo
	adds 	r7, r7, #12
	mov	sp, r7
	pop 	{r7}
	bx	lr




# Esta funcion realiza el debouncing si se presiona un boton o ambos
is_button_pressed:
        @ Prologo
	push 	{r7, lr} @ respalda r7 y lr
	sub	sp, sp, #24 @ respalda un marco de 32 bytes
	add	r7, sp, #0 @ actualiza r7
        
	str 	r0, [r7, #4] @ respalda el argumento recibido desde loop
@ read_button_input
@ if (button is not pressed)
@     return false
	ldr	r0, [r7, #4] @ carga el argumento recibido desde loop
	bl	read_button_input
	ldr 	r3, [r7, #4] @ carga el valor recibido desde read_button_input
	cmp	r0, r3 
	beq	L5 @ si hay al menos un boton presionado realiza el debouncing 
        @ si no se presiona ningun boton (el valor recibido desde read_button_input es 0) sale de la funcion y devuelve 0 (false)
        @ Epilogo
	mov	r0, #0 @ return 0
	adds	r7, r7, #24
	mov	sp, r7 
	pop 	{r7, lr}
	bx	lr
L1:
@ counter = 0
	mov	r3, #0 @ counter = 0
	str	r3, [r7, #8] @ guarda el valor de counter dentro del marco
@ for (int i = 0, i < 10, i++) 
	mov     r3, #0 @ i = 0;
        str     r3, [r7, #12] @ guarda el valor de i dentro del marco
        b       L6
L5:     
@ wait 5 ms
	mov 	r0, #50 @ 5ms a delay (wait_ms)
	bl   	delay
@ read button input
@ if (button is not pressed)
@    counter = 0
	ldr	r0, [r7, #4] @ carga el argumento recibido desde loop
	bl	read_button_input
	ldr 	r3, [r7, #4] @ carga el valor recibido desde read_button_input
	cmp	r0, r3 
	beq 	L7 @ si hay al menos un boton presionado se aumenta el contador una unidad
	mov 	r3, #0 @ counter = 0
	str	r3, [r7, #8] @ guarda el valor de counter dentro del marco
L3:		
@ else
@ counter = counter + 1
	ldr 	r3, [r7, #8] @ carga en r3 el valor de counter
	add	r3, #1 @ suma una unidad a counter
	str 	r3, [r7, #8] @ guarda el valor de counter dentro del marco
@ if (counter >= 4)
@    return true
	ldr 	r3, [r7, #8] @ carga en r3 el valor de counter
	cmp	r3, #4 @ counter >= 4 ?
	blt	L8 @ si counter < 4 sigue dentro del ciclo
	ldr	r0, [r7, #4] @ carga el valor de counter en r0 
        @ Epilogo
	adds	r7, r7, #24
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr
L4:
	ldr     r3, [r7, #12] @ carga en r3 el valor de i
        add     r3, #1 @ i++
        str     r3, [r7, #12] @ guarda el valor de i dentro del marco
L2:     
	ldr     r3, [r7, #12] @ carga en r3 el valor de i
        cmp     r3, #10 @ i < 10 ?
        blt     L9 @ si i < 10 sigue dentro del ciclo
@ return false
	@ Epilogo
	mov 	r0, #0 @ return 0
	adds	r7, r7, #24
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr

setup:
        # Prologue
        push    {r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0

        # enabling clock in port B
        ldr     r0, =RCC_APB2ENR @ move 0x40021018 to r0
        mov     r3, 0x4 @ loads 16 in r1 to enable clock in port A (IOPC bit)
        str     r3, [r0] @ M[RCC_APB2ENR] gets 4

        # set pin 0 to 4 as digital output
        ldr     r0, =GPIOA_CRL @ moves address of GPIOA_CRL register to r0
        ldr     r3, =0x44433333 @ PA0, PA1, PA2, PA3, PA4: output push-pull, max speed 50 MHz
        str     r3, [r0] @ M[GPIOA_CRL] gets 0x44433333

        # set pins 8-9 as digital input
        ldr     r0, =GPIOA_CRH @ moves address of GPIOA_CRH register to r0
        ldr     r3, =0x44444488 @ : input pull-down
        str     r3, [r0] @ M[GPIOB_CRH] gets 0x44444488

        # set led status initial value
        ldr     r0, =GPIOA_ODR @ moves address of GPIOA_ODR register to r0
        mov     r3, #0
        str     r3, [r0]

        # counter = 0;
        mov     r0, #0
        str     r0, [r7]
loop:   
        # if(2 buttons are pressed)
        mov     r0, 0x300
        bl      is_button_pressed
        cmp     r0, 0x300
        bne     .L6
        bl      reset
        str     r0, [r7]
        
.L6:    # else if(addition button is pressed)
        mov     r0, 0x100
        bl      is_button_pressed
        cmp     r0, 0x100
        bne     .L7
        ldr     r0, [r7]
        bl      addition
        str     r0, [r7]

.L7:    # else if(subtraction button is pressed)
        mov     r0, 0x200
        bl      is_button_pressed
        cmp     r0, 0x200
        bne     .L8

        ldr     r0, [r7]
        bl      subtraction
        str     r0, [r7]
.L8:
        ldr     r1, =GPIOA_ODR
        ldr     r0, [r7]
        str     r0, [r1]
        b       loop
