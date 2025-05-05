%define OFFSET_NEXT  0
%define OFFSET_SUM   8
%define OFFSET_SIZE  16
%define OFFSET_ARRAY 24
%define OFFSET_LISTA 32

BITS 64

section .text


; uint32_t proyecto_mas_dificil(lista_t*)
;
; Dada una lista enlazada de proyectos devuelve el `sum` más grande de ésta.
;
; - El `sum` más grande de la lista vacía (`NULL`) es 0.
;
global proyecto_mas_dificil
proyecto_mas_dificil:
	; COMPLETAR
	;prologo
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push rbx
	push r15
	sub rsp, 8

	xor r12,r12 ;Contador de proyectos
	xor r13,r13 ;Proyecto mas dificil
	xor r14,r14 ;size de esta lista
	xor r15,r15 ;proyecto actual
	xor rax,rax ;sum del proyecto actual
	xor rbx,rbx 

	mov r13,0
	cmp rdi,0          ; Verifica si rdi es NULL
	je fin_ciclo_listas
	;lista_t* esta en rdi
	

	ciclo_listas:
		mov r14, [rdi + OFFSET_SIZE]
		cmp r14, 0
		JE prox_iteracion

		mov r15, [rdi + OFFSET_SUM]
		mov rax, r15 ;cargo el sum del proyecto

		cmp rax, r13 ;comparo el sum del proyecto con el maximo
		jg nuevo_maximo ;si el sum del proyecto es mayor, lo guardo

		prox_iteracion:
			mov r15, [rdi + OFFSET_NEXT]
			cmp r15, 0 ;si el puntero next es cero, termino la lista enlazada
			je fin_ciclo_listas

			mov rdi, [rdi + OFFSET_NEXT]
			jmp ciclo_listas

	nuevo_maximo:
		mov r13, rax ;guardo el nuevo maximo
		JMP prox_iteracion

	
	fin_ciclo_listas:
		mov rax, r13 ;guardo el maximo en rax

		add rsp,8
		pop r15
		pop rbx
		pop r14
		pop r13
		pop r12
		pop rbp
		ret
; typedef struct lista_s {
; 	struct lista_s*  next; 8 bytes 
; 	uint32_t  sum; 4 bytes + 4 de padding
; 	uint64_t  size; 8 bytes
; 	uint32_t* array; 8 bytes
; } lista_t; Total: 32 bytes

; void tarea_completada(lista_t*, size_t)
;
; Dada una lista enlazada de proyectos y un índice en ésta setea la i-ésima
; tarea en cero.
;
; - La implementación debe "saltearse" a los proyectos sin tareas
; - Se puede asumir que el índice siempre es válido
; - Se debe actualizar el `sum` del nodo actualizado de la lista
;
global marcar_tarea_completada
marcar_tarea_completada:
	; COMPLETAR
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push rbx
	push r15
	sub rsp, 8

	xor r12,r12 
	xor r13,r13 ;
	xor r14,r14 ;size de esta lista
	xor r15,r15 ;proyecto actual
	xor rax,rax ;sum del proyecto actual
	xor rbx,rbx 

	mov r13,0
	cmp rdi,0          ; Verifica si rdi es NULL
	je fin_ciclo_listas2
	;lista_t* esta en rdi
	

	ciclo_listas2:
		mov r14, [rdi + OFFSET_SIZE]
		cmp r14, 0
		JE prox_iteracion2
										;r14 = tamaño array
		mov r15 , [rdi + OFFSET_ARRAY]  ;r15 = array dentro del nodo
		xor r12, r12					;r12 = contador iteraciones
		ciclo_interior:
			cmp r12, r14
			JE prox_iteracion2

			cmp r13, rsi ;comparo si i == elemento actual
			je tarea_completa ;si el sum del proyecto es mayor, lo guardo

			inc r12
			inc r13
			jmp ciclo_interior
		prox_iteracion2:
			mov r15, [rdi + OFFSET_NEXT]
			cmp r15, 0 ;si el puntero next es cero, termino la lista enlazada
			je fin_ciclo_listas2
			
			mov rdi, [rdi + OFFSET_NEXT]
			jmp ciclo_listas2


	tarea_completa:
		imul r12,4
		xor r9, r9
		xor r10, r10
		mov r9d, dword [rdi + OFFSET_SUM]
		mov r10d, dword [r15 + r12]
		sub r9d, r10d
		mov dword [rdi + OFFSET_SUM], r9d
		mov dword [r15 + r12], 0
		JMP fin_ciclo_listas2

	
	fin_ciclo_listas2:

		add rsp,8
		pop r15
		pop rbx
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

; uint64_t* tareas_completadas_por_proyecto(lista_t*)
;
; Dada una lista enlazada de proyectos se devuelve un array que cuenta
; cuántas tareas completadas tiene cada uno de ellos.
;
; - Si se provee a la lista vacía como parámetro (`NULL`) la respuesta puede
;   ser `NULL` o el resultado de `malloc(0)`
; - Los proyectos sin tareas tienen cero tareas completadas
; - Los proyectos sin tareas deben aparecer en el array resultante
; - Se provee una implementación esqueleto en C si se desea seguir el
;   esquema implementativo recomendado
;
global tareas_completadas_por_proyecto
tareas_completadas_por_proyecto:
	; COMPLETAR
	ret

; uint64_t lista_len(lista_t* lista)
;
; Dada una lista enlazada devuelve su longitud.
;
; - La longitud de `NULL` es 0
;
lista_len:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
	ret

; uint64_t tareas_completadas(uint32_t* array, size_t size) {
;
; Dado un array de `size` enteros de 32 bits sin signo devuelve la cantidad de
; ceros en ese array.
;
; - Un array de tamaño 0 tiene 0 ceros.
tareas_completadas:
	; OPCIONAL: Completar si se usa el esquema recomendado por la cátedra
