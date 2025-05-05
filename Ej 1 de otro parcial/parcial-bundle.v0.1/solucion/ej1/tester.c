#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej1.h"


#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej1 =  "salida.propios.ej1.txt";
void test_ej1a(char* filename);
void test_ej1b(char* filename);
void test_ej1c(char* filename);

int main(void) {
    srand(0);
    remove(filename_ej1);
    test_ej1a(filename_ej1);
    test_ej1b(filename_ej1);
    test_ej1c(filename_ej1);
    return 0;
}

#define LIST_SIZE 20
#define OT_LEN 6
#define SIZES_LEN 5
#define NODOS_TEST_LEN 5
#define GRAPHICS_CONSTANT 512

uint32_t shuffle_int(uint32_t min, uint32_t max){
    return (uint32_t) (rand() % (max + 1)) + min;
}

uint8_t primitiva_simple(uint8_t x, uint8_t y, uint8_t z_size) {
    return x-(uint8_t)1;
}

uint8_t primitiva_modulo(uint8_t x, uint8_t y, uint8_t z_size) {
    return (x+y) % z_size;
}

uint8_t primitiva_compleja(uint8_t x, uint8_t y, uint8_t z_size) {
    return (x+y) * z_size / GRAPHICS_CONSTANT;
}

void test_ej1a(char* filename) {

    ordering_table_t* (*func_init_OT)(uint8_t table_size);
    if (USE_ASM_IMPL){
        func_init_OT = inicializar_OT_asm;
    }else{
        func_init_OT = inicializar_OT;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "\n== Ejercicio 1a ==\n");) NL(filename)
    uint8_t sizes[SIZES_LEN] = {2,4,6,0,1};

    for (int i=0; i<SIZES_LEN; ++i) {
        ordering_table_t* ot = func_init_OT(sizes[i]);
        RUN(filename, fprintf(pfile, "Lista %d: %d %s\n", i,ot->table_size,(ot->table == NULL) ? "NULL" : "NOT NULL"));
        free(ot->table);
        free(ot);
    }
}

void test_ej1b(char* filename) {
    void (*func_calcular_z)(nodo_display_list_t* nodo, uint8_t z_size);
    if (USE_ASM_IMPL){
        func_calcular_z = calcular_z_asm;
    }else{
        func_calcular_z = calcular_z;
    }

    FILE* pfile;

    RUN(filename, fprintf(pfile, "\n== Ejercicio 1b ==\n");) NL(filename)

    nodo_display_list_t* nodo1 = inicializar_nodo(
        primitiva_simple,
        1, 2, NULL
    );
    nodo_display_list_t* nodo2 = inicializar_nodo(
        primitiva_modulo,
        1, 3, NULL
    );

    nodo_display_list_t* nodo3 = inicializar_nodo(
        primitiva_compleja,
        2, 4, NULL
    );

    func_calcular_z(nodo1, OT_LEN);
    RUN(filename, fprintf(pfile, "Nodo 1: %d\n", nodo1->z));
    func_calcular_z(nodo2, OT_LEN);
    RUN(filename, fprintf(pfile, "Nodo 2: %d\n", nodo2->z));
    func_calcular_z(nodo3, OT_LEN);
    RUN(filename, fprintf(pfile, "Nodo 3: %d\n", nodo3->z));

    free(nodo1);
    free(nodo2);
    free(nodo3);
}

void test_ej1c(char* filename) {
    void (*func_ordenar_dl)(ordering_table_t* ot, nodo_display_list_t* display_list);
    ordering_table_t* (*func_init_ot)(uint8_t table_size);
    if (USE_ASM_IMPL){
        func_ordenar_dl = ordenar_display_list_asm;
        func_init_ot = inicializar_OT_asm;
    }else{
        func_ordenar_dl = ordenar_display_list;
        func_init_ot = inicializar_OT;
    }
   

    FILE* pfile;

    RUN(filename, fprintf(pfile, "\n== Ejercicio 1c ==\n");) NL(filename)

    nodo_display_list_t* nodo1 = inicializar_nodo(
        primitiva_simple,
        (uint8_t)1, (uint8_t)2, NULL
    );
    nodo_display_list_t* nodo2 = inicializar_nodo(
        primitiva_modulo,
        (uint8_t)1, (uint8_t)3, nodo1
    );

    nodo_display_list_t* nodo3 = inicializar_nodo(
        primitiva_compleja,
        (uint8_t)2, (uint8_t)4, nodo2
    );

    nodo_display_list_t* nodo4 = inicializar_nodo(
        primitiva_simple,
        2, 5, nodo3
    );

    ordering_table_t* ot = func_init_ot(OT_LEN);

    func_ordenar_dl(ot, nodo4);
    for (int i=0; i<OT_LEN; ++i) {
        nodo_ot_t* z_index_current_node = ot->table[i];
        while (z_index_current_node != NULL) {
            nodo_display_list_t* nodo_actual = z_index_current_node->display_element;
            RUN(filename, fprintf(pfile, "OT position %d: %d\n", i, nodo_actual->z));
            nodo_ot_t* viejo_z_index = z_index_current_node;
            z_index_current_node = z_index_current_node->siguiente;
            free(viejo_z_index);
        }
    }
    free(ot->table);
    free(ot);
    free(nodo4);
    free(nodo3);
    free(nodo2);
    free(nodo1);
}

