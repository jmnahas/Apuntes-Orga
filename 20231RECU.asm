global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
global son_iguales
extern malloc

TAMANIO EQU 4*10			; 4 bytes x la cantidad de int que devuelvo (10)
PAGO_OFFSET_MONTO EQU 0
PAGO_OFFSET_COMERCIO EQU 8
PAGO_OFFSET_CLIENTE EQU 16
PAGO_OFFSET_APROBADO EQU 17
TAMANIO_PAGOS_STRUCT EQU 24
TAMANIO_PUNTERO EQU 8


;########### SECCION DE TEXTO (PROGRAMA)
section .text

;typedef struct {
;	uint8_t monto;		1 byte + 7 padding
;	char *comercio;		8 bytes de puntero
;	uint8_t cliente;	1 byte 
;	uint8_t aprobado;	1 byte + 6 bytes padding
;} pago_t;				24 bytes

; Cada atributo estará alineado al tamaño de su tipo de dato, insertando padding entre ellos en caso de ser necesario.
; La estructura en sí se alineará al tamaño del tipo más grande de sus atributos.

acumuladoPorCliente_asm:
	push rbp
	mov rbp, rsp
	;rdi = cantpagos (en su 1er byte, dil)
	;rsi = puntero a array de pagos
	
	push rdi
	push rsi
	mov rdi, TAMANIO
	call malloc			; rax = puntero a array respuesta
	pop rsi
	pop rdi

	mov rcx, rax		; rcx = puntero a array respuesta
	xor r9, r9
	mov r9b, dil		; r9 = cantpagos
	xor rdx, rdx		;contador ciclo
	
	xor r8, r8
	xor rdi, rdi
	
	xor r11, r11
	inicializar_array:					; inicializo el array respuesta en 0
		cmp r11, 10
		JE ciclo_acumulado

		mov dword [rcx + r11*4], 0
		inc r11

		JMP inicializar_array
	xor r11, r11
	ciclo_acumulado:
		cmp dl, r9b
		JE fin_ciclo_acumulado

		push rdx
		imul rdx, 24		; i * 24 bytes

		mov r11b, [rsi + rdx + PAGO_OFFSET_APROBADO] 	; r11 = aprobacion pago
		cmp r11b, 0
		JE prox_iteracion_acumulado	; si no está aprobado, paso al siguiente pago
		
		mov r8b, byte [rsi + rdx + PAGO_OFFSET_MONTO] 	; r8 = monto compra
		mov dil, byte [rsi + rdx + PAGO_OFFSET_CLIENTE] ; rdi = cliente

		;cuando viajas dentro de la memoria [] solo usar registros de 64
		;multiplicaciones dentro de la memoria van de 1, 2, 4 u 8 (por ejemplo el rdx tiene que ser alguno de esos)

		imul rdi, 4				; rdi = cliente * 4
		add rcx, rdi			; rcx = puntero al array respuesta + posicion cliente actual
		xor r10, r10
		mov r10d, dword [rcx]	; r10d = monto acumulado cliente actual
		add r10, r8				; r10 = monto acumulado cliente actual + monto compra

		mov dword [rcx], r10d
		
		mov rcx, rax			; rcx = puntero al inicio del array respuesta

		prox_iteracion_acumulado:
			pop rdx
			inc dl
			JMP ciclo_acumulado
	
	fin_ciclo_acumulado:
		pop rbp
		ret

; uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n)
; char* comercio = RDI
; char** lista_comercios = RSI
; uint8_t n = DL
en_blacklist_asm:
	push rbp
	mov rbp, rsp

	xor r10, r10
	mov r10, RSI	; r10 = char** lista_comercios

	xor r9, r9
	mov r9b, dl		; r9 = longitud de lista_comercios

	xor r8, r8		; r8 = contador iteraciones

	xor rax, rax	; inicializo rax en 0

	ciclo_1b:
		cmp r8, r9	; veo si llegué a la longitud de la lista
		je fin_1b

		mov rsi, [r10 + r8 * TAMANIO_PUNTERO]	; rsi = puntero actual

		push r10
		push r9
		push r8
		push rdi

		; char* comercio = RDI
		; char* lista_comercios = RSI

		call son_iguales

		pop rdi
		pop r8
		pop r9
		pop r10

		cmp rax, 1
		je fin_1b		; si rax = 1 -> comercio pertenece a lista_comercios y termino

		inc r8
		jmp ciclo_1b

	fin_1b:
		pop rbp
		ret

; ; función que toma dos parámetros (char*) y devuelve TRUE si son iguales y FALSE en caso contrario
son_iguales:
	push rbp
	mov rbp, rsp

	mov rax, 1			; inicializo rax en 1
	xor rdx, rdx
	xor rcx, rcx

	loop_son_iguales:
		mov dl, byte [RDI]
		mov cl, byte [RSI]

		cmp rdx, 0			; veo si RDI terminó
		jne verificar_rcx	; si no terminó verifico si RSI terminó

		cmp rcx, 0
		jne son_distintos	; veo si alguna de las dos strings llegó al final

		jmp fin_son_iguales

	verificar_rcx:
		cmp rcx, 0
		je son_distintos	; si RSI terminó y RDI no, entonces RSI != RDI
		cmp rdx, rcx
		jne son_distintos	; veo si el char actual es igual
		
		inc rdi
		inc rsi
		jmp loop_son_iguales

	son_distintos:
		mov rax, 0

	fin_son_iguales:
		pop rbp
		ret

; pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);

; cantidad_pagos -> RDI
; pago_t* arr_pagos -> RSI
; char** lista_comercios -> RDX
; longitud lista_comercios -> RCX

blacklistComercios_asm:
	push rbp
	mov rbp, rsp

	push rbx
	push r15
	push r14
	push r13
	push r12

	mov r15, rdi	; r15 = cantidad_pagos
	mov r14, rsi	; r14 = arr_pagos
	mov r13, rdx	; r13 = lista_comercios
	

	imul rdi, TAMANIO_PUNTERO	; rdi = cantidad_pagos * tamaño de un puntero (8 bytes), reservo la máxima cantidad de memoria que se que puedo llegar a utilizar porque no sé exactamente cuánta voy a usar
	add rdi, 8
	
	push rcx
	call malloc		; rax = puntero al array respuesta
	pop rcx
	sub rsp, 8

	xor r10, r10
	mov r10, rax	; r10 = puntero al array respuesta

	xor r8, r8		; r8 = contador
	xor r9, r9		; r9 = longitud del array respuesta
	xor rbx, rbx
	loop_blacklist:
		cmp r8, r15	; cuando ya recorrí todos los pagos termino
		je fin_blacklist

		mov r11, r8
		imul r11, TAMANIO_PAGOS_STRUCT	; r11 = tamaño del struct * cantidad de iteraciones, me lleva al struct actual

		mov rbx, r11
		add rbx, PAGO_OFFSET_COMERCIO	; rbx = tamaño del struct * cantidad de iteraciones + offset
		mov rdi, [r14 + rbx]			; rdi = char* comercio actual

		mov rsi, r13
		mov	rdx, rcx	; rdi = char*, rsi = char**, rdx = uint8_t (listos los parámetros para llamar a la función anterior)


		push rcx
		push r11
		push r10
		push r9
		push r8
		sub rsp, 8

		call en_blacklist_asm	; rax = 1 si el comercio está blacklisteado, 0 en caso contrario

		add rsp, 8
		pop r8
		pop r9
		pop r10
		pop r11
		pop rcx

		cmp rax, 0
		jne comercio_blacklisteado

		inc r8
		jmp loop_blacklist

	comercio_blacklisteado:
		mov rdi, [r14 + r11]	; rdi = puntero pago blacklisteado actual

		mov rsi, TAMANIO_PUNTERO
		imul rsi, r9			; rsi = 8 bytes * longitud del array respuesta, me lleva al actualmente último puntero

		mov [r10 + rsi], rdi	; cargo el pago blacklisteado en el array respuesta

		inc r9					; incremento la longitud de mi array respuesta
		inc r8
		jmp loop_blacklist

	fin_blacklist:
		mov qword [r10 + r9*TAMANIO_PUNTERO], 0	; declaro el último puntero del array como nulo para marcar el fin de la respuesta
		mov rax, r10							; rax = puntero al array respuesta
		add rsp, 8
		pop r12
		pop r13
		pop r14
		pop r15
		pop rbx

		pop rbp
		ret
