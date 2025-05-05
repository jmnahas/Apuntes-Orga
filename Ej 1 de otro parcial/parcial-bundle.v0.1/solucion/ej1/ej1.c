#include "ej1.h"

nodo_display_list_t* inicializar_nodo(
  uint8_t (*primitiva)(uint8_t x, uint8_t y, uint8_t z_size),
  uint8_t x, uint8_t y, nodo_display_list_t* siguiente) {
    nodo_display_list_t* nodo = malloc(sizeof(nodo_display_list_t));
    nodo->primitiva = primitiva;
    nodo->x = x;
    nodo->y = y;
    nodo->z = 255;
    nodo->siguiente = siguiente;
    return nodo;
}

ordering_table_t* inicializar_OT(uint8_t table_size) {
  ordering_table_t* res = malloc(sizeof(ordering_table_t));
  res->table_size = table_size;
  if(table_size == 0){
    res->table = NULL;
  } else{
    nodo_ot_t** table = calloc(table_size, sizeof(nodo_ot_t*)); //Inicializa la lista en NULL
    res->table = table;
  }
  return res;
}

//Calcula el Z de UN SOLO nodo
void calcular_z(nodo_display_list_t* nodo, uint8_t z_size) {
  nodo->z = nodo->primitiva(nodo->x, nodo->y, z_size);  
}

void ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) {
  while(display_list != NULL){
    calcular_z(display_list, ot->table_size);
    
    uint8_t z = display_list->z;
    
    nodo_ot_t* nodos_z = ot->table[z];

    //Si la ot->table[z] no tiene ningun elemento
    if(ot->table[z] == NULL){
      nodo_ot_t* primer_nodo = malloc(sizeof(nodo_ot_t));
      primer_nodo->display_element = display_list;
      primer_nodo->siguiente = NULL;
      ot->table[z] = primer_nodo;
    } 
    else{
      while(nodos_z->siguiente != NULL){
        nodos_z = nodos_z->siguiente;
      }

      nodo_ot_t* nuevo_nodo = malloc(sizeof(nodo_ot_t));

      nodos_z->siguiente = nuevo_nodo;

      nuevo_nodo->siguiente = NULL;

      nuevo_nodo->display_element = display_list;
    }
    display_list = display_list->siguiente;        
  }
}
