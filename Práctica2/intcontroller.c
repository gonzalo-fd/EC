/*-------------------------------------------------------------------
 **
 **  Fichero:

 **    intcontroller.c
 **
 **    Estructura de Computadores
 **    Dpto. de Arquitectura de Computadores y Automática
 **    Facultad de Informática. Universidad Complutense de Madrid
 **
 **  Propósito:
 **    Contiene las implementación del módulo intcontroller
 **
 **-----------------------------------------------------------------*/

/*--- ficheros de cabecera ---*/
#include "44b.h"
#include "intcontroller.h"

void ic_init(void) {
	/* Configuración por defector del controlador de interrupciones:
	 *    Líneas IRQ y FIQ no habilitadas
	 *    Línea IRQ en modo no vectorizado
	 *    Todo por la línea IRQ
	 *    Todas las interrupciones enmascaradas
	 **/
	rINTMOD = 0x0; // Configura las líneas como de tipo IRQ
	rINTCON = 0x7; // IRQ y FIQ enmascaradas, IRQ en modo no vectorizado
	rINTMSK = ~(0x0); // Enmascara todas las líneas
}

int ic_conf_irq(enum enable st, enum int_vec vec) {
	int conf = rINTCON;

	if (st != ENABLE && st != DISABLE)
		return -1;

	conf &= ~(0x7);

	if (vec == VEC) {
		//COMPLETAR: poner la línea IRQ en modo vectorizado
		conf |= (0x3);
	} else {
		//COMPLETAR: poner la línea IRQ en modo no vectorizado
		conf |= (0x5);
	}
	if (st == ENABLE) {
		//COMPLETAR: habilitar la línea IRQ
		conf &= ~(0x1 << 1);

	} else {
		//COMPLETAR: deshabilitar la línea IRQ
		conf |= (0x2);

	}
	rINTCON = conf;
	return 0;
}

int ic_conf_fiq(enum enable st) {
	int ret = 0;
	//añadido
	int conf = rINTCON;

	if (st == ENABLE) {
		//COMPLETAR: habilitar la línea FIQ
		conf &= ~(0x1);

	} else if (st == DISABLE) {
		//COMPLETAR: deshabilitar la línea FIQ
		conf |= (0x1);
	} else
		ret = -1;

	rINTCON = conf;
	return ret;
}

int ic_conf_line(enum int_line line, enum int_mode mode) {
	unsigned int bit = INT_BIT(line); // ???????????

	//añadido
	int conf = rINTMOD;

	if (line < 0 || line > 26)
		return -1;

	if (mode != IRQ && mode != FIQ)
		return -1;

	if (mode == IRQ) {
		//COMPLETAR: poner la línea indicada en line en modo IRQ
		conf &= ~(0x1 << line);

	} else {
		//COMPLETAR: poner la línea indicada en line en modo FIQ
		conf |= (0x1 << line);
	}
	rINTMOD = conf;
	return 0;
}

int ic_enable(enum int_line line) {
	if (line < 0 || line > 26)
		return -1;

	//COMPLETAR: habilitar las interrupciones por la línea indica en line
	//habilitar también bit global

	rINTMSK &=~ (0x1 << line);
	rINTMSK &=~ (0x1<< INT_GLOBAL);//habilita bit global

	return 0;
}

int ic_disable(enum int_line line) {
	if (line < 0 || line > 26)
		return -1;

	//COMPLETAR: enmascarar las interrupciones por la línea indicada en line
	rINTMSK |= (0x1 << line);

	return 0;
}

int ic_cleanflag(enum int_line line) {
	int bit;

	if (line < 0 || line > 26)
		return -1;

	bit = INT_BIT(line);

	if (rINTMOD & bit) {
		//COMPLETAR: borrar el flag de interrupción correspondiente a la línea indicada en line
		//con la línea configurada por FIQ
		rF_ISPC |= (0x1 << line);
		//llamar a ispc que hay que hacer en ensamblador
	} else {
		//COMPLETAR: borrar el flag de interrupción correspondiente a la línea indicada en line
		//con la línea configurada por IRQ
		rI_ISPC |= (0x1 << line);
	}
	return 0;
}

