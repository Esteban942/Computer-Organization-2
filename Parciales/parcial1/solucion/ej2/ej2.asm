global mezclarColores



;########### SECCION DE TEXTO (PROGRAMA)
section .text

;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
mezclarColores:
    push rbp
    sub rbp,rsp
    
    mul rcx,rdx
    mov r10, rcx
.for:

    movdqu xmm4, [rdi]  ; xmm4 <- |ARGB|ARGB|ARGB|ARGB| 
    movdqu xmm5, xmm4   ; xmm5 <- |ARGB|ARGB|ARGB|ARGB|
    movdqu xmm6, xmm4   ; xmm6 <- |ARGB|ARGB|ARGB|ARGB|

    ;Despejo R
    pslld xmm4, 8       ; xmm4 <- |RGB0|RGB0|RGB0|RGB0|
    psrld xmm4, 24      ; xmm4 <- |000R|000R|000R|000R|
    cvtdq2ps xmm4, xmm4

    ;Despejo G
    pslld xmm5, 16      ; xmm5 <- |GB00|GB00|GB00|GB00|
    psrld xmm5, 24      ; xmm5 <- |000G|000G|000G|000G|
    cvtdq2ps xmm5, xmm5

    ;Despejo B
    pslld xmm6, 24      ; xmm6 <- |B000|B000|B000|B000|
    psrld xmm6, 24      ; xmm6 <- |000B|000B|000B|000B|
    cvtdq2ps xmm6, xmm6
    ;me rindo :(( para la proxima será
    
pop rbp
