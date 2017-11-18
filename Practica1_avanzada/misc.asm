
	.equ COEF1, 3483
	.equ COEF2, 11718
	.equ COEF3, 1183
	.equ COEFDIV, 16384
	.equ COEF4, 255
	.text


	.global rgb2gray
	.global div16384
	.global apply_gaussian
	.global apply_invertir
	.global cambiacolor
	.global suma


rgb2gray:PUSH {R4,R5,R6,R7,R8,LR}
		 LDR R1, =COEF1
	     LDR R2, =COEF2
	 	 LDR R3, =COEF3

						   //
		 LDRB R5, [R0]     // R
  	 	 MUL R6, R5, R1    //

  	 	 ADD R0, R0, #1    //
  	 	 LDRB R5, [R0]     // G
  	 	 MUL R7, R5, R2    //

  	 	 ADD R0, R0, #1    //
  	 	 LDRB R5, [R0]     // B
  	 	 MUL R8, R5, R3    //

  	 	 ADD R0, R6, R7
  	 	 ADD R0, R0, R8

  	 	 BL div16384
		 POP {R4,R5,R6,R7,R8,LR}
		 MOV PC,LR
		 B .

div16384: PUSH {LR}
			LSR R0, R0, #14
		  POP {LR}
		  MOV PC, LR

apply_gaussian: PUSH {R4,R5,R6,R8,LR}
				MOV R4, #0 // i
		  for1: CMP R4, R3
		  		BGE fin
				MOV R5, #0 // j
		  for2: CMP R5, R2
		  		BGE fin_for2

		  		PUSH {R0,R1,R2,R3,R4,R5} //¿BURRADA?
		  		MOV R8, R1
		        MOV R1, R2 // PASAMOS WIDTH A R1
		        MOV R2, R3 // PASAMOS HEIGHT A R2
		        MOV R3, R4 // PASAMOS I A R3
		        MOV R4, R5 // PASAMOS J A R4


		        PUSH {R4}
		        BL gaussian
				POP {R4}
				MOV R7, R0
 				POP  {R0,R1,R2,R3,R4,R5}
		        MUL R6, R4, R2          //
		        ADD R6, R6, R5          // GUARDAMOS EN LA POSICION I*WIDTH + J DE IM2
		      	STRB R7, [R1,R6]  			    //

		        //POP  {R0,R1,R2,R3,R4,R5}

		        ADD R5, R5, #1
		        B for2

	fin_for2:   ADD R4, R4, #1
				B for1

		fin: 	POP {R4,R5,R6,R8,LR}
				MOV PC, LR


apply_invertir:
			  PUSH {R4-R9,LR}
			  MOV R4,#0 //i
			   SUB R6,R3,#1 //K = HEIGHT-1
	 	forUNO: CMP R4,R3
	 		  BGE fin_forUNO
	 		  MOV R5,#0 //J
	 	forDOS: CMP R5,R2

	 	      BGE fin_forDOS
	 	      MUL R8, R4,R2
	 	      ADD R8, R8,R5
	 	      MOV R10,R0
	 	      LDRB R0, [R0,R8]
	 	      PUSH {R4}
	 	      BL cambiaColor
	 	      POP {R4}
	 	      MOV R9,R0
	 	      MOV R0,R10


	 	      MUL R7,R2,R6 // K*WIDTH
	 	      ADD R7,R7,R5
	 	      STRB R9,[R1,R7]

	 	      ADD R5,R5,#1
	 	      B forDOS
	 fin_forDOS: ADD R4,R4,#1
	 			SUB R6,R6,#1
	 			B forUNO
	 fin_forUNO:
	 			POP {R4-R9,LR}
	 			MOV PC,LR

cambiaColor:
			PUSH {LR}
			LDR R4 ,=COEF4
			SUB R0,R4,R0
			POP {LR}
			MOV PC, LR
			.end
