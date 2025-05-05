#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

static size_t test__count = 0;
static size_t test__succeed__count = 0;

#define TEST(name)                                            \
void name##__impl(const char* test__name, bool* test__fallo); \
void name() {                                                 \
	test__count++;                                        \
	const char* test__name = #name;                       \
	bool test__fallo = false;                             \
	printf("- %s", test__name);                           \
	name##__impl(test__name, &test__fallo);               \
	if (!test__fallo) {                                   \
		test__succeed__count++;                       \
		printf(" OK\n");                              \
	}                                                     \
}                                                             \
void name##__impl(const char* test__name, bool* test__fallo)

#define TEST_ASSERT(cond)                                           \
	if (!(cond)) {                                              \
		printf(" FAILED\n");                                \
		printf("    fallo en %s:%d\n", __FILE__, __LINE__); \
		printf("        %s\n", #cond);                      \
		*test__fallo = true;                                \
		return;                                             \
	}

static inline void tests_end() {
	printf(
		"Pasaron %ld de %ld tests\n",
		test__succeed__count,
		test__count
	);
	if (test__count == test__succeed__count) {
		printf("¡Pasaron todos los tests!\n");
		exit(0);
	} else {
		printf("Fallaron algunos tests.\n");
		exit(1);
	}
}

