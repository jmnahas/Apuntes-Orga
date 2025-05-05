#pragma once

#include <stdint.h>
#include <stddef.h>

typedef struct lista_s {
	// Siguiente elemento de la lista o NULL si es el final
	struct lista_s*  next;
	// Suma de los elementos en array
	uint32_t  sum;
	// Cantidad de elementos en array
	uint64_t  size;
	// El array en cuestión que posee este proyecto de la lista
	uint32_t* array;
} lista_t;

uint32_t proyecto_mas_dificil(lista_t*);
void marcar_tarea_completada(lista_t*, size_t);
uint64_t* tareas_completadas_por_proyecto(lista_t*);
