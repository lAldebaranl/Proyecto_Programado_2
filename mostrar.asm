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
buflen: dw 4096 ; len del buffer

section .text
extern printf
extern file_Name

global mostrar
mostrar:

push ebp                        
mov ebp, esp        

;------------------------------------------------------------------
; open(char *path, int flags, mode_t mode);                        |
; Utiliza el argumento guardado en file_Name para abrir un archivo.|
;------------------------------------------------------------------
open:
mov ebx, file_Name
mov eax, 0x05 ; llamada de sistema para funcion open
xor ecx, ecx ; ecx = 0 > archivo de solo lectura
xor edx, edx 
int 0x80 

test eax, eax ; Verifica eax
jns file_read ; Si se activa la bandera de signo(positivo), se puede leer el archivo
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

;-------------------------------------------------------------
; write(int fd, void *buf, size_t count);
;-------------------------------------------------------------
file_out:
mov edx, eax ; guardamos en edx la cantidad de bytes leidos por read.
mov eax, 0x04 ; llamada de sistema para write
mov ebx, 0x01 ; Usamos la salida standard 1.
mov ecx, buffer ; movemos el buffer al los argumentos
int 0x80

exit:
mov esp, ebp
pop ebp
ret
