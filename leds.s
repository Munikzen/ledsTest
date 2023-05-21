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
        ble     .A1
        bl      reset @ counter = 0;
        str     r0, [r7, #4] 

.A1:
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
        bge     .S1
        bl      reset @ counter = 0;
        str     r0, [r7, #4] 

.S1:
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
        ldr     r0, =GPIOA_ODR
        ldr     r3, [r7, #4]
        str     r3, [r0] 
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

read_input:
        # Epilogue
        push    {r7}
        sub     sp, sp, #4
        add     r7, sp, #0
        str     r0, [r7] 
        # Function body
        ldr     r0, =GPIOA_IDR
        ldr     r0, [r0]
        ldr     r3, [r7]
        and     r0, r0, r3
        cmp     r0, r3
        beq     .L0
        mov     r0, #0
.L0:    
        # Epilogue
        adds    r7, r7, #4
        mov     sp, r7
        pop     {r7}
        bx      lr


is_button_pressed:
	push 	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
	str 	r0, [r7, #4]
	# read button input
	ldr	r0, [r7, #4]
	bl	read_button_input
	ldr 	r3, [r7, #4]
	cmp	r0, r3
	beq	.L1
	mov	r0, #0
	adds	r7, r7, #16
	mov	sp, r7
	pop 	{r7, lr}
	bx	lr
.L1:
	# counter = 0
	mov	r3, #0
	str	r3, [r7, #8]
	# for (int i = 0, i < 10, i++) 
	mov     r3, #0 @ j = 0;
        str     r3, [r7, #12]
        b       .L2
.L5:     
	# wait 5 ms
	mov 	r0, #50
	bl   	delay
	# read button input
	ldr	r0, [r7, #4]
	bl	read_button_input
	ldr 	r3, [r7, #4]
	cmp	r0, r3
	beq 	.L3
	mov 	r3, #0
	str	r3, [r7, #8]
.L3:		
	# counter = counter + 1
	ldr 	r3, [r7, #8]
	add		r3, #1
	str 	r3, [r7, #8]
	ldr 	r3, [r7, #8]
	cmp	r3, #4
	blt	.L4
	ldr	r0, [r7, #4]
	adds	r7, r7, #16
	mov	sp, r7
	pop 	{r7, lr}
	bx	lr
.L4:
	ldr     r3, [r7, #12] @ j++;
        add     r3, #1
        str     r3, [r7, #12]
.L2:     
	ldr     r3, [r7, #12] @ j < 10;
        cmp     r3, #10
        blt     .L5

	# return 0
	mov 	r0, #0
	adds	r7, r7, #16
	mov		sp, r7
	pop 	{r7, lr}
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
        b       loop
