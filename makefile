Main_Prompt: Main_Prompt.o mostrar.o copiar.o comparar.o
	gcc -m32 -o Main_Prompt Main_Prompt.o mostrar.o copiar.o comparar.o

Main_Prompt.o: Main_Prompt.asm
	nasm -f elf -o Main_Prompt.o Main_Prompt.asm

mostrar.o: mostrar.asm
	nasm -f elf -o mostrar.o mostrar.asm

copiar.o: copiar.asm
	nasm -f elf -o copiar.o copiar.asm

comparar.o: comparar.asm
	nasm -f elf -o comparar.o comparar.asm
