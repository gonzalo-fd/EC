
	.equ COEF1, 3483
	.equ COEF2, 11718
	.equ COEF3, 1183

//ldrb---cargas bit a bit

// Descomentar e implementar estas funciones
	.global rgb2gray
	.global div16384
	.global apply_gaussian

.text

start:

rgb2gray:
		push {r4-r7, lr}
		ldrb r4, [r0]
		ldr r5, =COEF1
		mul r6, r4, r5
		ldrb r4, [r0, #1]
		ldr r5, =COEF2
		mul r7, r4, r5
		add r6, r6, r7
		ldrb r4, [r0, #2]
		ldr r5, =COEF3
		mul r7, r4, r5
		add r0, r6, r7
		bl div16384
		pop {r4-r7, lr}
		mov pc, lr

div16384:
		push {lr}
		lsr r0, #14 //desplazar a la dch
		pop {lr}
		mov pc, lr

apply_gaussian:
		push {r4-r7, lr}
		mov r5, r0
		mov r6, r1
		mov r1, r2	//width
		mov r2, r3	//height
		mov r3, #0	//i
		mov r4, #0	//j
	for1:cmp r3, r2
		bge finfor1
	for2:cmp r4, r1
		bge finfor2
		mul r7, r3, r1		//i*width
		add r7, r7, r4		//i*width + j
		push {r1-r3}
		push {r4}
		bl gaussian
		add sp, sp, #4 		//borras el r4 que has guardado
		pop {r1-r3}
		strb r0, [r6, r7]	//el bit actualizado
		mov r0, r5 			//restauras el r0-->im1
		add r4, r4, #1		//j++
		b for2
	finfor2: mov r4, #0		//inicializar j
		add r3, r3, #1		//i++
		b for1
  	finfor1:pop {r4-r7, lr}
  		.end


