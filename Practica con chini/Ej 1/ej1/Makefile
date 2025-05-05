AS = nasm
ASFLAGS = -felf64 -Fdwarf -g
LDFLAGS = -lm
CFLAGS= -Wall -Wextra -pedantic -O0 -g -Wno-unused-variable -Wno-unused-parameter -no-pie -z noexecstack

# Crea los binarios en cuestión
all: test_c test_asm

# Corre los tests usando la implementación en C
run_c: test_c
	./test_c

# Corre los tests usando la implementación en ASM
run_asm: test_asm
	./test_asm

# Corre los tests en valgrind usando la implementación en C
valgrind_c: test_c
	valgrind  --show-reachable=yes --leak-check=full --error-exitcode=1 ./test_c \
	&& echo "No se detectaron errores de memoria"

# Corre los tests en valgrind usando la implementación en ASM
valgrind_asm: test_asm
	valgrind  --show-reachable=yes --leak-check=full --error-exitcode=1 ./test_asm \
	&& echo "No se detectaron errores de memoria"

# Borra todos los archivos generados
clean:
	rm -f test_c test_asm ej1_asm.o

test_c: test.c ej1.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

test_asm: test.c ej1_asm.o
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

ej1_asm.o: ej1.asm
	$(AS) $(ASFLAGS) $^ -o $@

.PHONY: clean run_c run_asm valgrind_c valgrind_asm

