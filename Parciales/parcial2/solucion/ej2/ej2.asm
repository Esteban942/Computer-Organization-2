global combinarImagenes_asm

section .rodata

todoUnos: times 16 db 0xFF
alpha255: db 0,0,0,0xFF,0,0,0,0xFF,0,0,0,0xFF,0,0,0,0xFF

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;rdi puntero imagen A
;rsi puntero imagen B
;rdx puntero destino
;rcx width
;r8 height
combinarImagenes_asm:
    push rbp
    mov rbp, rsp

    movdqu xmm10, [todoUnos]
    movdqu xmm11, [alpha255 ]

    imul rcx,r8 ;cantidad de pixeles de las imagenes

.for:
    cmp rcx,0
    je .fin
    movdqu xmm0, [rdi] ;agarro la tanda de 4 pixeles de A
    ;tres copias de A para despejar RGB
    pslld xmm0, 8 ;elimino el alpha
    movdqu xmm2, xmm0
    movdqu xmm3, xmm0
    movdqu xmm4, xmm0

    pslld xmm2, 16      ;xmm2 <- |B000|B000|B000|B000|
    psrld xmm2, 24      ;xmm2 <- |000B|000B|000B|000B|  (B despejada)

    pslld xmm3, 8       ;xmm3 <- |GB00|GB00|GB00|GB00|
    psrld xmm3, 24      ;xmm3 <- |000G|000G|000G|000G|  (G despejada)

    psrld xmm4, 24      ;xmm4 <- |000R|000R|000R|000R|  (R despejada)

    
    
    movdqu xmm1, [rsi] ;agarro la tanda de 4 pixeles de B
    pslld xmm1, 8 ;elimino el alpha
    ;tres copias de B para despejar RGB
    movdqu xmm5, xmm1
    movdqu xmm6, xmm1
    movdqu xmm7, xmm1
    
    pslld xmm5, 16      ;xmm5 <- |B000|B000|B000|B000|
    psrld xmm5, 24      ;xmm5 <- |000B|000B|000B|000B|  (B despejada)

    pslld xmm6, 8       ;xmm6 <- |GB00|GB00|GB00|GB00|
    psrld xmm6, 24      ;xmm6 <- |000G|000G|000G|000G|  (G despejada)


    psrld xmm7, 24      ;xmm7 <- |000R|000R|000R|000R|  (R despejada)

    ;en xmm2 el B de A
    ;en xmm3 el G de A
    ;en xmm4 el R de A
    ;en xmm5 el B de B
    ;en xmm6 el G de B
    ;en xmm7 el R de B


    paddd xmm2, xmm7 ;en xmm2 tengo el B del destino
    psubd xmm5, xmm4 ;en xmm5 tengo el R del destino

    movdqu xmm7, xmm3 ; copia de G de A
    movdqu xmm8, xmm3 ; copia de G de A

    psubd xmm3 , xmm6 ;si Ag es mayor a Bg uso esto
    pavgb xmm7, xmm6 ;en xmm7 tengo si no es mayor

    pcmpgtd xmm8, xmm6 ;en xmm8 tengo la mascara de G del destino

    pslld xmm5, 16 ;shifteo R 16 bits para estar en su lugar

    pslld xmm3, 8 ;shifteo G 8 bits para que este en su lugar 
    pslld xmm7, 8 ;shifteo G 8 bits para que este en su lugar

    pand xmm3, xmm8 ;tengo G en los lugares donde es mas grande
    pxor xmm8, xmm10 ;transformo la mascara para ahora poner G en los lugares donde es menor con la xor y todos unos lo invierto
    pand xmm7,xmm8 ;tengo G en los lugares donde es mas chico

    ;junto todo
    por xmm2,xmm5
    por xmm2,xmm3
    por xmm2,xmm7 
    por xmm2, xmm11 ;en xmm2 tengo lo de destino


    add rdi, 16 ;avanzo a los siguientes 4 pixeles de A
    add rsi, 16 ;avanzo a los siguientes 4 pixeles de B
    movdqu [rdx], xmm2 ;lo pongo en destino
    add rdx, 16 ;avanzo a los siguientes 4 pixeles
    sub rcx, 4
    jmp .for

.fin:

    pop rbp
    ret