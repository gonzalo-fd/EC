/*-----------------------------------------------------------------
**
**  Fichero:
**    init.asm
**
**    Estructura de Computadores
**    Dpto. de Arquitectura de Computadores y Autom�tica
**    Facultad de Inform�tica. Universidad Complutense de Madrid
**
**  Prop�sito:
**    Arranca un programa en C
**
**  Notas de dise�o:
**
**---------------------------------------------------------------*/

   .extern main
	.global start
	.extern button_ISR
	.extern timer_ISR
	
	/* Etiquetas que se usan para inicializar la Tabla de direcciones */
	.equ _ISR_STARTADDRESS, 0xc7fff00
	.equ HandleIRQ, _ISR_STARTADDRESS+4*6

	/* Constantes utiles para la rutina ISR_IRQ */
	.equ I_ISPR, 0x01E00020
	.equ I_ISPC, 0x01E00024

	/*
	** Modos de operaci�n
	*/
	.equ MODEMASK, 0x1f		/* Para selecci�n de M[4:0] del CPSR */
	.equ USRMODE,  0x10
	.equ FIQMODE,  0x11
	.equ IRQMODE,  0x12
	.equ SVCMODE,  0x13
	.equ ABTMODE,  0x17
	.equ UNDMODE,  0x1b
	.equ SYSMODE,  0x1f

	/*
	** Direcciones de las bases de las pilas del sistema 
	*/
	.equ USRSTACK, 0xc7ff000   	
	.equ SVCSTACK, 0xc7ff100
	.equ UNDSTACK, 0xc7ff200
	.equ ABTSTACK, 0xc7ff300
	.equ IRQSTACK, 0xc7ff400
	.equ FIQSTACK, 0xc7ff500

	/*
	** Registros del controlador de interrupciones para enmascarar y eliminar interrupciones pendientes
	*/
	.equ rINTMSK,    0x1e0000c
	.equ rI_ISPC,    0x1e00024
	.equ rF_ISPC,    0x1e0003c

	/*
	** Registro del puerto G  para eliminar interrupciones pendientes
	*/
	.equ rEXTINTPND, 0x1d20054

start:


	/* 1- Pasar a modo supervisor */
    mrs	r0, cpsr
    bic	r0, r0, #MODEMASK
    orr	r1, r0, #SVCMODE
    msr	cpsr_c, r1 

/* Inicializaci�n de la secci�n bss a 0, est�ndar C */
    ldr	    r3, =Image_ZI_Base
	ldr	    r1, =Image_ZI_Limit	/* Top of zero init segment */
    mov	    r2, #0
L0:
    cmp	    r3, r1	    		/* Zero init */
    strcc   r2, [r3], #4
    bcc	    L0
	/****************************************************/

	/* 2- Desde modo SVC inicializar los SP de todos los modos de ejecuci�n privilegiados */
    bl InitStacks



	/*3- En el controlador de interrupciones, enmascarar interrupciones */
	ldr r0, =rINTMSK
	ldr r1, =0x1fffffff
    str r1, [r0]

	/*4- Habilitar linea IRQ y FIQ del procesador (registro de estado CPSR) */
	mrs r0, cpsr
	bic r0, r0, #0xC0
	msr cpsr_c, r0
	
	/*5- Inicializar la tabla de direcciones de la subrutinas de tratamiento de interrupcion*/
	/* A�adir la direcci�n de la subrutina irq_ISR en la tabla de direcciones de la subrutinas de tratamiento de interrupcion */
	/*COMPLETAR*/
	ldr r0,=irq_ISR
	ldr r1,=HandleIRQ
	str r0,[r1]

    /*6- Eliminar posibles interrupciones pendientes */
	ldr r0, =rEXTINTPND
	ldr r1, =0xff
	str r1, [r0]
	ldr r0, =rI_ISPC
	ldr r1, =0x1fffffff
	str r1, [r0]
	ldr r0, =rF_ISPC
	ldr r1, =0x1fffffff
	str r1, [r0]


	/* Desde modo SVC cambia a modo USR e inicializa el SP_usr */
	mrs r0, cpsr
	bic r0, r0, #MODEMASK
	orr r1, r0, #USRMODE  
	msr cpsr_c, r1
	ldr sp, =USRSTACK

    mov fp, #0

	/* Saltar al main */
    bl main

End:
    B End

InitStacks:
	mrs r0, cpsr
	bic r0, r0, #MODEMASK

	orr r1, r0, #UNDMODE  /* desde modo SVC cambia a modo UND e inicializa el SP_und */
	msr cpsr_c, r1    
	ldr sp, =UNDSTACK

	orr r1, r0, #ABTMODE  /* desde modo UND cambia a modo ABT e inicializa el SP_abt */
	msr cpsr_c, r1 
	ldr sp, =ABTSTACK

	orr r1, r0, #IRQMODE  /* desde modo ABT cambia a modo IRQ e inicializa el SP_abt */
	msr cpsr_c, r1
	ldr sp, =IRQSTACK

	orr r1, r0, #FIQMODE  /* desde modo IRQ cambia a modo FIQ e inicializa el SP_fiq */
	msr cpsr_c, r1
	ldr sp, =FIQSTACK

	orr r1, r0, #SVCMODE  /* desde modo FIQ cambia a modo SVC e inicializa el SP_svc */
	msr cpsr_c, r1
	ldr sp, =SVCSTACK
	
    mov pc, lr

//irq_ISR:
	//COMPLETAR: debemos ver si la interrupci�n que debemos atender es la
	//de la l�nea INT_TIMER0 and INT_EINT4567. Si es la del timer se invocar� la
	//funci�n timer_ISR y despu�s se borrar� el flag de interrupci�n utilizando
	//el interfaz definido en intcontroller.h. Si es la de EINT4567 se invocar�
	//la funci�n button_ISR y se borrar� el flag correspondiente utilizando el
	//mismo interfaz.
	//Recordad que en el pr�logo hay que guardar todos los registros usados + lr si es no hoja*/
	//Antes de la llamada a otra funci�n hay que guardar los registros de R0 a R3

irq_ISR:
		push {r0-r3,lr}
		LDR r0, =I_ISPR
		LDR r1,[r0]
		LDR r3, =0x2000 // 1 en el bit 13
		AND r2, r1, r3
		CMP r2, #0
		BEQ if_eint4567
		BL timer_ISR
		MOV r0, #13 // timer
		BL  ic_cleanflag
		B exit
if_eint4567:
		LDR r3, =0x200000 // 1 en el bit 21
		AND r2, r1, r3
		CMP r2, #0
		BEQ exit
		BL button_ISR
		MOV r0, #21 // button
		BL ic_cleanflag
exit:   pop {r0-r3, lr}
		SUBS pc, lr , #4
	.end

