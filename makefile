Main_Prompt: Main_Prompt.o mostrar.o
	gcc -m32 -o Main_Prompt Main_Prompt.o mostrar.o

Main_Prompt.o: Main_Prompt.asm
	nasm -f elf -o Main_Prompt.o Main_Prompt.asm

mostrar.o: mostrar.asm
	nasm -f elf -o mostrar.o mostrar.asm

