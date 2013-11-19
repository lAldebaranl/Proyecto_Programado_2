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
ComandoLen: dw 40
YES: times 4 db 0
;Prompt
promptMsg: db 'Aguacate@ITCR:>',0
;Funciones disponibles:
salida_In: db 'salir',0
F_Mostrar: db 'mostrar',0
F_Copiar: db 'copiar',0
F_Borrar: db 'borrar',0
F_Comparar: db 'comparar',0
F_Renombrar: db 'renombrar',0
F_Ayuda: db '.ayuda',0
;Advertencias
Borrar_Check: db 'Esta seguro que desea borrar el archivo?[Y/N]>',0
Renombrar_Check: db 'Esta seguro que desea renombrar el archivo?[Y/N]>',0
Accion_OK: db 'Accion realizada correctamente!',10,0
Accion_Fail: db 'No se pudo realizar la accion.',10,'Asegurese de que los archivos existan.',10,10,0
OP_Missing: db 'Faltan argumentos. Puede usar "funcion --ayuda" para mas informacion.',10,10,0
;Argumentos.
funcion: times 20-$+funcion db ' '
         db 0 ;Primer argumento del comando (mostrar, copiar, etc..)
global   arg1
arg1:    times 30-$+arg1 db ' '
         db 0 ;Segundo argumento (--ayuda o nombre-primer-arhivo)
global   arg2
arg2:    times 30-$+arg2 db ' '
         db 0 ;Tercer argumento (nombre-segundo-archivo o --forzado)
global   arg3
arg3:    times 20-$+arg3 db ' '
         db 0 ;Tercer argumento (--forzado para renombrar)
;Otras variables
ayuda_In: db '--ayuda',0
forzado_In: db '--forzado',0
ult_arg: db 0 ;Variable para saber se ya llegamos al ultimo argumento.
pos_arg: db 0 ;Posicion a modificar en los argumentos.
global file_Name
file_Name: db 'README.md' ;Nombre del archivo a abrir, ingresado por el usuario o uno de ayuda.
catsize: times 20 db 0
pos_com: times 2 db 0 ;Posicion que sirve de guia a medida que se analiza el comando.

section .text
extern printf
extern scanf
extern fflush
extern strcat
extern mostrar
extern copiar
extern comparar
extern rename
extern remove

global main
main:
;Mensaje principal, presenta la informacion del programa.

call mostrar
mov eax, [file_Name]
xor eax, eax
mov [file_Name], eax

;--------------------------------------------------------
;Prompt principal, muestra el msj de peticion de comandos|
;--------------------------------------------------------
mainPrompt:
push ebp			
mov ebp, esp
	
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

jmp Reset_Variables ;Comando invalido, vuelve a pedir otro.

;-----------------------------------------------------------------------
;Funcion mostrar. Usa la variable global file_Name para abrir un archivo|
;-----------------------------------------------------------------------
Func_mostrar:
call Es_Ultimo ;verifica si ya se leyo el ultimo argumento, si asi es, faltan argumentos en el comando.
call Next_arg  ;Preparamos para leer el segundo argumento
mov ebx, arg1  ;El siguiente quedara guardado en arg1
call Fetch_Arg ;Lo leemos

mov eax, [arg1] ;Si el segundo arg es --ayuda, mostramos el archivo
cmp eax, [ayuda_In]
jne abre_archivo
jmp Ayuda_Comando

abre_archivo:
push arg1      ;Movemos el arg1 a file_Name 
push file_Name
call strcat
add esp, 8
call mostrar   ;Y lo tratamos de abrir e imprimir

cmp ecx, 0     ;Si la cantidad de bytes resultante es 0, no se cargo ningun archivo
jne mostrar_Ok 
push Accion_Fail ;Mostramos msj de fallo de lectura
call printf
add esp, 4

mostrar_Ok: ;Finalmente volvemos al prompt.
jmp Reset_Variables 

;----------------
;Funcion copiar. |
;----------------
Func_copiar:
call Es_Ultimo
call Next_arg
mov ebx, arg1
call Fetch_Arg

mov eax, [arg1]
cmp eax, [ayuda_In]
jne copy_arg2
jmp Ayuda_Comando

copy_arg2:
call Es_Ultimo
call Next_arg
mov ebx, arg2
call Fetch_Arg

copiar_:
call copiar

cmp ecx, 0 ;Cantidad de bytes leidos del archivo-original, si es 0, no existe.
jne Copiado_Ok  
push Accion_Fail 
call printf
add esp, 4
jmp Reset_Variables

Copiado_Ok:
push Accion_OK
call printf
add esp, 4
jmp Reset_Variables


;-----------------
;Funcion borrar.  |
;-----------------
Func_borrar:
call Es_Ultimo
call Next_arg
mov ebx, arg1
call Fetch_Arg

mov eax, [arg1]
cmp eax, [ayuda_In]
je Ayuda_Comando

mov eax, [ult_arg]
cmp eax, 1
je rem_check
call Next_arg
mov ebx, arg2
call Fetch_Arg

mov eax, [arg2]
cmp eax, [forzado_In]
je remove_

rem_check:
push Borrar_Check
call printf
add esp, 4

push 0
call fflush   ;Hacemos un flush antes de la lectura para que se imprima correctamente.
add esp, 4

mov eax, 3
mov ebx, 0
mov ecx, YES ;Lectura del comando.
mov edx, 2
int 0x80

mov ecx, YES
cmp byte[ecx], 'Y'
je remove_
cmp byte[ecx], 'y'
jne Reset_Variables

remove_:
push arg1
call remove
add esp, 4

cmp eax, 0
je Borrado_Ok
push Accion_Fail
call printf
add esp, 4
jmp Reset_Variables

Borrado_Ok:
push Accion_OK
call printf
add esp, 4

jmp Reset_Variables

;--------------------
;Funcion renombrar.  |
;--------------------
Func_Renombrar:
call Es_Ultimo
call Next_arg
mov ebx, arg1
call Fetch_Arg

mov eax, [arg1]
cmp eax, [ayuda_In]
jne renom_arg2
jmp Ayuda_Comando

renom_arg2:
call Es_Ultimo
call Next_arg
mov ebx, arg2
call Fetch_Arg

mov eax, [ult_arg]
cmp eax, 1
je renom_check
call Next_arg
mov ebx, arg3
call Fetch_Arg

mov eax, [arg3]
cmp eax, [forzado_In]
je rename_

renom_check:
push Renombrar_Check
call printf
add esp, 4

push 0
call fflush   ;Hacemos un flush antes de la lectura para que se imprima correctamente.
add esp, 4

mov eax, 3
mov ebx, 0
mov ecx, YES ;Lectura del comando.
mov edx, 2
int 0x80

mov ecx, YES
cmp byte[ecx], 'Y'
je rename_
cmp byte[ecx], 'y'
jne Reset_Variables

rename_:
push arg2
push arg1
call rename
add esp, 8

cmp eax, 0
je Renombrado_Ok
push Accion_Fail
call printf
add esp, 4
jmp Reset_Variables

Renombrado_Ok:
push Accion_OK
call printf
add esp, 4
jmp Reset_Variables

;------------------
;Funcion compara.  |
;------------------
Func_Comparar:
call Es_Ultimo
call Next_arg
mov ebx, arg1
call Fetch_Arg

mov eax, [arg1]
cmp eax, [ayuda_In]
jne comp_arg2
jmp Ayuda_Comando

comp_arg2:
call Es_Ultimo
call Next_arg
mov ebx, arg2
call Fetch_Arg

comparar_:
call comparar

cmp ecx, 0 ;Cantidad de bytes leidos de los archivos, si es 0, alguno de ellos no existe.
jne Reset_Variables 
push Accion_Fail 
call printf
add esp, 4
jmp Reset_Variables


;---------------------------------------------------------------------------------------
;Concatena el nombre de la funcion con '.ayuda' en file_Name para mostrar la ayuda.     |
;Si por ejemplo la funcion es mostrar:                                                  |
;file_Name= file_Name+funcion= 'mostrar', file_Name= file_Name+F_Ayuda= 'mostrar.ayuda'.|
;---------------------------------------------------------------------------------------
Ayuda_Comando:
push funcion
push file_Name
call strcat
mov [esp+4], dword F_Ayuda
call strcat
add esp, 8
call mostrar

Reset_Variables:
mov eax, 0 
mov [pos_com], eax ;Reseteamos pos_com para la lectura del comando.
mov eax, 0
mov [ult_arg], eax
mov eax, [file_Name]
xor eax, eax
mov [file_Name], eax
mov eax, [Comando]
xor eax, eax
mov [Comando],eax

mov esp, ebp
pop ebp
jmp mainPrompt ;Vuelve al inicio del programa.

;----------------------------------------------------------------
;Funciones para ir analizando cada argumento del comando, guarda |
;la palabra nueva palabra en la direccion que este en ebx.       |
;----------------------------------------------------------------
global Next_arg
Next_arg:
mov eax, 0
mov [pos_arg], eax
mov eax, [pos_com]
add eax, 1
mov [pos_com], eax
mov ecx, Comando
ret

global Fetch_Arg
Fetch_Arg:
mov eax, [pos_com]
;Verifica si se esta leyendo un espacio, si es asi, ya tenemos el argumento completo.
mov dl, byte[ecx+eax]
cmp dl, ' '
jne final_com
mov eax, [pos_arg] ;Agregamos un 0 al final argumento (pos_arg)
mov byte[ebx+eax], 0 ;elimina el espacio de la palabra.
ret
;Verifica si se esta leyendo un 0, si es asi, se guarda el argumento y
;se activa la bandera ult_arg para saber que ese fue el ultimo argumento.
final_com:
cmp dl, 10
jne continua
mov eax, [pos_arg] ;Agregamos un 0 al final argumento (pos_arg)
mov byte[ebx+eax], 0 ;elimina el newline.
mov eax, 1
mov [ult_arg], eax
ret
;Continua leyendo, se guarda el caracter acual en la variable correspondiente.
continua:
mov eax, [pos_arg]
mov byte[ebx+eax], dl
add eax, 1
mov [pos_arg], eax
mov eax, [pos_com]
add eax, 1
mov [pos_com],eax
jmp Fetch_Arg

;Funcion para mostrar un msj en caso de que falten argumentos
global Es_Ultimo
Es_Ultimo:
mov eax, [ult_arg]
cmp eax, 1
je opmiss
ret
opmiss:
push OP_Missing
call printf
add esp, 4
jmp Reset_Variables

exit:
mov esp, ebp
pop ebp
ret
