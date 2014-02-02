all: src/hello.o
	ld -o bin/hello src/hello.o
	strip -s bin/hello
	
src/hello.o: src/hello.asm
	nasm -f elf64 src/hello.asm -o src/hello.o

clean:
	rm bin/hello src/hello.o
			