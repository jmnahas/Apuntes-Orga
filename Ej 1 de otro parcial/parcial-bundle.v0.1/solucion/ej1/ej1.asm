section .rodata


section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free
extern calloc

; La famosa consola de videojuegos Orga2-station se diseñó de forma que para dibujar los gráficos,
; recorra una lista enlazada llamada Display List que contiene información de cada elemento a renderizar.
; Cada nodo de dicha lista, llamado nodo_display_list_t, contiene las coordenadas x,y,z (siendo z
; la profundidad en la escena a renderizar) y un puntero a la función a utilizar para determinar el valor
; de z.
; Para dibujar una escena correctamente es necesario dibujar los nodos que están más lejos de la
; pantalla, esto es, dibujar primero aquellos con un valor en z más alto.
; 1
; Para evitar recorrer la lista entera varias veces, se utiliza una Ordering Table o Tabla de Ordena-
; miento. Esta estructura mantiene referencias ordenadas por su valor de z a los nodos a dibujar de la
; Display List.
; En otras palabras, una Ordering Table (OT a partir de ahora) es una lista enlazada diseñada para
; agrupar primitivas de gráficos 3D según su ubicación en el eje Z. Primero se dibujan los más lejanos
; y luego los más cercanos (es decir, se dibujan ordenados según z de mayor a menor).
; La OT usa un array fijo como ancla para cada posible valor en Z, evitando así tener que recorrer
; la lista enlazada una vez para cada valor de Z. El tamaño del array determinará cuántos puntos en Z
; puede haber. Por ejemplo, si el array tiene 10 posiciones, entonces habrá 10 ”profundidades” a dibujar.
; En esta consola, el tamaño es variable según el juego, por lo que no sabemos de antemano cuánta
; memoria utilizará.
; Cada primitiva calcula la posición z a partir de las coordenadas x,y, además el valor resultante de
; Z se redondea para utilizarse como índice del OT.
; Si todo fue calculado correctamente, con llamar una sola vez a la función para dibujar en pantalla,
; el motor de dibujo de la Orga2-station renderizará sin errores.
; Cada nodo de la lista enlazada Display List tiene la siguiente forma:
; typedef struct {
; // Puntero a la función que calcula z (puede ser distinta para cada nodo):
; uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size);
; // Coordenadas del nodo en la escena:
; uint8_t x;
; uint8_t y;
; uint8_t z;
; //Puntero al nodo siguiente:
; nodo_display_list_t* siguiente;
; } nodo_display_list_t;
; Por otro lado, la OT está definida como:
; typedef struct {
; uint8_t table_size;
; nodo_ot_t** table;
; } ordering_table_t;
; y los nodos de la OT:
; typedef struct {
; nodo_display_list_t* display_element;
; nodo_ot_t* siguiente;
; } nodo_ot_t;
; Un esquema general de las estructuras mencionadas se muestra en la figura 1
; Se pide:
; Implementar en asm:
; 2
; Figura 1: Esquema de estructuras para el motor de dibujo de la consola Orga2-station.
; 3
; 1. La función que inicializa la Ordering Table. La aridad de la función es:
; ordering_table_t* inicializar_OT_asm(uint8_t z_size);
; 2. Una función llamada calcular_z que complete la coordenada z de cada nodo en función de su
; primitiva.
; La aridad de la función es:
; void* calcular_z_asm(nodo_display_list_t* nodo,
; uint8_t z_size);
; Aclaración: Los parámetros son:
; • nodo_display_list_t* nodo; un puntero al nodo.
; • uint8_t z_size; tamaño del array de OT o ”cantidad de profundidades” (utilizado para
; calcular z).
; La función deberá llamar a la primitiva de ese nodo (z=nodo.primitiva(x,y,z_size);) y
; completar el campo z de dicho nodo.
; Aclaración 2: Recordar que el z calculado va a ser menor al tamaño de la OT y (hint) puede
; ser utilizado como índice.
; 3. La función que coloca en la OT las referencias de la Display List. La aridad de la función es:
; void* ordenar_display_list_asm(ordering_table_t* ot,
; nodo_display_list_t* display_list);
; La función deberá calcular el z para dicho nodo, ubicar en la OT la lista correspondiente y
; agregar el nodo al final de la misma.
;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size);
;RDI = table_size
inicializar_OT_asm:
    ;epilogo
   

;void calcular_z_asm(nodo_display_list_t* nodo, uint8_t z_size)
;RDI = nodo, RSI = z_size
;Calcular el z PARA UN SOLO nodo
calcular_z_asm:
    ;prologo
    

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
;RDI = ot , RSI = display_list 
ordenar_display_list_asm:
    ;prologo