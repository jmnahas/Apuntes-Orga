# Primer parcial - Arquitectura y Organización de Computadoras
#### Segundo cuatrimestre 2024

## Normas generales y modalidad de entrega

- El parcial es **INDIVIDUAL**
- Una vez terminada la evaluación se deberá crear un issue con el *hash* del
  *commit* de entrega.

## Régimen de Aprobación

- Para aprobar el examen es necesario obtener como mínimo **un ejercicio
  aprobado y un ejercicio regular**.
- Para conservar la posibilidad de promocionar es condición necesaria obtener
  como mínimo **dos ejercicios aprobados**, _sólo se aceptarán errores
  menores_.

## Actualización del fork individual

Es importante que, para esta instancia de parcial y próximas, **no creen un nuevo fork de este repositorio** si no que actualicen el mismo fork individual que estaban utilizando para el tp0.

Los pasos para actualizar el repositorio son los mismos que siguieron para el TP1-b y TP1-c, pero ante cualquier duda pueden consultarlos en el archivo [como_actualizar.md (link)](https://git.exactas.uba.ar/ayoc-doc/individual-2c2024/-/blob/master/p1/como_actualizar.md) de esta carpeta.

## Compilación y Testeo

Para compilar y ejecutar los tests cada ejercicio dispone de un archivo
`Makefile` con los siguientes *targets*:

| Comando             | Descripción                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `make test_c`       | Genera el ejecutable usando la implementación en C del ejercicio.   |
| `make test_asm`     | Genera el ejecutable usando la implementación en ASM del ejercicio. |
| `make run_c`        | Corre los tests usando la implementación en C.                      |
| `make run_asm`      | Corre los tests usando la implementación en ASM.                    |
| `make valgrind_c`   | Corre los tests en valgrind usando la implementación en C.          |
| `make valgrind_asm` | Corre los tests en valgrind usando la implementación en ASM.        |
| `make clean`        | Borra todo archivo generado por el `Makefile`.                      |

El sistema de tests de este parcial **sólo correrá los tests que hayan marcado
como hechos**. Para esto deben modificar la variable `EJERCICIO_xx_HECHO`
correspondiente asignándole `true` (en C) ó `TRUE` (en ASM). `xx` es el inciso
en cuestión: `1A`, `1B`, `2A`, `2B` ó `2C`.

# Ejercicio 1

Como parte del espectacular juego AAA llamado "AyOC 2 - La venganza de los
punteros" estamos diseñando su sistema de inventario. Los jugadores pueden tener
grandes cantidades de ítems en sus inventarios y quieren poder reordenarlos con
total fluidez. Debido a estos requisitos de performance se solicita implementar
en ensamblador algunas funciones del sistema de manipulación de inventarios.

La estructura utilizada para representar ítems es la siguiente:
```c
typedef struct {
    char nombre[18];
    uint32_t fuerza;
    uint16_t durabilidad;
} item_t;
```

El inventario se implementa como un array de punteros a ítems. Nuevos ítems
siempre se agregan al final. La siguiente imagen ejemplifica el inventario:

![Ejemplo de inventario](img/inventario.png)

Uno de los requisitos más importantes es el de poder ver los ítems _más
fuertes_/_con menos daño_/_más baratos_/etc en simultáneo. Para lograr esto el
juego mantiene una serie de índices que indican la permutación necesaria para
mostrar el inventario según cada criterio.

Supongamos entonces que queremos mostrar la vista de ítems según daño:
```c
items_danio[i] = inventario[indices_danio[i]];
```

Si en su lugar quisiéramos verlos ordenados por durabilidad:
```c
items_durabilidad[i] = inventario[indices_durabilidad[i]];
```

Estos índices nos permiten mantener múltiples nociones de orden en simultáneo sin tener que mantener múltiples copias de los inventarios (alcanza con mantener los índices).

Hay muchísimos criterios de orden posibles por lo que además definimos un tipo
de dato para poder hablar de ellos:
```c
typedef bool (*comparador_t)(item_t*, item_t*);
``` 

## 1A - Detectar índices ordenados

Las vistas del inventario son editables y nos gustaría poder detectar cuando una
vista es equivalente a ordenar el inventario según una función de comparación.
Esto permitiría ahorrar memoria representando esas vistas como "el resultado de
ordenar la lista usando X" en lugar de tener que escribir todo el índice.

Para realizar esto se solicita implementar en ensamblador una función que
verifique si una vista del inventario está correctamente ordenada de acuerdo a
un criterio. La firma de la función a implementar es la siguiente:
```c
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);
```

Dónde:
- `inventario`: Un array de punteros a ítems que representa el inventario a
  procesar.
- `indice`: El arreglo de índices en el inventario que representa la vista.
- `tamanio`: El tamaño del inventario (y de la vista).
- `comparador`: La función de comparación que a utilizar para verificar el
  orden.

Tenga en consideración:
- `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
  como parámetro podría tener basura.
- `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
  `call`) para comenzar la ejecución de la subrutina en cuestión.
- Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
- `false` es el valor `0` y `true` es todo valor distinto de `0`.
- Importa que los ítems estén ordenados según el comparador. No hay necesidad
  de verificar que el orden sea estable.

## 1B - Materializar índices

Cuando una vista es muy importante para un jugador se puede escoger reordenar el
inventario en base a esta. Nuestros índices son básicamente una forma de
representar permutaciones del inventario. Se solicita implementar una función
que dado un inventario y una vista cree un nuevo inventario que mantenga el
orden descrito por la misma.

Es decir:
```math
\forall i \in [0; \text{tamanio})\quad  \text{resultado}[i] = \text{inventario}[\text{vista}[i]]
```

La memoria a solicitar para el nuevo inventario debe poder ser liberada
utilizando `free(ptr)`.

La función debe tener la siguiente firma:
```c
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);
``` 

Donde:
- `inventario` un array de punteros a ítems que representa el inventario a
  procesar.
- `indice` es el arreglo de índices en el inventario que representa la vista
  que vamos a usar para reorganizar el inventario.
- `tamanio` es el tamaño del inventario.

Tenga en consideración:
- Tanto los elementos de `inventario` como los del resultado son punteros a
  `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
  ítems**

# Ejercicio 2 - SIMD

Este ejercicio consiste en implementar filtros gráficos similares al taller
utilizando el modelo de procesamiento SIMD.

## Formatos de píxel

A lo largo de este ejercicio vamos a usar varios formatos distintos de píxel.
En esta sección se documentan las estructuras que vamos a tratar.

### Color (`rgba_t`)

Nuestras imágenes a color tienen 8 bits por canal (0 a 255) con 4 canales: Rojo
(R), Verde (G), Azul (B), Alfa (A). Cuando un canal vale 0 la intensidad del
mismo es la mínima mientras que 255 es la intensidad máxima.

```c
typedef struct rgba_pixfmt {
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} rgba_t;
```

**Campos:**
- `r`: La cantidad de rojo en el píxel. Va de 0 a 255.
- `g`: La cantidad de verde en el píxel. Va de 0 a 255.
- `b`: La cantidad de azul en el píxel. Va de 0 a 255.
- `a`: La transparencia del píxel. Va de 0 a 255.

### Máscaras o control en 8bits (`uint8_t`)

Las máscaras que determinan en qué pixel aplicar el efecto (o con qué intensidad
aplicarlo) tendrán un único canal de 8 bits. En lugar de tener una
representación específica para ese tipo de dato usaremos `uint8_t`.

## Filtro de contraste

En este ejercicio trabajaremos con un filtro de contraste.  Dicho filtro se
aplica a cada canal de color de un píxel de la siguiente manera:

```math
\begin{aligned}
    \text{Rojo}_{\text{Salida}}  &=
        \text{Saturar}(\frac{\text{Contraste} \times (\text{Rojo}  - 128)}{32} + 128) \\
    \text{Verde}_{\text{Salida}} &=
        \text{Saturar}(\frac{\text{Contraste} \times (\text{Verde} - 128)}{32} + 128) \\
    \text{Azul}_{\text{Salida}}  &=
        \text{Saturar}(\frac{\text{Contraste} \times (\text{Azul}  - 128)}{32} + 128) \\
    \text{Alfa}_{\text{Salida}}  &= 255
\end{aligned}
```

Dónde la función $`\text{Saturar}(x)`$ es:
```math
\text{Saturar}(x) =
    \begin{cases}
        255 & \text{Si } 255 < x \\
        x   & \text{Si } x \in [0; 255] \\
        0   & \text{Si } x < 0
    \end{cases}
```

Tenga en consideración:
- $`32 = 2^5`$ y $`\frac{1}{32} = 2^{-5}`$
- Puede asumir que $`\text{Contraste} \times (\text{Canal} - 128)`$ es siempre
  representable como un `int16_t`

## 2A - Aplicar contraste en toda la imagen
En este primer punto implementaremos el filtro de contraste descripto
anteriormente a una imagen.
  
La firma de la función a implementar es la siguiente:
```c
void ej2a(
    rgba_t* dst,
    rgba_t* src,
    uint32_t width, uint32_t height,
    uint8_t amount
);
```

**Parámetros:**
- `dst`: La imagen destino. Está a color (RGBA) en 8 bits sin signo por canal.
- `src`: La imagen origen. Está a color (RGBA) en 8 bits sin signo por canal.
- `width`: El ancho en píxeles de `src` y `dst`.
- `height`: El alto en píxeles de `src` y `dst`.
- `amount`: El nivel de intensidad de contraste a aplicar (en la fórmula
  corresponde al parámetro _Contraste_).

## 2B - Aplicar contraste según una máscara

Ahora queremos extender la funcionalidad del filtro anterior para que se aplique
sólo sobre determinados pixeles de la imagen. Para esto, esta nueva
implementación recibe adicionalmente una máscara de la misma cantidad de
elementos que pixeles contenidos en la imagen original. Cada elemento de la
máscara indica si se debe aplicar el filtro de contraste en el pixel
correspondiente. 

Si el valor es 255 se debe aplicar el filtro, en caso contrario debe ser ignorado. Es correcto
asumir que todos los valores de `mask` son o bien 0 ó 255.

La firma de la función a implementar es la siguiente:
```c
void ej2b(
    rgba_t* dst,
    rgba_t* src,
    uint32_t width, uint32_t height,
    uint8_t amount,
    uint8_t* mask
);
```

**Parámetros:**
- `dst`: La imagen destino. Está a color (RGBA) en 8 bits sin signo por canal.
- `src`: La imagen origen. Está a color (RGBA) en 8 bits sin signo por canal.
- `width`: El ancho en píxeles de `src` y `dst`.
- `height`: El alto en píxeles de `src` y `dst`.
- `amount`: El nivel de intensidad de contraste a aplicar (en la fórmula
  corresponde al parámetro _Contraste_).
- `mask`: La máscara de control de 8 bits sin signo (8 bits, todos los valores
  son 0 ó 255).

## 2C - Aplicar contraste según una imagen de control

En este punto **no es necesario realizar una implementación**. Pueden agregar la respuesta debajo, en este mismo archivo, o generar otro archivo Markdown con la respuesta.

Se pide explicar la idea de cómo modificar la implementación del ejercicio 2B
para que la máscara regule la intensidad del filtro en lugar de
habilitarlo/deshabilitarlo de manera binaria. La intensidad del filtro entonces
dependerá ahora de un parámetro de control que contiene tantos *amount* como
píxeles la imagen fuente.

La firma de la función sería la siguiente:
```c
void ej2c(
    rgba_t* dst,
    rgba_t* src,
    uint32_t width, uint32_t height,
    uint8_t* control
);
```

**Parámetros:**
- `dst`: La imagen destino. Está a color (RGBA) en 8 bits sin signo por canal.
- `src`: La imagen origen. Está a color (RGBA) en 8 bits sin signo por canal.
- `width`:  El ancho en píxeles de `src` y `dst`.
- `height`: El alto en píxeles de `src` y `dst`.
- `control`: Una imagen que que regula el nivel de intensidad del filtro en
  cada píxel (es en escala de grises a 8 bits por canal).
