If you have trouble seeing green arrow in KDbg then try

nasm -f elf -g -F dwarf eatsyscall.asm -o eatdemo.o

instead of 


nasm -f elf -g -F dwarf eatsyscall.asm -o eatdemo.o

If you have trouble linking add -m elf_i386 to ld options

If you have trouble with no output in KDbg view try installing xterm
