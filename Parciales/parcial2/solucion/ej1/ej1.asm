section .rodata
; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

;defines para lista
%define lista_size 16
%define offset_first 0
%define offset_last 8

;defines para nodo
%define offset_next 0
%define offset_prev 8
%define offset_type 16
%define offset_hash 24
%define nodo_size 32

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat


string_proc_list_create_asm:
    push rbp 
    mov rbp, rsp
    
    mov rdi, lista_size 
    call malloc  ;pido memoria para la lista
    
    mov qword[rax + offset_first],NULL ;pongo el lugar donde va  el puntero del primer nodo en null
    mov qword[rax + offset_last],NULL ;pongo en el lugar donde va el puntero del ultimo nodo en null 

    pop rbp
    ret

;rdi type
;rsi hash
string_proc_node_create_asm:
    push rbp 
    mov rbp, rsp

    push rdi; pusheo el type
    push rsi; pusheo el hash

    mov rdi, nodo_size
    call malloc ;pido memoria para el nodo

    pop rsi ;recupero el hash
    pop rdi ;recupero el type

    mov qword[rax + offset_next], NULL ;pongo el lugar del puntero next en null
    mov qword[rax + offset_prev], NULL ;pongo el lugar del puntero prev en null
    mov byte [rax + offset_type], dil ;pongo el type en el nodo
    mov qword[rax + offset_hash], rsi ;pongo el puntero a hash


    pop rbp
    ret

;rdi puntero a lista
;rsi type
;rdx puntero a hash
string_proc_list_add_node_asm:
    push rbp 
    mov rbp, rsp
    push r15

    ;resguardo las entradas
    push rdi
    push rsi
    push rdx

    mov rdi,rsi ; pongo en rdi el type
    mov rsi,rdx ;pongo en rsi el puntero a hash
    call string_proc_node_create_asm ;creo el nodo y lo tengo en rax

    ;recupero los datos de entrada
    pop rdx
    pop rsi
    pop rdi

    cmp qword[rdi + offset_last], NULL ;pregunto si el last es NULL
    jne .noEsNULL
    ;si es null pongo en los lugares de puntero a nodo pongo el puntero del nodo creado en first y en last
    mov [rdi + offset_first], rax 
    mov [rdi + offset_last], rax
    jmp .fin ;salto el fin para no hacer lo de abajo

    ;si no es null tengo que modificar los lugares donde van los punteros
    .noEsNULL:
        mov r15, qword[rdi + offset_last] ;agarro el puntero al nodo ex-ultimo
        mov [rdi + offset_last], rax ;pongo el puntero del nodo creado a ultimo de la lista
        mov [r15 + offset_next], rax ;apunto el siguiente del ex ultimo nodo al nuevo nodo
        mov [rax + offset_prev], r15 ;apunto el previo del nuevo ultimo nodo al ex ultimo nodo

    .fin:

    pop r15
    pop rbp
    ret


;rdi tengo puntero a lista
;rsi tengo el tipo 
;rdx tengo el puntero hash
string_proc_list_concat_asm:
    push rbp
    mov rbp,rsp
    push r15
    push r14
    push r13
    push r12

    mov r12,rdi ;copio el puntero a lista en r12
    mov r13,rsi ;copio el tipo en r13
    mov r14,rdx ;copio el puntero hash en r14

    mov r12, [r12 + offset_first] ;me muevo al puntero del primer nodo

.for:
    cmp r12, NULL ;pregunto si el puntero de first apunta a null
    je .salir ;si es null no hay nodos entonces salgo
    ;pregunto si los tipos son iguales
    cmp r13b, byte[r12 + offset_type]
    jne .seguir ;si no lo son salto a la proxima iteracion
    ;si lo son concateno
    mov rdi, r14
    mov rsi, [r12 + offset_hash] 
    call str_concat ;concateno los dos hash
    mov r14, rax ;agarro el que sale 
    

.seguir:
    mov r12, [r12 + offset_next]    ;me muevo al siguiente nodo   
    jmp .for

.salir:
    mov rax, r14 ;pongo en rax lo que quiero que salga

    pop r12
    pop r13
    pop r14
    pop r15
    pop rbp
    ret

