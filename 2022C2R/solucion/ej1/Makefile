CFLAGS += -Wall -Wextra -O0 -g -lm -Wno-unused-variable -Wno-unused-parameter -no-pie

all: tests_c tests_asm main_c main_asm

clean:
	rm -f tests_c tests_asm main_c main_asm tests.o main.o lista_c.o lista_asm.o

run_tests: tests_asm
	valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./tests_asm \
	&& echo "No se detectaron errores de memoria"

run_c_tests: tests_c
	valgrind --show-reachable=yes --leak-check=full --error-exitcode=1 ./tests_c \
	&& echo "No se detectaron errores de memoria"

tests_c: tests.o lista_c.o
	$(CC) $(CFLAGS) $^ -o $@

tests_asm: tests.o lista_asm.o
	$(CC) $(CFLAGS) $^ -o $@

main_c: main.o lista_c.o
	$(CC) $(CFLAGS) $^ -o $@

main_asm: main.o lista_asm.o
	$(CC) $(CFLAGS) $^ -o $@

lista_c.o: lista_c.c

lista_asm.o: lista_asm.asm
	nasm -f elf64 -g $^ -o $@

.PHONY: all clean run_tests run_c_tests
