#pragma once
#include <stdbool.h>
#include <stdint.h>

/**
 * Un ítem en nuestro videojuego.
 *
 * Campos:
 *   - nombre:      El nombre el ítem.
 *   - fuerza:      La cantidad de fuerza que provee usarlo.
 *   - durabilidad: El nivel de desgaste del ítem. Los ítems se rompen cuando
 *                  la durabilidad llega a 0.
 */
typedef struct {
	char nombre[18];
	uint32_t fuerza;
	uint16_t durabilidad;
} item_t;

/**
 * El tipo de las funciones que se utilizan para comparar ítems.
 *
 * Devolver `true` significa los parámetros están en el orden correcto.
 */
typedef bool (*comparador_t)(item_t*, item_t*);

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
extern bool EJERCICIO_1A_HECHO;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
extern bool EJERCICIO_1B_HECHO;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

/**
 * OPCIONAL: implementar en C
 */
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);
