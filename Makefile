all: build bin bin/hello

build:
	mkdir build

bin:
	mkdir bin

build/hello.o: src/hello.s
	nasm -f elf -g -F stabs -o $@ $<

bin/hello: build/hello.o
	ld -o $@ $<

clean:
	rm -rf build bin
