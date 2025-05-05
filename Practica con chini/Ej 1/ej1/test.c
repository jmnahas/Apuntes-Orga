#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Cuenta cuántos tests corrieron exitosamente.
 */
uint64_t successful_tests = 0;
/**
 * Cuenta cuántos tests test fallaron.
 */
uint64_t failed_tests = 0;

/**
 * El mensaje [DONE] escrito en verde.
 */
#define DONE "[\033[32;1mDONE\033[0m] "

/**
 * El mensaje [FAIL] escrito en rojo.
 */
#define FAIL "[\033[31;1mFAIL\033[0m] "

/**
 * El mensaje [INFO] escrito en amarillo.
 */
#define INFO "[\033[33;1mINFO\033[0m] "

/**
 * El mensaje [SKIP] escrito en magenta.
 */
#define SKIP "[\033[95;1mSKIP\033[0m] "

typedef enum {
	COMPARAR_POR_NOMBRE,
	COMPARAR_POR_FUERZA,
	COMPARAR_POR_DURABILIDAD,
	COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD
} test_comparador_t;

const char* nombre_comparador[] = {
	[COMPARAR_POR_NOMBRE] = "COMPARAR_POR_NOMBRE",
	[COMPARAR_POR_FUERZA] = "COMPARAR_POR_FUERZA",
	[COMPARAR_POR_DURABILIDAD] = "COMPARAR_POR_DURABILIDAD",
	[COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD] = "COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD"
};

bool test_comparar_por_nombre(item_t* a, item_t* b) {
	return strcmp(a->nombre, b->nombre) <= 0;
}

bool test_comparar_por_fuerza(item_t* a, item_t* b) {
	return b->fuerza <= a->fuerza;
}

bool test_comparar_por_durabilidad(item_t* a, item_t* b) {
	return a->durabilidad <= b->durabilidad;
}

bool test_comparar_por_nombre_desempatar_por_durabilidad(item_t* a, item_t* b) {
	int resultado = strcmp(a->nombre, b->nombre);
	if (resultado == 0) return a->durabilidad <= b->durabilidad;
	return resultado < 0;
}

comparador_t funcion_comparador[] = {
	[COMPARAR_POR_NOMBRE] = test_comparar_por_nombre,
	[COMPARAR_POR_FUERZA] = test_comparar_por_fuerza,
	[COMPARAR_POR_DURABILIDAD] = test_comparar_por_durabilidad,
	[COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD] = test_comparar_por_nombre_desempatar_por_durabilidad
};

void test_es_indice_ordenado(bool esperado, item_t** inventario, uint16_t* indice, test_comparador_t id_comparador) {
	bool failed = false;

	uint16_t tamanio = 0;
	for (item_t** i = inventario; *i != NULL; i++, tamanio++);

	bool resultado = es_indice_ordenado(inventario, indice, tamanio, funcion_comparador[id_comparador]);

	if (resultado != esperado) {
		printf(FAIL "%s != es_indice_ordenado(inventario, (uint16_t[]) {", esperado ? " true" : "false");
		for (int i = 0; i < tamanio; i++) {
			printf("%d", indice[i]);
			if (i + 1 < tamanio) {
				printf(", ");
			}
		}
		printf("}, %d, %s)\n", tamanio, nombre_comparador[id_comparador]);
		failed_tests++;
		return;
	} else {
		printf(DONE "%s == es_indice_ordenado(inventario, (uint16_t[]) {", esperado ? " true" : "false");
		for (int i = 0; i < tamanio; i++) {
			printf("%d", indice[i]);
			if (i + 1 < tamanio) {
				printf(", ");
			}
		}
		printf("}, %d, %s)\n", tamanio, nombre_comparador[id_comparador]);
		successful_tests++;
	}
}

void test_indice_a_inventario(item_t** inventario, uint16_t* indice, item_t** esperado) {
	bool failed = false;

	uint16_t tamanio = 0;
	for (item_t** i = inventario; *i != NULL; i++, tamanio++);

	item_t** resultado = indice_a_inventario(inventario, indice, tamanio);

	for (int i = 0; i < tamanio; i++) {
		if (resultado[i] == esperado[i]) continue;

		printf(FAIL "indice_a_inventario(inventario, (uint16_t[]) {");
		for (int i = 0; i < tamanio; i++) {
			printf("%d", indice[i]);
			if (i + 1 < tamanio) {
				printf(", ");
			}
		}
		printf("}, %d): Distinto ítem en la posición %d!\n", tamanio, i);
		failed_tests++;
		free(resultado);
		return;
	}

	// No encontramos errores
	printf(DONE "indice_a_inventario(inventario, (uint16_t[]) {");
	for (int i = 0; i < tamanio; i++) {
		printf("%d", indice[i]);
		if (i + 1 < tamanio) {
			printf(", ");
		}
	}
	printf("}, %d)\n", tamanio);
	successful_tests++;
	free(resultado);
}

#define I(valor_nombre, valor_fuerza, valor_durabilidad) (&(item_t) { \
	.nombre = #valor_nombre,                                          \
	.fuerza = (valor_fuerza),                                         \
	.durabilidad = (valor_durabilidad)                                \
})

/**
 * Evalúa los tests del ejercicio 1A. Este ejercicio requiere implementar
 * `es_indice_ordenado`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_1A_HECHO`.
 */
void test_ej1a(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_1A_HECHO) {
		printf(SKIP "El ejercicio 1A no está hecho aún.\n");
		return;
	}

	item_t* inventario[] = {
		I(Espada que espadea, 10, 5),
		I(Escudo de carton, 1, 2),
		I(Caramelos 30 min, 2, 3),
		I(Yerba mate, 5, 1),
		NULL
	};

	test_es_indice_ordenado(true,  inventario, (uint16_t[]) {2, 1, 0, 3}, COMPARAR_POR_NOMBRE);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {2, 1, 0, 3}, COMPARAR_POR_FUERZA);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {2, 1, 0, 3}, COMPARAR_POR_DURABILIDAD);
	test_es_indice_ordenado(true,  inventario, (uint16_t[]) {2, 1, 0, 3}, COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD);

	test_es_indice_ordenado(false, inventario, (uint16_t[]) {0, 3, 2, 1}, COMPARAR_POR_NOMBRE);
	test_es_indice_ordenado(true,  inventario, (uint16_t[]) {0, 3, 2, 1}, COMPARAR_POR_FUERZA);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {0, 3, 2, 1}, COMPARAR_POR_DURABILIDAD);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {0, 3, 2, 1}, COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD);

	test_es_indice_ordenado(false, inventario, (uint16_t[]) {3, 1, 2, 0}, COMPARAR_POR_NOMBRE);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {3, 1, 2, 0}, COMPARAR_POR_FUERZA);
	test_es_indice_ordenado(true,  inventario, (uint16_t[]) {3, 1, 2, 0}, COMPARAR_POR_DURABILIDAD);
	test_es_indice_ordenado(false, inventario, (uint16_t[]) {3, 1, 2, 0}, COMPARAR_POR_NOMBRE_DESEMPATAR_POR_DURABILIDAD);

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 1A tuvo tests que fallaron.\n");
	}
}

/**
 * Evalúa los tests del ejercicio 1B. Este ejercicio requiere implementar
 * `es_indice_ordenado`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_1B_HECHO`.
 */
void test_ej1b(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_1B_HECHO) {
		printf(SKIP "El ejercicio 1A no está hecho aún.\n");
		return;
	}

	item_t* inventario[] = {
		I(Espada que espadea, 10, 5),
		I(Escudo de carton, 1, 2),
		I(Caramelos 30 min, 2, 3),
		I(Yerba mate, 5, 1),
		NULL
	};

	test_indice_a_inventario(inventario, (uint16_t[]) {0, 1, 2, 3}, inventario);
	test_indice_a_inventario(inventario, (uint16_t[]) {2, 1, 0, 3}, (item_t*[]) {
		inventario[2],
		inventario[1],
		inventario[0],
		inventario[3]
	});
	test_indice_a_inventario(inventario, (uint16_t[]) {0, 3, 2, 1}, (item_t*[]) {
		inventario[0],
		inventario[3],
		inventario[2],
		inventario[1]
	});
	test_indice_a_inventario(inventario, (uint16_t[]) {3, 1, 2, 0}, (item_t*[]) {
		inventario[3],
		inventario[1],
		inventario[2],
		inventario[0]
	});

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 1B tuvo tests que fallaron.\n");
	}
}

/**
 * Corre los tests de este ejercicio.
 *
 * Las variables `EJERCICIO_1A_HECHO` y `EJERCICIO_1B_HECHO` controlan qué
 * testsuites se van a correr. Ponerlas como `false` indica que el ejercicio no
 * está implementado y por lo tanto no querés que se corran los tests asociados
 * a él.
 *
 * Recordá que los dos ejercicios pueden implementarse independientemente uno
 * del otro.
 *
 * Si algún test falla el programa va a terminar con un código de error.
 */
int main(int argc, char* argv[]) {
	// 1A
	test_ej1a();
	// 1B
	test_ej1b();

	printf(
		"\nSe corrieron %ld tests. %ld corrieron exitosamente. %ld fallaron.\n",
		failed_tests + successful_tests, successful_tests, failed_tests
	);

	if (failed_tests) {
		return 1;
	} else {
		return 0;
	}
}
