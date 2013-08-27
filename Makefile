all: build bin bin/hello bin/template

build:
	mkdir build

bin:
	mkdir bin

ASM := nasm -f elf -g -F stabs
LD := ld

build/hello.o: src/hello.s
	$(ASM) -o $@ $<

bin/hello: build/hello.o
	$(LD) -o $@ $<

build/template.o: src/template.s
	$(ASM) -o $@ $<

bin/template: build/template.o
	$(LD) -o $@ $<

build/upcase.o: src/upcase.s
	$(ASM) -o $@ $<

bin/upcase: build/upcase.o
	$(LD) -o $@ $<

debug:
	make bin/template && gdb -x .gdbinit bin/template

clean:
	rm -rf build bin
