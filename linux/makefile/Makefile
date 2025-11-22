CFLAGS = -Wno-implicit-function-declaration # You can append multiple flags separated by space

all: final

final: main.o hello.o
	@echo "Linking and producing the final application"
	gcc $(CFLAGS) main.o hello.o -o final
	chmod +x final

main.o: main.c
	@echo "Compiling main.c..."
	gcc $(CFLAGS) -c main.c

hello.o: hello.c
# Starting line by '@' suppress the command print on stdin
	@echo "Compiling hello.c..."
	gcc $(CFLAGS) -c hello.c

clean:
	@echo "Removing everything but the source file"
	rm main.o hello.o final