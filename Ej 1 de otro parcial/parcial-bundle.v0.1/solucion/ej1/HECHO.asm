section .rodata
%define NODO_DISPLAY_LIST_PRIMITIVA_OFFSET 0
%define NODO_DISPLAY_LIST_X_OFFSET 8
%define NODO_DISPLAY_LIST_Y_OFFSET 9
%define NODO_DISPLAY_LIST_Z_OFFSET 10
%define NODO_DISPLAY_LIST_SIGUIENTE_OFFSET 16
%define NODO_DISPLAY_LIST_SIZE 24

%define NODO_OT_DISPLAY_OFFSET 0
%define NODO_OT_SIGUIENTE_OFFSET 8
%define NODO_OT_SIZE 16

%define OT_TABLE_SIZE_OFFSET 0
%define OT_TABLE_OFFSET 8
%define OT_SIZE 16

section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free
extern calloc


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
;RDI = table_size
inicializar_OT_asm:
    ;epilogo
    push rbp
    mov rbp, rsp
    
    ;guardamos el valor de r12
    push r12

    ;guardamos el valor de r13
    push r13

    ;Ponemos table_size en r12 para no perderlo
    xor r12, r12
    mov r12b, dil

    ;Reservamos el espacio para ordering_table_t*
    ;malloc(sizeof(ordering_table_t))
    xor rdi, rdi
    mov rdi, OT_SIZE
    call malloc ;RAX = res

    ;Movemos res a r13 para no perderlo
    mov r13, rax

    ;Ponemos el valor de table_size dentro del struct
    mov byte [r13 + OT_TABLE_SIZE_OFFSET], r12b

    ;Reservamos el espacio para un array de punteros de tamaño table_size
    ;Este espacio es table_size * sizeof(nodo_ot_t*) = table_size * 8
    ;Vamos a inicializarlo vacio con calloc
    xor rdi, rdi
    mov rdi, r12
    
    xor rsi, rsi
    mov rsi, 8
    
    cmp rdi, 0
    je set_table_NULL

    call calloc ;RAX apunta al array de punteros a nodo_ot INICIALIZADO EN 0

    mov qword [r13 + OT_TABLE_OFFSET], rax
    jmp prologo

    set_table_NULL:
    mov qword [r13 + OT_TABLE_OFFSET], 0
    jmp prologo


    prologo:
    ;Movemos res a RAX
    mov rax, r13
    
    ;prologo
    pop r13
    pop r12
    pop rbp
    ret

;void calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size)
;RDI = nodo, RSI = z_size
;Calcular el z PARA UN SOLO nodo
calcular_z_asm:
    ;prologo
    push rbp
    mov rbp, rsp

    ;Guardamos registros no volatiles
    push r12
    push r13

    ;Guardamos el nodo actual para que no se pierda
    mov r12, rdi

    ;Guardamos el z_size para que no se pierda
    xor r13, r13
    mov r13b, sil

    ;Tenemos que llamar a la funcion primitiva del nodo
    ;Ponemos x en rdi, y en rsi , z_size en rdx
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

    mov dil, byte[r12 + NODO_DISPLAY_LIST_X_OFFSET]
    mov sil, byte[r12 + NODO_DISPLAY_LIST_Y_OFFSET]
    mov dl, r13b

    ;Llamamos a la funcion primitva del nodo
    call [r12 + NODO_DISPLAY_LIST_PRIMITIVA_OFFSET]
    ;AL = z

    ;Ponemos el valor de z donde corresponde
    mov byte [r12 + NODO_DISPLAY_LIST_Z_OFFSET], al 

    ;epilogo
    pop r13
    pop r12
    pop rbp
    ret

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
;RDI = ot , RSI = display_list 
ordenar_display_list_asm:
    ;prologo
    push rbp
    mov rbp, rsp

    ;Guardamos registros no volatiles
    push r12
    push r13
    push r14
    push r15

    mov r12, rsi ;r12 = nodo_display_actual
    mov r13, rdi ;r13 = OT
    
    ;Iteramos sobre display list
    ciclo_display_list:
        cmp r12, 0
        je fin_ciclo_display_list

        ;Calculamos su valor z
        mov rdi, r12
        xor rsi, rsi
        mov sil, byte[r13 + OT_TABLE_SIZE_OFFSET]

        call calcular_z_asm 

        ;Movemos z a un registro
        xor r15, r15
        mov r15b, [r12 + NODO_DISPLAY_LIST_Z_OFFSET]

        ;Iterar sobre table[z]
        ;[r13 + OT_TABLE_OFFSET]             = Puntero a la primera posicion de un arreglo de punteros
        ;[[r13 + OT_TABLE_OFFSET]]           = Primera posicion del arreglo de punteros
        ;[[r13 + OT_TABLE_OFFSET] + z * 8]   = z-esima posicion del arreglo de punteros
        ;[[[r13 + OT_TABLE_OFFSET] + z * 8]] = Primer nodo OT de la z-esima posicion del arreglo
        xor rax, rax
        mov rax, 8
        mul r15 ;RAX = 8*z

        mov r14, [r13 + OT_TABLE_OFFSET] ;r14 = Puntero a la primera posicion de un arreglo de punteros
        
        ;Si [r14 + rax] es NULL => table[z] esta vacia, hay que hacer un caso aparte
        cmp qword [r14 + rax], 0
        je table_z_vacia

        ;Si llego aca es porque table[z] tiene por lo menos un elemento
        table_z_no_vacia:
            mov r14, [r14 + rax] ;r14 = z-esimo elemento del arreglo

            ;Iteramos sobre table[z]
            ;while sig != NULL
            ciclo_table_z:
                cmp qword [r14 + NODO_OT_SIGUIENTE_OFFSET], 0
                je fin_ciclo_table_z

                ;nodo_OT = nodo_OT->siguiente
                mov r14, qword [r14 + NODO_OT_SIGUIENTE_OFFSET]
                jmp ciclo_table_z
            fin_ciclo_table_z:

            ;Ahora r14 tiene una direccion de memoria en la que hay un nodo_OT cuyo siguiente nodo es NULL

            ;Creamos el nuevo nodo_OT
            xor rdi, rdi
            mov rdi, NODO_OT_SIZE
            call malloc ;RAX = nodo_OT*

            ;Ponemos el nodo_display_list en el nodo_OT
            mov qword [rax + NODO_OT_DISPLAY_OFFSET], r12

            ;Ponemos el siguiente en NULL
            mov qword [rax + NODO_OT_SIGUIENTE_OFFSET], 0

            ;Ponemos al nodo actual como siguiente del nodo anterior
            mov qword [r14 + NODO_OT_SIGUIENTE_OFFSET], rax
        jmp epilogo_ciclo_display_list

        table_z_vacia:
            ;Guardamos la direccion de table[z]
            xor r15, r15
            mov r15, r14
            add r15, rax

            ;Creamos el primer nodo_OT de table_z
            xor rdi, rdi
            mov rdi, NODO_OT_SIZE
            call malloc

            ;Ponemos el nodo_display_list en el nodo_OT
            mov qword [rax + NODO_OT_DISPLAY_OFFSET], r12

            ;Ponemos el siguiente en NULL
            mov qword [rax + NODO_OT_SIGUIENTE_OFFSET], 0

            ;Ponemos el nodo_ot al principio de table[z]
            mov qword [r15], rax
        jmp epilogo_ciclo_display_list

        epilogo_ciclo_display_list:
        ;nodo_display_actual = nodo_display_actual->siguiente
        mov r12, qword [r12 + NODO_DISPLAY_LIST_SIGUIENTE_OFFSET]

        jmp ciclo_display_list
    fin_ciclo_display_list:



    ;epilogo
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
