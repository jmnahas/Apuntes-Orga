extern malloc
extern free 

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16
TAMANIO_MAPA EQU 255*255
TAMANIO_PUNTERO EQU 8
CANT_COLUMNAS EQU 255

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = mapa_t           mapa
	; r/m64 = attackunit_t*    compartida
	; r/m64 = uint32_t*        fun_hash(attackunit_t*)

	; typedef struct {
	; 	char clase[11];      	11 bytes + 1 de padding
	; 	uint16_t combustible; 	2 bytes
	; 	uint8_t references;  	1 byte + 1 de padding
	; } attackunit_t;  			16 bytes

	;rdi = puntero a matriz mapa
	;rsi = puntero a la unidad a optimizar
	;rdx = puntero a funcion para hash

	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	mov r15, rdi	; r15 = puntero a los punteros del mapa
	mov r14, rsi	; r14 = puntero a la unidad
	mov r13, rdx	; r13 = función hash
	xor r12, r12	; contador iteraciones
	mov rbx, TAMANIO_MAPA

	mov rdi, rsi	; pasamos por parametro a la función la unidad que vamos a optimizar

	; llamamos a la función hash	
	
	call r13

	mov rsi, rax	;rsi = hash de la unidad a optimizar
	
	
	ciclo_a:
		cmp r12, rbx 
		je fin_ciclo_a

		mov rdi, [r15 + r12*TAMANIO_PUNTERO] ; rdi = mapa[r8]
		;no se puede acceder a memoria 0, siempre que trabaje con listas de punteros chequeo donde voy antes de entrar

		cmp rdi, 0
		JE prox_iteracion
		cmp rdi, r14
		JE prox_iteracion

		push rsi
		push rdi
		
		call r13	;rax = hash de la unidad actual

		pop rdi
		pop rsi
		
		cmp eax, esi		
		je optimizar_unidad
	prox_iteracion:
			inc r12		
			jmp ciclo_a
			
	optimizar_unidad:
		;matriz apunte a r14 en vez de a unidad sin optimizar
		;cantidad referencia unidad a optimizar ++aa
		;free puntero unidad[i] viejo
		inc byte [r14 + ATTACKUNIT_REFERENCES]
		mov rdi, [r15 + r12 * TAMANIO_PUNTERO]
		dec byte [rdi + ATTACKUNIT_REFERENCES]
		;si la cantidad de referencias de la unidad vieja es 0, free
		mov [r15 + R12 * TAMANIO_PUNTERO], r14	;entras a la matriz y reemplazas el puntero viejo por el nuevo
		
		cmp byte [rdi + ATTACKUNIT_REFERENCES], 0
		je free_unidad_vieja
		jmp ciclo_a

	free_unidad_vieja:
		push rsi
		sub rsp, 8

		call free

		add rsp, 8
		pop rsi

		inc r12
		jmp ciclo_a

	fin_ciclo_a:

		add rsp, 8
		pop rbx
		pop r12
		pop r13
		pop r14
		pop r15
		
		pop rbp
		ret
		
		
		
global contarCombustibleAsignado
contarCombustibleAsignado:
	; r/m64 = mapa_t           mapa
	; r/m64 = uint16_t*        fun_combustible(char*)
	; mapa_t -> RDI
	; puntero a función -> RSI
	
	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push r12
	push rbx
	sub rsp, 8

	mov r15, rdi	; r15 = puntero al mapa
	mov r14, rsi	; r14 = puntero a la función
	xor r13, r13	; contador iteraciones
	xor r12, r12	; contador de combustible
	xor rax, rax
	
	ciclo_b:
		cmp r13, TAMANIO_MAPA
		je fin_ciclo_b

		mov rdi, [r15 + r13 * TAMANIO_PUNTERO]	; rdi = mapa[r8]
		;no se puede acceder a memoria 0, siempre que trabaje con listas de punteros chequeo donde voy antes de entrar

		cmp rdi, 0			; reviso que el puntero no sea nulo
		JE prox_iteracion_b

		push rdi
		sub rsp, 8	

		call r14	; rax = combustible base de la unidad actual

		add rsp, 8
		pop rdi	
		
		xor r11, r11
		mov r11w, word [rdi + ATTACKUNIT_COMBUSTIBLE]
		sub r11, rax
		add r12, r11	; sumo el combustible de la unidad a la variable de combustible total

	prox_iteracion_b:
		inc r13
		jmp ciclo_b
	
	fin_ciclo_b:
		mov rax, r12	; retorno el combustible total

		add rsp, 8
		pop rbx
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbp
		ret


global modificarUnidad
modificarUnidad:
	; r/m64 = mapa_t           mapa
	; r/m8  = uint8_t          x
	; r/m8  = uint8_t          y
	; r/m64 = void*            fun_modificar(attackunit_t*)

	; puntero a punteros del mapa -> RDI
	; coordenada x -> RSI
	; coordenada y -> RDX
	; puntero a función -> RCX

	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push r12

	imul rsi, CANT_COLUMNAS		; rdx = x * 255
	add rdx, rsi				; rdx = y + 255 * x
	imul rdx, TAMANIO_PUNTERO	; rdx = (y + 255 * x) * 8	->	este es el desplazamiento correcto para acceder al puntero en la matriz
	

	mov r15, rdi	; r15 = puntero a punteros del mapa
	xor r14, r14
	mov r13, rdx	; r13 = posición en el mapa
	mov r12, rcx	; r12 = puntero a la función

	mov rdi, [r15 + r13]	; r14 = puntero a la unidad en la posición (x,y)

	cmp rdi, 0
	je fin_modificar_unidad	; veo si mi puntero es nulo
	; no se puede acceder a memoria 0, siempre que trabaje con listas de punteros chequeo donde voy antes de entrar
	; si el puntero es nulo no hago nada

	mov r14b, byte [rdi + ATTACKUNIT_REFERENCES]
	cmp r14b, 1
	jg instancia_compartida ; si la unidad tiene más de una referencia, creo un nuevo struct para no modificar el resto

	modificar_unidad:
		call r12		; llamo a la función de modificación sabiendo que el puntero a la unidad a modificar está en rdi

		jmp fin_modificar_unidad

	instancia_compartida:
		dec byte [rdi + ATTACKUNIT_REFERENCES]	; resto una referencia a la instancia compartida
	instancia_individual:
		mov r14, rdi							; r14 = puntero a la unidad a modificar
		mov rdi, ATTACKUNIT_SIZE				; rdi = tamaño de la unidad (para reservar el espacio en memoria del nuevo struct)
		call malloc								; rax = puntero a la nueva unidad
		
		; copio el contenido de la unidad compartida a la nueva unidad
		mov r8, qword [r14]		; copio los primeros 8 bytes (qword) en la nueva unidad
		mov qword [rax], r8
		mov r8, qword [r14 + 8]	; copio los segundos 8 bytes (qword) en la nueva unidad
		mov qword [rax + 8], r8
		; también se puede hacer la copia con memcpy que toma 3 parámetros (puntero destino, puntero origen y tamaño), pero no sé si se pude usar

		mov byte [rax + ATTACKUNIT_REFERENCES], 1	; la nueva unidad tiene una sola referencia

		mov rdi, rax							; rdi = guardo puntero a la nueva unidad en rdi para pasarlo a la función como parámetro
		mov [r15 + r13], rdi					; reemplazo el antiguo puntero (instancia) en la matriz por el nuevo puntero

		jmp modificar_unidad

	
	fin_modificar_unidad:
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbp
		ret