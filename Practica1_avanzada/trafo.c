/*-----------------------------------------------------------------
**
**  Fichero:
**    trafo.h  10/6/2014
**
**    Estructura de Computadores
**    Dpto. de Arquitectura de Computadores y Autom�tica
**    Facultad de Inform�tica. Universidad Complutense de Madrid
**
**  Prop�sito:
**    Contiene las implementaciones de las funciones en C
**    usadas por el programa principal
**
**  Notas de dise�o:
**
**---------------------------------------------------------------*/

#include "trafo.h"
#include "types.h"
#include "imgarm.h"




// COMPLETAR LAS FUNCIONES MARCADAS
/*
unsigned char rgb2gray(pixelRGB* pixel){
	unsigned char dest = (3483*pixel->R + 11718*pixel->G + 1183*pixel->B) /16384;
	return dest;
}
*/


void RGB2GrayMatrix(pixelRGB orig[], unsigned char dest[], int nfilas, int ncols) {
    int i,j;

    for (i=0;i<nfilas;i++)
        for (j=0; j<ncols; j++)
            dest[i*ncols+j] =  rgb2gray(&orig[i*ncols+j]);

}

/*
void apply_gaussian(unsigned char im1[], unsigned char im2[], int width, int height){
	int i,j;
	for (i=0 ; i < height; ++i){
		for (j=0 ; j < width; ++j){
			im2[i * width + j] = gaussian(im1, width, height, i, j);
		}
	}
}
*/

void apply_sobel(unsigned char im1[], unsigned char im2[], int width, int height){
	int i,j;
		for (i=0 ; i < height; ++i){
			for (j=0 ; j < width; ++j){
				im2[i * width + j] = sobel(im1, width, height, i, j);
			}
		}
}

/*void apply_invertir(unsigned char im1[], unsigned char im2[],int width , int height){

	int i,j,k;

	k = height-1;
	for(i=0;i < height; i++){
		for(j = 0;j < width; j++){
			im2[k*width+j] = im1[i*width+j];
		}
		k= k-1;
	}
}
*/
