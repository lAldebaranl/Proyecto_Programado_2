;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss
global file_Name
file_Name: resw 1

section .data
promptMsg: db 'Aguacate@ITCR:>',0
salida_In: db 'salir',0
Comando:db '',0


section .text
extern printf
extern scanf
extern fflush
extern mostrar

global main
main:

push ebp			
mov ebp, esp	

;--------------------------------------------------------
;Prompt principal, muestra el msj de peticion de comandos|
;--------------------------------------------------------
mainPrompt:
push promptMsg
call printf
add esp, 4

push 0
call fflush
add esp, 4

mov eax, 3
mov ebx, 0
mov ecx, Comando
mov edx, 50
int 0x80


func_mostrar:
mov eax, file_Name
mov byte[eax+13], 0

push file_Name
call printf
add esp, 4

call mostrar


exit:
mov esp, ebp
pop ebp
ret



