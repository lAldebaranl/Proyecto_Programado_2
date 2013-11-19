;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss
buffer1: resb 4096 ; Se utiliza un buffer de 4KB para la lectura del archivo 1
buffer2: resb 4096 ;2
Linea_Buff1: resb 4096
Linea_Buff2: resb 4096


section .data
buflen1: dw 4096 ; len del buffer1
buflen2: dw 4096 ; len del buffer2
Char_actual1: dd 0 ;Posicion actual en buffer1
Char_actual2: dd 0 ;Posicion actual en buffer2
Char_linea1: dd 0 ;Posicion a escribir en Linea_Buff1
Char_linea2 dd 0 ;Posicion a escribir en Linea_Buff2
Linea_actual: dd 1 ;Numero de linea que se esta comparando
Linea_EOF: dd 0
Diffound: db 'Se encontraron diferencias en la linea %d.',10,0
File_EOF: db 'Fin de la comparacion.',10,0

section .text
extern printf
extern arg1
extern arg2
extern strcmp

global comparar
comparar:

push ebp                        
mov ebp, esp        

;--------------------------------------------------------------------
; open(char *path, int flags, mode_t mode);                          |
; Utiliza el argumento guardado en arg1 para abrir el primer archivo.|
;--------------------------------------------------------------------
open_file_1:
mov ebx, arg1
mov eax, 0x05 ; llamada de sistema para funcion open
xor ecx, ecx ; ecx = 0 > archivo de solo lectura
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
jns file_read_1 ; Si la bandera de signo es positiva, se puede leer el archivo
jmp exit ;De otra manera sale.

;--------------------------------------------------------
;read(int fd, void *buf, size_t count);                  |
;Leemos el archivo utilizando el file descriptor en eax  |
;--------------------------------------------------------
file_read_1:
mov ebx, eax ; guardamos el FD en ebx
mov eax, 0x03 ; llamada de sistema para read
mov ecx, buffer1 ; Usamos el buffer de 2KB
mov edx, buflen1 ; Y su len
int 0x80

test eax, eax ; Revisa si hay errores / EOF (end of file)
jz open_file_2 ; Cuando llega al EOF, imprime el contenido.
js exit ; Si la lectura falla, sale.

;--------------------------------------------------------------------
; open(char *path, int flags, mode_t mode);                          |
; Utiliza el argumento guardado en arg2 para abrir el 2ndo archivo.  |
;--------------------------------------------------------------------
open_file_2:
mov ebx, arg2
mov eax, 0x05 ; llamada de sistema para funcion open
xor ecx, ecx ; ecx = 0 > archivo de solo lectura
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
jns file_read_2 ; Si la bandera de signo es positiva, se puede leer el archivo
jmp exit ;De otra manera sale.

;--------------------------------------------------------
;read(int fd, void *buf, size_t count);                  |
;Leemos el archivo utilizando el file descriptor en eax  |
;--------------------------------------------------------
file_read_2:
mov ebx, eax ; guardamos el FD en ebx
mov eax, 0x03 ; llamada de sistema para read
mov ecx, buffer2 ; Usamos el buffer de 2KB
mov edx, buflen2 ; Y su len
int 0x80

test eax, eax ; Revisa si hay errores / EOF (end of file)
jz Comparar_Archivos ; Cuando llega al EOF, imprime el contenido.
js exit ; Si la lectura falla, sale.


;--------------------------------------------------------
;Rutina para comparar los textos cargados                |
;Imprime un msj cada vez que encuentra lineas distintas  |
;--------------------------------------------------------
Comparar_Archivos:
mov eax, buffer1
mov ebx, Linea_Buff1;

;----------------------------------------------------
;Loop para ir guardando cada linea del primer archivo|
;----------------------------------------------------
buf1loop:
mov ecx, [Char_actual1]
mov dl, byte[eax+ecx]
mov ecx, [Char_linea1]
mov byte[ebx+ecx], dl
cmp byte[ebx+ecx], 10
je get_buf2
cmp byte[ebx+ecx], 0
jne next_char
mov eax, 1
mov [Linea_EOF], eax
jmp get_buf2
next_char:
add ecx, 1
mov [Char_linea1], ecx
mov ecx, [Char_actual1]
add ecx, 1
mov [Char_actual1], ecx
jmp buf1loop

get_buf2:
mov ebx, Linea_Buff1
mov byte[ebx+ecx], 0

mov eax, buffer2
mov ebx, Linea_Buff2

;-----------------------------------------------------
;Loop para ir guardando cada linea del segundo archivo|
;-----------------------------------------------------
buf2loop: 
mov ecx, [Char_actual2]
mov dl, byte[eax+ecx]
mov ecx, [Char_linea2]
mov byte[ebx+ecx], dl
cmp byte[ebx+ecx], 10
je bfcmp
cmp byte[ebx+ecx], 0
jne next_char2
mov eax, 1
mov [Linea_EOF], eax
jmp bfcmp
next_char2:
add ecx, 1
mov [Char_linea2], ecx
mov ecx, [Char_actual2]
add ecx, 1
mov [Char_actual2], ecx
jmp buf2loop

bfcmp:
mov ebx, Linea_Buff2
mov byte[ebx+ecx], 0

;----------------------------------------------------
;Usa las dos lineas actuales y las compara con strcmp|
;----------------------------------------------------
push Linea_Buff1
push Linea_Buff2
call strcmp
add esp, 8
cmp eax, 0
je continua
mov eax, [Linea_actual]
push eax
push Diffound
call printf
add esp, 4

;---------------------------------------------------------------------------
;Actualiza variables y vemos si ya terminamos de leer alguno de los archivos|
;---------------------------------------------------------------------------
continua:
mov eax, [Linea_actual]
add eax, 1
mov [Linea_actual], eax
mov eax, [Linea_EOF]
cmp eax, 1
je Found_EOF
xor eax, eax
mov [Char_linea1], eax
mov [Char_linea2], eax
mov eax, [Char_actual1]
inc eax
mov [Char_actual1], eax
mov eax, [Char_actual2]
inc eax
mov [Char_actual2], eax
jmp Comparar_Archivos

Found_EOF:
;Resetea variables para proximas llamadas.
xor eax, eax
mov [Char_linea1], eax
mov [Char_linea2], eax
mov [Char_actual1], eax
mov [Char_actual2], eax
mov [Linea_EOF], eax
inc eax
mov [Linea_actual], eax

push File_EOF
call printf
add esp, 4
mov ecx, 1

exit:
mov esp, ebp
pop ebp
ret
