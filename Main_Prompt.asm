;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss
Comando: resb 40 ;Contiene la direccion a el comando completo.
	
section .data
asd: db 'numero = %d',0
ComandoLen: dw 40
promptMsg: db 'Aguacate@ITCR:>',0
salida_In: db 'salir',0
F_Mostrar: db 'mostrar',0
F_Copiar: db 'copiar',0
F_Borrar: db 'borrar',0
F_Renombrar: db 'renombrar',0
F_Comparar: db 'comparar',0
F_Ayuda: db '.ayuda',0
funcion: db '' ;Primer argumento del comando (mostrar, copiar, etc..)
funclen: times 15 db 0
global arg1
arg1: db ''
arg1len: times 20 db 0
global arg2
arg2: db ''
arg2len: times 20 db 0
ayuda_In: db '--ayuda',0
pos_arg: db 0 ;Posicion a modificar en los argumentos.
global file_Name
file_Name: db '' ;Nombre del archivo a abrir, ingresado por el usuario o uno de ayuda.
catsize: times 20 db 0
pos_com: times 2 db 0 ;Posicion que sirve de guia a medida que se analiza el comando.

section .text
extern printf
extern scanf
extern fflush
extern mostrar
extern copiar
extern strcat
extern memset
extern rename
extern remove

global main
main:

push ebp			
mov ebp, esp	

;--------------------------------------------------------
;Prompt principal, muestra el msj de peticion de comandos|
;--------------------------------------------------------
mainPrompt:
push promptMsg
call printf  ;Imprimimos el prompt.
add esp, 4

push 0
call fflush   ;Hacemos un flush antes de la lectura para que se imprima correctamente.
add esp, 4

mov eax, 3
mov ebx, 0
mov ecx, Comando ;Lectura del comando.
mov edx, ComandoLen
int 0x80

push 0
call fflush   ;Hacemos un flush antes de la lectura para que se imprima correctamente.
add esp, 4

;verifica si el comnando es salir.
mov eax, [Comando]
cmp eax, [salida_In]
je exit

;-------------------------------------------------------------
;Interprete, guarda el primer argumento del Comando ingresado.|
;Luego de este proceso se busca la funcion a realizar         |
;-------------------------------------------------------------
Interprete:

mov ecx, Comando
mov ebx, funcion
call Fetch_Arg


jmp Analiza_func


;----------------------------------------------------------------------
;Comparamos el primer argumento 'funcion' con las funciones disponibles|
;Si la entrada es incorrecta, muestra comando.ayuda                    |
;----------------------------------------------------------------------
Analiza_func:

mov ebx, [funcion]
cmp ebx, [F_Mostrar]
je Func_mostrar
cmp ebx, [F_Copiar]
je Func_copiar
cmp ebx, [F_Borrar]
je Func_borrar
cmp ebx, [F_Renombrar]
je Func_Renombrar
cmp ebx, [F_Comparar]
je Func_Comparar

push funcion
call printf  ;Imprimimos el prompt.
add esp, 4

jmp Reset_Variables ;Comando invalido, vuelve a pedir otro.

;-----------------------------------------------------------------------
;Funcion mostrar. Usa la variable global file_Name para abrir un archivo|
;-----------------------------------------------------------------------
Func_mostrar:
mov eax, 0
mov [pos_arg], eax
mov eax, [pos_com]
add eax, 1
mov [pos_com], eax
mov ecx, Comando
mov ebx, arg1
call Fetch_Arg

mov eax, [arg1]
cmp eax, [ayuda_In]
jne abre_archivo
call Ayuda_Comando
jmp Reset_Variables

abre_archivo:
push arg1
push file_Name
call strcat
add esp, 8
call mostrar

jmp Reset_Variables 

Func_copiar:

;call copiar
;call Ayuda_Comando
jmp Reset_Variables

Func_borrar:
;push arg1
;call remove
;add esp, 4
;call Ayuda_Comando
jmp Reset_Variables

Func_Renombrar:
;push arg2
;push arg1
;call rename
;add esp, 8
;call Ayuda_Comando
jmp Reset_Variables

Func_Comparar:
;call Ayuda_Comando
jmp Reset_Variables

;---------------------------------------------------------------------------------------
;Concatena el nombre de la funcion con '.ayuda' en file_Name para mostrar la ayuda.     |
;Si por ejemplo la funcion es mostrar:                                                  |
;file_Name= file_Name+funcion= 'mostrar', file_Name= file_Name+F_Ayuda= 'mostrar.ayuda'.|
;---------------------------------------------------------------------------------------
global Ayuda_Comando
Ayuda_Comando:
push funcion
push file_Name
call strcat
mov [esp+4], dword F_Ayuda
call strcat
add esp, 8
call mostrar
ret
;jmp Reset_Variables

Reset_Variables:

mov eax, 0 
mov [pos_com], eax ;Reseteamos pos_com para la lectura del comando.
mov eax, [file_Name]
xor eax, eax
mov [file_Name], eax
mov eax, [Comando]
xor eax, eax
mov [Comando],eax 

mov esp, ebp
pop ebp
jmp main ;Vuelve al inicio del programa.

;-------------------------------------------------------------
;Funcion para ir analizando cada argumento del comando, guarda |
;la palabra nueva palabra en la direccion que este en ecx.     |
;-------------------------------------------------------------
global Fetch_Arg
Fetch_Arg:
mov eax, [pos_com]
mov dl, byte[ecx+eax]
cmp dl, ' '
jne continua
mov eax, [pos_arg] ;Agregamos un 0 al argumento en la pos actual
mov byte[ebx+eax], 0 ;para asegurar que ahi termine la palabra.
ret
continua:
cmp dl, 0
je Reset_Variables
mov eax, [pos_arg]
mov byte[ebx+eax], dl
add eax, 1
mov [pos_arg], eax
mov eax, [pos_com]
add eax, 1
mov [pos_com],eax
jmp Fetch_Arg


exit:
mov esp, ebp
pop ebp
ret



