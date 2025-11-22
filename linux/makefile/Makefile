CC=gcc
CFLAGS=-Wno-implicit-function-declaration -Wall -Wextra -O0
BIN=final
OBJECTS=main.o hello.o

all: $(BIN)

$(BIN): $(OBJECTS)
	@echo "Linking and producing the final application"
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^ 
	@# $@ points to the left hand of colon (:), $^ to dependency (i.e. %.c)..

clean:
	@echo "Removing everything but the source file"
	rm $(BIN) $(OBJECTS)
