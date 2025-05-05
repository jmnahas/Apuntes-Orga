#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>
#define USE_ASM_IMPL 1 

typedef struct nodo_display_list_t {
    // Puntero a la función que calcula z (puede ser distinta para cada nodo):
    uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size); //0-7
    // Coordenadas del nodo en la escena:
    uint8_t x;                                                  //8
    uint8_t y;                                                  //9
    uint8_t z;                                                  //10
    //Puntero al nodo siguiente:
    struct nodo_display_list_t* siguiente;                      //16-23
} nodo_display_list_t;                                          //24

typedef struct nodo_ot_t {
    struct nodo_display_list_t* display_element;                //0-7
    struct nodo_ot_t* siguiente;                                //8-15
} nodo_ot_t;                                                    //16

typedef struct ordering_table_t {
    uint8_t table_size;                                         //0
    struct nodo_ot_t** table;                                   //8-15
} ordering_table_t;                                             //16

ordering_table_t* inicializar_OT(uint8_t table_size);
ordering_table_t* inicializar_OT_asm(uint8_t table_size);

void calcular_z(nodo_display_list_t* nodo, uint8_t z_size);
void calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size);

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list);
void ordenar_display_list_asm(ordering_table_t* ot, nodo_display_list_t* display_list);

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente);
