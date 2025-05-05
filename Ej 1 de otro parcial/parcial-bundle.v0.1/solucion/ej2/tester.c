#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej2.h"


#define H 20
#define W 6

static yuyv_t a[H][W];
static yuyv_t b[H][W];
static yuyv_t c[H][W];



void shuffle(uint32_t max){
    for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++){
            int8_t n= (int8_t) rand() % max;
            if (n == 127 || i == 0 || j == 3) {
                c[i][j].y1 = n-2;
                c[i][j].u = 127;
                c[i][j].y2 = n-3;
                c[i][j].v = 127;
                if (n == 127) {
                    n = n-4;
                }
            } else {
                c[i][j].y1 = n;
                c[i][j].u = n-1;
                c[i][j].y2 = n-2;
                c[i][j].v = n-3;
            }
            a[i][j].y1 = n;
            a[i][j].u = n+1;
            a[i][j].y2 = n+2;
            a[i][j].v = n+3;
            
            b[i][j].y1 = (int8_t) rand() % max;
            b[i][j].u = (int8_t) rand() % max;
            b[i][j].y2 = (int8_t) rand() % max;
            a[i][j].v =  (int8_t) rand() % max;
        }
    }
}

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);

char *filename_ej2 =  "salida.propios.ej2.txt";
void test_ej2(char* filename);


int main(void) {
    srand(0);
    remove(filename_ej2);
    test_ej2(filename_ej2);
    return 0;
}


void test_ej2(char* filename) {

    uint8_t *res = malloc(H*W*2*4);
    
    void (*func_convert)( int8_t *, uint8_t *, uint32_t , 
                               uint32_t );
    if (USE_ASM_IMPL){
        func_convert = YUYV_to_RGBA;
    }else{
        func_convert = YUYV_to_RGBA_c;
    }

    FILE* pfile;
    shuffle(INT8_MAX);
    RUN(filename, fprintf(pfile, "== Ejercicio 2 ==\n");) NL(filename)
    RUN(filename, fprintf(pfile, "== Sin Errores ==\n");) NL(filename)


    func_convert((int8_t*)a,(uint8_t*)res,W,H);

    for(int i=0;i<W*2;++i){
        for(int j=0;j<H;++j){
            RUN(filename, fprintf(pfile, "%3d ",res[i*W*2 +j]);)
        }
        NL(filename)
    }


    RUN(filename, fprintf(pfile, "\n== Random ==\n");) NL(filename)

    func_convert((int8_t*)b,(uint8_t*)res,W,H);

    for(int i=0;i<W*2;++i){
        for(int j=0;j<H;++j){
            RUN(filename, fprintf(pfile, "%3d ",res[i*W*2 +j]);)
        }
        NL(filename)
    }

    RUN(filename, fprintf(pfile, "\n== Con Errores==\n");) NL(filename)

    func_convert((int8_t*)c,(uint8_t*)res,W,H);

    for(int i=0;i<W*2;++i){
        for(int j=0;j<H;++j){
            RUN(filename, fprintf(pfile, "%3d ",res[i*W*2 +j]);)
        }
        NL(filename)
    }



    free(res);
}

