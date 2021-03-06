;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss
buffer: resb 4096 ; Se utiliza un buffer de 2KB para la lectura

section .data
buflen: dw 40496 ; len del buffer

section .text
extern printf
extern file_Name
extern arg2
extern arg1

global copiar
copiar:

push ebp			
mov ebp, esp	

;------------------------------------------------------------------
; open(char *path, int flags, mode_t mode);                        |
; Utiliza el argumento guardado en file_Name para abrir un archivo.|
;------------------------------------------------------------------
open_oldfile:
mov ebx, arg1
mov eax, 0x05 ; llamada de sistema para funcion open
xor ecx, ecx ; ecx = 0 > archivo de solo lectura
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
jns file_read ; Si la bandera de signo es positiva, se puede leer el archivo
jmp exit ;De otra manera sale.

;--------------------------------------------------------
;read(int fd, void *buf, size_t count);                  |
;Leemos el archivo utilizando el file descriptor en eax  |
;--------------------------------------------------------
file_read:
mov ebx, eax ; guardamos el FD en ebx
mov eax, 0x03 ; llamada de sistema para read
mov ecx, buffer ; Usamos el buffer de 2KB
mov edx, buflen ; Y su len
int 0x80

test eax, eax ; Revisa si hay errores / EOF (end of file)
jz file_out ; Cuando llega al EOF, imprime el contenido.
js exit ; Si la lectura falla, sale.
push eax ;Cantidad de bytes leidos

;--------------------------------------------------------------------------------
;Se crea un archivo nuevo si no existe, de otro modo se sobreescribe el existente|
;--------------------------------------------------------------------------------
open_newfile:
mov ebx, arg2
mov eax, 0x08 
mov ecx, 0x07  
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
js exit 

;-------------------------------------------------------------
; write(int fd, void *buf, size_t count);
;-------------------------------------------------------------
file_out:
mov ebx, eax ; Usamos el fd del archivo nuevo
pop edx ; guardamos en edx la cantidad de bytes leidos por read.
mov eax, 0x04 ; llamada de sistema para write
mov ecx, buffer ; movemos el buffer al los argumentos
int 0x80

exit:
mov esp, ebp
pop ebp
ret
