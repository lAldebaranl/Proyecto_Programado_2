;------------------------------------- 
; Proyecto de Programacion II         |    
; Arquitectura de Computadoras        |
; Interprete de Comandos (Prompt)     |
; Alejandro Rojas Jara                |
; Fecha de entrega: 18/11/2013        |  
;-------------------------------------   

section .bss

section .data
global file_Name
file_Name: db ''


section .text
extern printf
extern mostrar

global main
main:

push ebp			
mov ebp, esp	

mov ebx, [esp + 12]	;puntero a arg[]
mov ebx, dword [ebx+4]
mov [file_Name], ebx
call mostrar

exit:
mov esp, ebp
pop ebp
ret



