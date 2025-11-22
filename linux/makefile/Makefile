CC=gcc
BIN=final
CODEDIRS=. lib
INCDIR=. ./include/

# Consider the changes in .h files too.
DEPFLAGS=-MP -MD
CFLAGS=-Wall -Wextra -O0 $(DEPFLAGS) -g $(foreach D,$(INCDIR),-I$(D)) # -I. -I./include/

# Iteration and regex completion (wildcard)
CFILES=$(foreach D,$(CODEDIRS),$(wildcard $(D)/*.c)) # ./main.c ./lib/hello.c
OBJS=$(patsubst %.c,%.o,$(CFILES)) # hello.c -> hello.o
DEPS=$(patsubst %.c,%.d,$(CFILES)) # hello.c -> hello.d

all: $(BIN)

$(BIN): $(OBJS)
	@echo "Linking and producing the final application..."
	$(CC) -o $@ $^

%.o: %.c
# $< Only want the .c file dependency here
	$(CC) $(CFLAGS) -c -o $@ $<

distribute: clean
	tar zcvf dist.tgz *

diff:
# $(info ...) prints output
	$(info The status of the repository...)
	@git status
	@git diff --stat

clean:
	@echo "Removing everything but the source file"
	rm -rf $(BIN) $(OBJS) $(DEPS)

-include $(DEPS)