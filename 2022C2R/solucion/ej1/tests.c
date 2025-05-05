#include <stdbool.h>
#include <stdlib.h>

#include "utils.h"
#include "test-utils.h"

TEST(proyecto_mas_dificil_de_lista_vacia_cuesta_0) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA()) == 0);
}

TEST(proyecto_mas_dificil_si_no_hay_tareas_es_0) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA()) == 0);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO())) == 0);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(), PROYECTO())) == 0);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(), PROYECTO(), PROYECTO())) == 0);
}

TEST(proyecto_mas_dificil_con_una_sola_tarea_es_esa) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(99))) == 99);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(), PROYECTO(123))) == 123);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(1), PROYECTO(), PROYECTO())) == 1);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(), PROYECTO(2), PROYECTO())) == 2);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(), PROYECTO(), PROYECTO(3))) == 3);
}

TEST(proyecto_mas_dificil_usa_la_suma) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(1, 2, 3))) == 6);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(100, 200, 10))) == 310);
}

TEST(proyecto_mas_dificil_calcula_el_maximo) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(1, 2, 3))) == 6);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(3, 2, 1))) == 6);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(1), PROYECTO(2), PROYECTO(3))) == 3);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(3), PROYECTO(2), PROYECTO(1))) == 3);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(PROYECTO(10, 11, 12), PROYECTO(100, 90, 80))) == 270);
}

TEST(proyecto_mas_dificil_ignora_vacios) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA(
		PROYECTO(),
		PROYECTO(10, 11, 12),
		PROYECTO(),
		PROYECTO(20, 30, 40),
		PROYECTO()
	)) == 90);
}

TEST(proyecto_mas_dificil_ejemplos_del_enunciado) {
	TEST_ASSERT(proyecto_mas_dificil(LISTA(
		PROYECTO(1, 2, 3),
		PROYECTO(98, 99),
		PROYECTO(9)
	)) == 197);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(
		PROYECTO(),
		PROYECTO(),
		PROYECTO()
	)) == 0);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(
		PROYECTO(3),
		PROYECTO(2, 1),
		PROYECTO(1, 1, 1)
	)) == 3);
	TEST_ASSERT(proyecto_mas_dificil(LISTA(
		PROYECTO(),
		PROYECTO(1, 1, 1),
		PROYECTO(100)
	)) == 100);
	TEST_ASSERT(proyecto_mas_dificil(NULL) == 0);
}

bool son_listas_iguales(lista_t* a, lista_t* b) {
	if (a == NULL && b == NULL) {
		return true;
	}
	if (a == NULL || b == NULL) {
		return false;
	}
	if (a->sum != b->sum) {
		return false;
	}
	if (a->size != b->size) {
		return false;
	}
	for (size_t i = 0; i < a->size; i++) {
		if (a->array[i] != b->array[i]) {
			return false;
		}
	}
	return son_listas_iguales(a->next, b->next);
}

TEST(marcar_tarea_completada_) {
}

TEST(marcar_tarea_completada_accede_al_primero_como_array) {
	lista_t* lista = LISTA(PROYECTO(99, 98, 97));

	marcar_tarea_completada(lista, 0);
	TEST_ASSERT(lista->array[0] == 0);

	marcar_tarea_completada(lista, 1);
	TEST_ASSERT(lista->array[1] == 0);

	marcar_tarea_completada(lista, 2);
	TEST_ASSERT(lista->array[2] == 0);
}

TEST(marcar_tarea_completada_puede_atravesar_la_lista) {
	lista_t* lista = LISTA(
		PROYECTO(1, 2, 3),
		PROYECTO(10, 20, 30),
		PROYECTO(100, 200, 300)
	);

	marcar_tarea_completada(lista, 1);
	TEST_ASSERT(lista->array[1] == 0);

	marcar_tarea_completada(lista, 3);
	TEST_ASSERT(lista->next->array[0] == 0);

	marcar_tarea_completada(lista, 8);
	TEST_ASSERT(lista->next->next->array[2] == 0);
}

TEST(marcar_tarea_completada_actualiza_la_suma) {
	lista_t* lista = LISTA(PROYECTO(1, 2, 3));
	TEST_ASSERT(lista->sum == 6)

	marcar_tarea_completada(lista, 0);
	TEST_ASSERT(lista->sum == 5)

	marcar_tarea_completada(lista, 1);
	TEST_ASSERT(lista->sum == 3)

	marcar_tarea_completada(lista, 2);
	TEST_ASSERT(lista->sum == 0)
}


TEST(marcar_tarea_completada_ignora_proyectos_vacios) {
	lista_t* vacios_en_el_medio = LISTA(PROYECTO(1), PROYECTO(), PROYECTO(), PROYECTO(2));
	marcar_tarea_completada(vacios_en_el_medio, 1);
	TEST_ASSERT(son_listas_iguales(
		vacios_en_el_medio,
		LISTA(PROYECTO(1), PROYECTO(), PROYECTO(), PROYECTO(0))
	));

	lista_t* vacios_al_principio = LISTA(PROYECTO(), PROYECTO(), PROYECTO(1), PROYECTO(2));
	marcar_tarea_completada(vacios_al_principio, 0);
	TEST_ASSERT(son_listas_iguales(
		vacios_al_principio,
		LISTA(PROYECTO(), PROYECTO(), PROYECTO(0), PROYECTO(2))
	));

	marcar_tarea_completada(vacios_al_principio, 1);
	TEST_ASSERT(son_listas_iguales(
		vacios_al_principio,
		LISTA(PROYECTO(), PROYECTO(), PROYECTO(0), PROYECTO(0))
	));
}

TEST(marcar_tarea_completada_ejemplos_del_enunciado) {
	lista_t* ejemplo1 = LISTA(PROYECTO(1, 2, 3));
	marcar_tarea_completada(ejemplo1, 0);
	TEST_ASSERT(son_listas_iguales(
		ejemplo1,
		LISTA(PROYECTO(0, 2, 3))
	));

	lista_t* ejemplo2 = LISTA(PROYECTO(), PROYECTO(1));
	marcar_tarea_completada(ejemplo2, 0);
	TEST_ASSERT(son_listas_iguales(
		ejemplo2,
		LISTA(PROYECTO(), PROYECTO(0))
	));

	lista_t* ejemplo3 = LISTA(PROYECTO(1, 2, 3), PROYECTO(4, 5));
	marcar_tarea_completada(ejemplo3, 4);
	TEST_ASSERT(son_listas_iguales(
		ejemplo3,
		LISTA(PROYECTO(1, 2, 3), PROYECTO(4, 0))
	));

	lista_t* ejemplo4 = LISTA(PROYECTO(1), PROYECTO(2), PROYECTO(3));
	marcar_tarea_completada(ejemplo4, 2);
	TEST_ASSERT(son_listas_iguales(
		ejemplo4,
		LISTA(PROYECTO(1), PROYECTO(2), PROYECTO(0))
	));

	lista_t* ejemplo5 = LISTA(PROYECTO(1), PROYECTO(2), PROYECTO(3));
	marcar_tarea_completada(ejemplo5, 1);
	TEST_ASSERT(son_listas_iguales(
		ejemplo5,
		LISTA(PROYECTO(1), PROYECTO(0), PROYECTO(3))
	));
}

bool son_arrays_iguales(size_t size, uint64_t a[], uint64_t b[]) {
	for (size_t i = 0; i < size; i++) {
		if (a[i] != b[i]) {
			return false;
		}
	}
	return true;
}

TEST(tareas_completadas_por_proyecto_proyecto_vacio_da_cero) {
	uint64_t* un_proyecto_vacio =
		tareas_completadas_por_proyecto(LISTA(PROYECTO()));
	TEST_ASSERT(son_arrays_iguales(
		1, /* Elementos en el array */
		un_proyecto_vacio,
		(uint64_t[]) { 0 }
	))
	free(un_proyecto_vacio);

	uint64_t* dos_proyectos_vacios =
		tareas_completadas_por_proyecto(LISTA(PROYECTO(), PROYECTO()));
	TEST_ASSERT(son_arrays_iguales(
		2, /* Elementos en el array */
		dos_proyectos_vacios,
		(uint64_t[]) { 0, 0 }
	))
	free(dos_proyectos_vacios);

	uint64_t* tres_proyectos_vacios =
		tareas_completadas_por_proyecto(LISTA(PROYECTO(), PROYECTO(), PROYECTO()));
	TEST_ASSERT(son_arrays_iguales(
		3, /* Elementos en el array */
		tres_proyectos_vacios,
		(uint64_t[]) { 0, 0, 0 }
	))
	free(tres_proyectos_vacios);
}

TEST(tareas_completadas_por_proyecto_cuenta_ceros_si_son_todos_ceros) {
	uint64_t* un_proyecto_con_dos_ceros =
		tareas_completadas_por_proyecto(LISTA(PROYECTO(0, 0)));
	TEST_ASSERT(son_arrays_iguales(
		1, /* Elementos en el array */
		un_proyecto_con_dos_ceros,
		(uint64_t[]) { 2 }
	))
	free(un_proyecto_con_dos_ceros);

	uint64_t* un_cero_y_nueve_ceros =
		tareas_completadas_por_proyecto(LISTA(
			PROYECTO(0),
			PROYECTO(0, 0, 0, 0, 0, 0, 0, 0, 0)
		));
	TEST_ASSERT(son_arrays_iguales(
		2, /* Elementos en el array */
		un_cero_y_nueve_ceros,
		(uint64_t[]) { 1, 9 }
	))
	free(un_cero_y_nueve_ceros);

	uint64_t* uno_dos_y_tres_ceros =
		tareas_completadas_por_proyecto(LISTA(
			PROYECTO(0),
			PROYECTO(0, 0),
			PROYECTO(0, 0, 0)
		));
	TEST_ASSERT(son_arrays_iguales(
		3, /* Elementos en el array */
		uno_dos_y_tres_ceros,
		(uint64_t[]) { 1, 2, 3 }
	))
	free(uno_dos_y_tres_ceros);
}

TEST(tareas_completadas_por_proyecto_no_cuenta_no_ceros) {
	uint64_t* uno_dos_tres =
		tareas_completadas_por_proyecto(LISTA(
			PROYECTO(1, 2, 3)
		));
	TEST_ASSERT(son_arrays_iguales(
		1, /* Elementos en el array */
		uno_dos_tres,
		(uint64_t[]) { 0 }
	))
	free(uno_dos_tres);

	uint64_t* uno_dos_y_tres =
		tareas_completadas_por_proyecto(LISTA(
			PROYECTO(1, 2), PROYECTO(3)
		));
	TEST_ASSERT(son_arrays_iguales(
		1, /* Elementos en el array */
		uno_dos_y_tres,
		(uint64_t[]) { 0, 0 }
	))
	free(uno_dos_y_tres);

	uint64_t* uno_y_dos_y_tres =
		tareas_completadas_por_proyecto(LISTA(
			PROYECTO(1), PROYECTO(2), PROYECTO(3)
		));
	TEST_ASSERT(son_arrays_iguales(
		1, /* Elementos en el array */
		uno_y_dos_y_tres,
		(uint64_t[]) { 0, 0, 0 }
	))
	free(uno_y_dos_y_tres);
}

TEST(tareas_completadas_por_proyecto_ejemplos_del_enunciado) {
	// NOTA: El test de ejemplo1 realmente no está testeando mucho.
	uint64_t* ejemplo1 = tareas_completadas_por_proyecto(NULL);
	TEST_ASSERT(son_arrays_iguales(0, ejemplo1, (uint64_t[]){}))
	free(ejemplo1);

	uint64_t* ejemplo2 = tareas_completadas_por_proyecto(LISTA(PROYECTO()));
	TEST_ASSERT(son_arrays_iguales(1, ejemplo2, (uint64_t[]){ 0 }))
	free(ejemplo2);

	uint64_t* ejemplo3 = tareas_completadas_por_proyecto(LISTA(PROYECTO(), PROYECTO()));
	TEST_ASSERT(son_arrays_iguales(2, ejemplo3, (uint64_t[]){ 0, 0 }))
	free(ejemplo3);

	uint64_t* ejemplo4 = tareas_completadas_por_proyecto(LISTA(PROYECTO(1, 2, 3)));
	TEST_ASSERT(son_arrays_iguales(1, ejemplo4, (uint64_t[]){ 0 }))
	free(ejemplo4);

	uint64_t* ejemplo5 = tareas_completadas_por_proyecto(LISTA(PROYECTO(0, 2, 0)));
	TEST_ASSERT(son_arrays_iguales(1, ejemplo5, (uint64_t[]){ 2 }))
	free(ejemplo5);

	uint64_t* ejemplo6 = tareas_completadas_por_proyecto(LISTA(PROYECTO(1, 2), PROYECTO(3, 4)));
	TEST_ASSERT(son_arrays_iguales(2, ejemplo6, (uint64_t[]){ 0, 0 }))
	free(ejemplo6);

	uint64_t* ejemplo7 = tareas_completadas_por_proyecto(LISTA(PROYECTO(1, 2), PROYECTO(0, 0)));
	TEST_ASSERT(son_arrays_iguales(2, ejemplo7, (uint64_t[]){ 0, 2 }))
	free(ejemplo7);

	uint64_t* ejemplo8 = tareas_completadas_por_proyecto(LISTA(PROYECTO(1, 0), PROYECTO(0, 4)));
	TEST_ASSERT(son_arrays_iguales(2, ejemplo8, (uint64_t[]){ 1, 1 }))
	free(ejemplo8);
}

int main(void) {
	printf("= Tests de proyecto_mas_dificil(lista_t*)\n");
	printf("=========================================\n");
	proyecto_mas_dificil_de_lista_vacia_cuesta_0();
	proyecto_mas_dificil_si_no_hay_tareas_es_0();
	proyecto_mas_dificil_con_una_sola_tarea_es_esa();
	proyecto_mas_dificil_usa_la_suma();
	proyecto_mas_dificil_calcula_el_maximo();
	proyecto_mas_dificil_ignora_vacios();
	proyecto_mas_dificil_ejemplos_del_enunciado();
	printf("\n");

	printf("= Tests de marcar_tarea_completada(lista_t*, size_t)\n");
	printf("====================================================\n");
	marcar_tarea_completada_accede_al_primero_como_array();
	marcar_tarea_completada_puede_atravesar_la_lista();
	marcar_tarea_completada_actualiza_la_suma();
	marcar_tarea_completada_ignora_proyectos_vacios();
	marcar_tarea_completada_ejemplos_del_enunciado();
	printf("\n");


	printf("= Tests de tareas_completadas_por_proyecto(lista_t*, size_t)\n");
	printf("============================================================\n");
	tareas_completadas_por_proyecto_proyecto_vacio_da_cero();
	tareas_completadas_por_proyecto_cuenta_ceros_si_son_todos_ceros();
	tareas_completadas_por_proyecto_no_cuenta_no_ceros();
	tareas_completadas_por_proyecto_ejemplos_del_enunciado();
	printf("\n");

	tests_end();
	return 0;
}
