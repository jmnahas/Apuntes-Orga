#pragma once

#include <stdio.h>
#include "lista.h"

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof(*(arr)))

#define PROYECTO(...)                                               \
	&(lista_t) {                                                \
		.next = NULL,                                       \
		.sum = helper_sumar(                                \
			(uint32_t[]){ __VA_ARGS__ },                \
			ARRAY_SIZE(((uint32_t[]) { __VA_ARGS__ }))  \
		),                                                  \
		.size = ARRAY_SIZE(((uint32_t[]) { __VA_ARGS__ })), \
		.array = (uint32_t[]){ __VA_ARGS__ }                \
	}

#define LISTA(...) helper_array_a_lista((lista_t*[]) { __VA_ARGS__ __VA_OPT__(,) NULL })

static inline uint32_t helper_sumar(uint32_t array[], size_t length) {
	uint32_t result = 0;
	for (size_t i = 0; i < length; i++) {
		result += array[i];
	}
	return result;
}

static inline lista_t* helper_array_a_lista(lista_t* proyectos[]) {
	if (proyectos[0] == NULL) {
		return NULL;
	}

	for (size_t i = 1; proyectos[i] != NULL; i++) {
		proyectos[i-1]->next = proyectos[i];
	}

	return proyectos[0];
}

static inline void imprimir_proyecto(lista_t* proyecto) {
	printf("== Proyecto %p\n", proyecto);
	printf("   next: %p\n", proyecto->next);
	printf("   sum:  %u\n", proyecto->sum);
	printf("   size: %ld\n", proyecto->size);
	printf("   [");
	for (size_t i = 0; i < proyecto->size; i++) {
		if (i == 0) {
			printf("%u", proyecto->array[i]);
		} else {
			printf(", %u", proyecto->array[i]);
		}
	}
	printf("]\n");
}

static inline void imprimir_proyectos(lista_t* proyectos) {
	if (proyectos == NULL) {
		printf("== FIN\n");
	} else {
		imprimir_proyecto(proyectos);
		imprimir_proyectos(proyectos->next);
	}
}

