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

    cte_float_uno: times 2 dd 1.370705
    cte_float_dos: times 2 dd 0.698001
    cte_float_tres: times 2 dd 0.337633
    cte_float_cuatro: times 2 dd 1.732446

    mask_reordenar_G: db 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0xFF, 0xFF, 0x08, 0xFF, 0xFF, 0xFF, 0x0C, 0xFF, 0xFF 
    ;[00 00 00 G3 00 00 00 G2 00 00 00 G1 00 00 00 G0]

    mask_reordenar_B: db 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0xFF, 0xFF, 0x08, 0xFF, 0xFF, 0xFF, 0x0C, 0xFF
    ;[00 00 00 B3 00 00 00 B2 00 00 00 B1 00 00 00 B0]

    llenar_128: times 4 db 0x80, 0x00, 0x00, 0x00

    suma_transparencia: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

    mask_shuf_cvt_byte_to_dw_V: db 0x04, 0x05, 0x06, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;xmm2 = [0, 0, 0, 0, 0, 0, 0, 0, V1, V1, V0, V0, 0, 0, 0, 0]

    mask_shuf_cvt_byte_to_dw_U: db 0x08, 0x09, 0x0A, 0xB, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;xmm3 = [0, 0, 0, 0, U1, U1, U0, U0, 0, 0, 0, 0, 0, 0, 0, 0]

    mask_limpiar_R: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
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

    ;#Iteraciones = #px / #px_por_it = width * height / 2
    
    xor rax, rax
    mov eax, edx    ;rax = width
    
    xor r8, r8
    mov r8d, ecx    ;r8 = height
    
    mul r8          ;rax = width * height
    
    shr rax, 1      ;rax = width * height / 2
    
    ;Ponemos el contador de iteraciones en r9
    xor r9, r9
    mov r9, rax

    ciclo:
        cmp r9, 0
        je fin_ciclo

        ;Cargamos 2 pixeles YUYV extendidos a 0 en xmm10
        ;xmm10 = [0, 0, 0, 0, V1, Y11, U1, Y10, 0, 0, 0, 0, V0, Y01, U0, Y00]
        pmovzxdq xmm10, [rdi]
        
        ;Agrupamos las cosas asi podemos pasar los componentes a registros separados
        ;xmm10 = [0, 0, 0, 0, U1, U1, U0, U0, V1, V1, V0, V0, Y11, Y10, Y01, Y00]
        movdqu xmm11, [mask_reordenar_YUYV]
        pshufb xmm10, xmm11
        
        ;Limpiamos los registros en los que vamos a poner las componentes Y U V separadas
        pxor xmm1, xmm1
        pxor xmm2, xmm2
        pxor xmm3, xmm3
        
        ;Hacemos blend para mover las componentes que queremos a los registros
        
        ;xmm1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Y11, Y10, Y01, Y00]
        movdqu xmm0, [mask_blend_Y]
        pblendvb xmm1, xmm10

        ;xmm2 = [0, 0, 0, 0, 0, 0, 0, 0, V1, V1, V0, V0, 0, 0, 0, 0]
        movdqu xmm0, [mask_blend_V]
        pblendvb xmm2, xmm10
        
        ;xmm3 = [0, 0, 0, 0, U1, U1, U0, U0, 0, 0, 0, 0, 0, 0, 0, 0]
        movdqu xmm0, [mask_blend_U]
        pblendvb xmm3, xmm10

        ;Para convertirlos en single precision primero tenemos que convertirlos en double word CON signo
        ;Para esto movemos todas las componentes a los primeros 4 bytes
        movdqu xmm0, [mask_shuf_cvt_byte_to_dw_V] ;xmm2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, V1, V1, V0, V0]
        pshufb xmm2, xmm0

        movdqu xmm0, [mask_shuf_cvt_byte_to_dw_U] ;xmm3 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, U1, U1, U0, U0]
        pshufb xmm3, xmm0
        
        ;Ahora extendemos 4 enteros con signo de un byte a 4 enteros con signo en doubleword
        ;xmm1 = [Y11 | Y10 | Y01 | Y00]
        ;xmm2 = [V1  | V1  | V0  | V0 ]	
        ;xmm3 = [U1  | U1  | U0  | U0 ]        
        pmovsxbd xmm1, xmm1
        pmovsxbd xmm2, xmm2
        pmovsxbd xmm3, xmm3
        
        ;Restamos 128 a V y U
        movdqu xmm0, [llenar_128]
        psubd xmm2, xmm0
        psubd xmm3, xmm0

        ;Convertimos en single precision floats
        ;xmm1 = [Y11      | Y10      | Y01      | Y00     ]
        ;xmm2 = [V1 - 128 | V1 - 128 | V0 - 128 | V0 - 128]	
        ;xmm3 = [U1 - 128 | U1 - 128 | U0 - 128 | U0 - 128]
        cvtdq2ps xmm1, xmm1
        cvtdq2ps xmm2, xmm2
        cvtdq2ps xmm3, xmm3
        
        ;Cargamos las constantes en los siguientes registros:
        ;xmm4 = [1.370705 | 1.370705 | 1.370705 | 1.370705]
        movlps xmm4, [cte_float_uno]
        movhps xmm4, [cte_float_uno]
        
        ;xmm5 = [0.698001 | 0.698001 | 0.698001 | 0.698001]
        movlps xmm5, [cte_float_dos]
        movhps xmm5, [cte_float_dos]        
        
        
        ;xmm6 = [0.337633 | 0.337633 | 0.337633 | 0.337633]
        movlps xmm6, [cte_float_tres]
        movhps xmm6, [cte_float_tres]        
        
        ;xmm7 = [1.732446 | 1.732446 | 1.732446 | 1.732446]
        movlps xmm7, [cte_float_cuatro]
        movhps xmm7, [cte_float_cuatro]
        
        ;CALCULAMOS R G B:
        ;xmm4 = xmm4 * xmm2		(1.37 * V)
        ;xmm4 = xmm4 + xmm1		(1.37 * V + Y) = R
        mulps xmm4, xmm2
        addps xmm4, xmm1


        ;xmm6 = xmm6 * xmm3		(0.337 * U)
        ;xmm5 = xmm5 * xmm2		(0.698 * V)
        ;xmm8 = xmm1
        ;xmm8 = xmm8 - xmm5		(Y - 0.698 * V)
        ;xmm8 = xmm8 - xmm6		(Y - 0.698 * V - 0.337 * U) = G
        mulps xmm6, xmm3
        mulps xmm5, xmm2
        movaps xmm8, xmm1
        subps xmm8, xmm5
        subps xmm8, xmm6
        
        ;xmm7 = xmm7 * xmm3		(1.37 * U )
        ;xmm7 = xmm7 + xmm1		(1.37 *U  + Y) = B
        mulps xmm7, xmm3
        addps xmm7, xmm1
        
        ;Ahora tenemos 4 pixeles RGBA
        ;R = xmm4 = [R3, R2, R1, R0]
        ;G = xmm8 = [G3, G2, G1, G0]
        ;B = xmm7 = [B3, B2, B1, B0]
        
        ;Pasamos estos 3 registros a uint_8 con truncacion
        cvttps2dq xmm4, xmm4
        cvttps2dq xmm8, xmm8
        cvttps2dq xmm7, xmm7

        ;Como sabemos que los valores no pueden ser mayores a 255 solo nos importa el byte mas bajo de cada doubleword  
        
        ;Hacemos un shuffle para dejar los bytes donde tienen que estar
        ;(R en el primero, G en el segundo, B en el tercero) (R no se ordena, solo se limpian los bytes de mas)

        ;Limpiamos R
        movdqu xmm0, [mask_limpiar_R]
        pand xmm4, xmm0
        
        movdqu xmm0, [mask_reordenar_G]
        pshufb xmm8, xmm0

        movdqu xmm0, [mask_reordenar_B]
        pshufb xmm7, xmm0
        
        ;Sumamos por byte para combinar los registros porque tienen 0 en todos los lados donde van las otras cosas
        paddb xmm4, xmm8
        paddb xmm4, xmm7

        ;Ponemos FF en la transparencia mediante una suma 
        ;movdqu xmm0, [suma_transparencia]
        ;paddusb xmm4, xmm0
        
        ;Ponemos FF en la transparencia con inserts
        pinsrb xmm4, [transparencia], 0x03
        pinsrb xmm4, [transparencia], 0x07
        pinsrb xmm4, [transparencia], 0x0B
        pinsrb xmm4, [transparencia], 0x0F


        ;Movemos el registro resultante a memoria
        movdqu [rsi], xmm4

        ;Ponemos todo en orden para el proximo ciclo
        dec r9
        ;Sumamos 2 pixeles en X (8 bytes)
        add rdi, 8
        ;Sumamos 4 pixeles en Y (16 bytes)
        add rsi, 16

        jmp ciclo
    fin_ciclo:
    
    ;epilogo
    pop rbp
