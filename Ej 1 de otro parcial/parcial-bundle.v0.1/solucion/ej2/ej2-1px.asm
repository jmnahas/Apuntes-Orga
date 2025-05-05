section .rodata
    mask_reordenar_YUYV: db 0x00, 0x02, 0x08, 0x0A, 0x03, 0x03, 0x0B, 0x0B, 0x01, 0x01, 0x09, 0x09, 0xFF, 0xFF, 0xFF, 0xFF
    ;ANTES   = [0, 0, 0, 0, V1, Y11, U1, Y10, 0, 0, 0, 0, V0, Y01, U0, Y00]
    ;DESPUES = [0, 0, 0, 0, U1, U1, U0, U0, V1, V1, V0, V0, Y11, Y10, Y01, Y00]

    mask_blend_Y: db 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ;dst = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] 
    ;src = [0, 0, 0, 0, U1, U1, U0, U0, V1, V1, V0, V0, Y11, Y10, Y01, Y00]
    ;result = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Y11, Y10, Y01, Y00]

    mask_blend_V: db 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

    mask_blend_U: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00

    cte_float_uno: dq 1.370705
    cte_float_dos: dq 0.698001
    cte_float_tres: dq 0.337633
    cte_float_cuatro: dq 1.732446

    mask_reordenar_G: db 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF 
    ;[00 00 00 00 00 00 00 00 00 00 00 G1 00 00 00 G0]

    mask_reordenar_B: db 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;[00 00 00 00 00 00 00 00 00 00 00 B1 00 00 00 B0]

    llenar_128: db 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00

    suma_transparencia: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

    mask_shuf_cvt_byte_to_dw_V: db 0x04, 0x05, 0x06, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;xmm2 = [0, 0, 0, 0, 0, 0, 0, 0, V1, V1, V0, V0, 0, 0, 0, 0]

    mask_shuf_cvt_byte_to_dw_U: db 0x08, 0x09, 0x0A, 0xB, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;xmm3 = [0, 0, 0, 0, U1, U1, U0, U0, 0, 0, 0, 0, 0, 0, 0, 0]

    mask_limpiar_R: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ;xmm4 = [X, X, X, R, X, X, X, R, X, X, X, R, X, X, X, R]

    transparencia: db 0xFF 

global YUYV_to_RGBA

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void YUYV_to_RGBA( int8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
;RDI = X src , RSI = Y dst, RDX = width, RCX = height
;NO LLEGUE A HACER LA PARTE DE CORREGIR LOS PIXELES INVALIDOS
YUYV_to_RGBA:
    ;prologo
    push rbp
    mov rbp, rsp

    ;Vamos a procesar de a un px YUYV a la vez
    ;#Iteraciones = #px / #px_por_it = width * height
    
    xor rax, rax
    mov eax, edx    ;rax = width
    
    xor r8, r8
    mov r8d, ecx    ;r8 = height
    
    mul r8          ;rax = width * height
    
    ;Ponemos el contador de iteraciones en r9
    xor r9, r9
    mov r9, rax

    ciclo:
        cmp r9, 0
        je fin_ciclo

        ;Cargamos 1 pixel YUYV extendidos a 0 en xmm10
        ;xmm10 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, V0, Y01, U0, Y00]
        pxor xmm10, xmm10
        movd xmm10, [rdi]
        
        ;Extendemos los valores con signo a doubleword
        ;xmm10 = [V | Y1 | U | Y0]
        pmovsxbd xmm10, xmm10

        ;Cargamos un registro con [128, 0, 128, 0]
        movdqu xmm11, [llenar_128]

        ;Restamos con signo
        ;xmm10 = [V - 128 | Y1 | U - 128 | Y0]
        psubd xmm10, xmm11
        
        ;Limpiamos los registros en los que vamos a poner las componentes Y U V separadas
        pxor xmm9, xmm9 ;Aca ira [0 | 0 | Y1 | Y0]
        pxor xmm8, xmm8 ;Aca ira [0 | 0 | U  | U ]
        pxor xmm7, xmm7 ;Aca ira [0 | 0 | V  | V ]
        
        ;Hacemos blend para mover las componentes que queremos a los registros
        ;Luego hacemos shuffle para que queden bien ordenadas
        
        ;xmm9 = [0 | Y1 | 0 | Y0]
        pblendw xmm9, xmm10, 00110011b
        ;xmm9 = [0 | 0 | Y1 | Y0]
        pshufd xmm9, xmm9, 01011000b

        ;xmm8 = [0 | 0 | U | 0]
        pblendw xmm8, xmm10, 00001100b
        ;xmm8 = [0 | 0 | U  | U ]
        pshufd xmm8, xmm8, 00000101b

        ;xmm7 = [V | 0 | 0 | 0]
        pblendw xmm7, xmm10, 11000000b
        ;xmm7 = [0 | 0 | V  | V ]
        pshufd xmm7, xmm7, 00001111b

        ;Convertimos en double precision floats
        ;xmm9 = [Y1 | Y0]
        ;xmm8 = [U  | U ]
        ;xmm7 = [V  | V ] 
        cvtdq2pd xmm9, xmm9
        cvtdq2pd xmm8, xmm8
        cvtdq2pd xmm7, xmm7
        
        ;Cargamos las constantes en los siguientes registros:
        ;xmm6 = [1.370705 | 1.370705]
        movlpd xmm6, [cte_float_uno]
        movhpd xmm6, [cte_float_uno]
        
        ;xmm5 = [0.698001 | 0.698001]
        movlpd xmm5, [cte_float_dos]
        movhpd xmm5, [cte_float_dos]        
        
        
        ;xmm4 = [0.337633 | 0.337633]
        movlpd xmm4, [cte_float_tres]
        movhpd xmm4, [cte_float_tres]        
        
        ;xmm3 = [1.732446 | 1.732446]
        movlpd xmm4, [cte_float_cuatro]
        movhpd xmm4, [cte_float_cuatro]
        
        ;CALCULAMOS R G B:
        ;xmm6 = xmm6 * xmm7		(1.37 * V)
        ;xmm6 = xmm6 + xmm9		(1.37 * V + Y) = R
        mulpd xmm6, xmm7
        addpd xmm6, xmm9

        ;xmm3 = xmm3 * xmm8     (1.732 * U)
        ;xmm3 = xmm3 + xmm9     (Y + 1.732 * U) = B
        mulpd xmm3, xmm8
        addpd xmm3, xmm9

        ;xmm5 = xmm5 * xmm7     (0.698 * V)
        ;xmm4 = xmm4 * xmm8     (0.337 * U)
        ;xmm9 = xmm9 - xmm5     (Y - 0.698 * V)
        ;xmm9 = xmm9 - xmm4     (Y - 0.698 * V - 0.337 * U) = G
        pmuld xmm5, xmm7
        pmuld xmm4, xmm8
        subpd xmm9, xmm5
        subpd xmm9, xmm4

        
        ;Ahora tenemos 4 pixeles RGBA
        ;R = xmm6 = [R1, R0]
        ;G = xmm9 = [G1, G0]
        ;B = xmm3 = [B1, B0]
        
        ;Pasamos estos 3 registros a uint_8 con truncacion
        ;La instruccion deja los 64 bits mas altos en 0
        ;xmm6 = [0 | 0 | R1 | R0]
        ;xmm9 = [0 | 0 | G1 | G0]
        ;xmm3 = [0 | 0 | B1 | B0]
        cvttpd2dq xmm6, xmm6
        cvttpd2dq xmm9, xmm9
        cvttpd2dq xmm3, xmm3

        ;Como sabemos que los valores no pueden ser mayores a 255 solo nos importa el byte mas bajo de cada doubleword  
        
        ;Hacemos un shuffle para dejar los bytes donde tienen que estar
        ;(R en el primero, G en el segundo, B en el tercero) (R no se ordena, solo se limpian los bytes de mas)

        ;Limpiamos R (R ya esta en la posicion en la que tiene que estar)
        movdqu xmm0, [mask_limpiar_R]
        pand xmm6, xmm0
        
        movdqu xmm0, [mask_reordenar_G]
        pshufb xmm9, xmm0

        movdqu xmm0, [mask_reordenar_B]
        pshufb xmm3, xmm0
        
        ;Sumamos por byte para combinar los registros porque tienen 0 en todos los lados donde van las otras cosas
        paddusb xmm6, xmm9
        paddusb xmm6, xmm3
        
        ;Ponemos FF en la transparencia con inserts
        pinsrb xmm6, [transparencia], 0x03
        pinsrb xmm6, [transparencia], 0x07

        ;Movemos la primera quad word (8 bytes = 2px RGBA) a memoria
        movq [rsi], xmm6

        ;Ponemos todo en orden para el proximo ciclo
        dec r9
        ;Sumamos 1 pixeles en X (4 bytes)
        add rdi, 4
        ;Sumamos 2 pixeles en Y (8 bytes)
        add rsi, 8

        jmp ciclo
    fin_ciclo:
    
    ;epilogo
    pop rbp
