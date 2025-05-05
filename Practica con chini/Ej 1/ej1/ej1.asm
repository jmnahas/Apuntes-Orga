extern malloc



section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
OFFSET_PUNTEROS EQU 8
OFFSET_indices EQU 2

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.


;typedef struct {
;    char nombre[18];		//OFFSET 0, tamaño 1*18 + 6 padding
;    uint32_t fuerza;		//OFFSET 24, tamaño 4 + 4 padding
;    uint16_t durabilidad;	//OFFSET 32, tamaño 2 + 6 padding
;} item_t


global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**     inventario
	; r/m64 = uint16_t*    indice
	; r/m16 = uint16_t     tamanio
	; r/m64 = comparador_t comparador
	

	;rdi = puntero al inventario
	;rsi = puntero a la lista de indices
	;edx = tamaño inventario
	;TAL VEZ HAYA QUE LIMPIAR 
	;rcx = puntero a la funcion comparadora
	
	;prologo
	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15
	;cantidad de push despues del rbp va de 2 en 2

	xor r8, r8
	xor r9, r9
	xor r11, r11
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15

	mov r12, rdi ;r12 = puntero a inventario
	mov r13, rsi ;r13 = puntero a indices

	and edx, 0x0000FFFF
	mov rax, 1
	mov r11w, dx ; r11 = tamanio
	sub r11, 1 ;comparo hasta longitud - 1 para no pasarme
	ciclo_indice_ord:
		cmp r8d, r11d		; r8 = cantidad de iteraciones
		je fin_de_ciclo

		;necesitamos para llamar a la funcion con rdi rsi
		mov r14w, [r13 + r8*OFFSET_indices]	; r14w = indice, ERA WORD PORQUE UN INDICE SOLO SON 2 BYTES

		mov rdi, [r12 + r14 * OFFSET_PUNTEROS]
		;rdi = inventario[indices[i]]
		
		add r8, 1

		mov r14w, [r13 + r8*OFFSET_indices]
		mov rsi, [r12 + r14 * OFFSET_PUNTEROS]
		;rsi = inventario[indices[i+1]]

		push r8
		push r11
		push rcx
		push r9

		call rcx
		
		pop r9
		pop rcx
		pop r11
		pop r8
		
		cmp rax, byte 0
		JE fin_de_ciclo

		jmp ciclo_indice_ord
	fin_de_ciclo:
		;epilogo
		pop r15
		pop r14
		pop r13
		pop r12
		
		pop rbp
		ret



;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario
	; r/m64 = uint16_t* indice
	; r/m16 = uint16_t  tamanio
	
	; rdi = inventario: Un array de punteros a ítems que representa el inventario a procesar.
	; rsi = indice: El arreglo de índices en el inventario que representa la vista.
	; rdx = tamanio: El tamaño del inventario (y de la vista).

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15		

	xor r15, r15
	xor r14, r14
	xor r13, r13
	xor r12, r12
	
	and rdx, 0x000000000000FFFF
	mov r12, rdi ; r12 = inventario
	mov r15, rsi ; r15 = indices
	mov rdi, rdx
	imul rdi, 8  ; rdi = tamaño * 8
	
	push rdx	 ; guardo el tamaño
	call malloc  ; rax = puntero a inventario nuevo
	pop rdx
	
	mov r13, rax ; r13 = puntero a inventario nuevo
	
	xor r8,r8 	 ;contador
	mov r9, rdx

	ciclo_b:
		cmp r8, r9
		JE fin_b
		
		mov r14w, [r15 + r8*OFFSET_indices]		; r14w = indices[i]
		mov rdi, [r12 + r14 * OFFSET_PUNTEROS]	; rdi = inventario[indices[i]]
		
		mov [r13 + r8 * OFFSET_PUNTEROS], rdi
		inc r8
		JMP ciclo_b
		
	fin_b:
		;epilogo
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

	

	

