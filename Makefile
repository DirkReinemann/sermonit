CC=gcc
CFLAGS=-g3 -std=c11 -Wall -Wextra -Werror -D_GNU_SOURCE
SOURCES=serwatch.c mongoose.c
BIN=serwatch

all: compile mods

compile:
	$(CC) $(CFLAGS) $(SOURCES) -o $(BIN)

clean:
	rm -f *.o $(BIN) *~ *.out

run: compile
	./serwatch

mods:
	$(MAKE) -C modules
