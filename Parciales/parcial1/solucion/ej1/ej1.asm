section .text
;struct pago
%define offset_monto 0
%define offset_aprobado 1
%define offset_pagador 8
%define offset_cobrador 16
%define offset_structP 24

;struct pagoSplitted
%define offset_cantaprobados 0
%define offset_cantrechazados 1
%define offset_aprobados 8
%define offset_rechazados 16
%define offset_structPS 24

;struct list
%define offset_pago 0
%define offset_next 8
%define offset_prev 16
%define list_size 24

global contar_pagos_aprobados_asm

global contar_pagos_rechazados_asm

global split_pagos_usuario_asm

extern malloc
extern free
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)
;rdi lista
;rsi usuario
; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
contar_pagos_aprobados_asm:
push rbp
sub rbp, rsp
push r12
push r13
push r14
push r15

mov r13, rsi
mov r14,[rdi]
mov rdi,[r14]
mov r15, rdi

.ciclo:
    mov rsi, r13
    mov rdi, [r15]
    mov r12, [r15]
    mov rdi, [rdi + offset_cobrador]
    call strcmp
    cmp rax, 0
    jne .siguiente
    mov r12b, byte[r12 + offset_aprobado]
    cmp r12, 1
    jne .siguiente
    inc r14

    .siguiente:
        add r15,8
        mov rdi, [r15]
        mov r15, rdi
        cmp r15,0
        je .fin
        jmp .ciclo

.fin:
 mov rax, r14

pop r15
pop r14
pop r13
pop r12
pop rbp
; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
push rbp
sub rbp, rsp
push r12
push r13
push r14
push r15

mov r13, rsi
mov r14,[rdi]
mov rdi,[r14]
mov r15, rdi

.ciclo2:
    mov rsi, r13
    mov rdi, [r15]
    mov r12, [r15]
    mov rdi, [rdi + offset_cobrador]
    call strcmp
    cmp rax, 0
    jne .siguiente2
    mov r12b, byte[r12 + offset_aprobado]
    cmp r12, 1
    je .siguiente2
    inc r14

    .siguiente2:
        add r15,8
        mov rdi, [r15]
        mov r15, rdi
        cmp r15,0
        je .fin2
        jmp .ciclo2

.fin2:
 mov rax, r14

pop r15
pop r14
pop r13
pop r12
pop rbp
; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:

