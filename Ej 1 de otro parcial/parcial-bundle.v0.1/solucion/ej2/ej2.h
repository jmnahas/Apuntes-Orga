#ifndef EJ2
#define EJ2

#include <stdio.h>   	//encabezado de funciones de entrada y salida fopen, fclose, fgetc, printf, fprintf ...
#include <stdlib.h>  	//biblioteca estándar, atoi, atof, rand, srand, abort, exit, system, NULL, malloc, calloc, realloc...
#include <stdint.h>  	//contiene la definición de tipos enteros ligados a tamaños int8_t, int16_t, uint8_t,...
#include <ctype.h>   	//contiene funciones relacionadas a caracteres, isdigit, islower, tolower...
#include <string.h>  	//contiene las funciones relacionadas a strings, memcmp, strcat, memset, memmove, strlen,strstr...
#include <math.h>    	//define funciones matemáticas como cos, sin, abs, sqrt, log...
#include <stdbool.h> 	//contiene las definiciones de datos booleanos, true (1), false (0)
#include <unistd.h>  	//define constantes y tipos standard, NULL, R_OK, F_OK, STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO...
#include <assert.h>  	//provee la macro assert que evalúa una condición, y si no se cumple provee información diagnóstica y aborta la ejecución

//*************************************
//Declaración de estructuras
//*************************************
typedef struct rgba_t {
    unsigned char r, g, b, a;
} __attribute__((packed)) rgba_t;

typedef struct yuv_t {
    int8_t y, u, v;
} __attribute__((packed)) yuv_t;

typedef struct yuyv_t {
    int8_t y1, u, y2, v;
} __attribute__((packed)) yuyv_t;

#define USE_ASM_IMPL 1


//*******************************
//Declaración de funciones de ej2
//*******************************
void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, 
                          uint32_t height  );
void YUYV_to_RGBA_c( int8_t *X, uint8_t *Y, uint32_t width, 
                          uint32_t height  );

#endif /* EJ2 */
