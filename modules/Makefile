CC=gcc
CFLAGS=-g3 -std=c11 -Wall -Wextra -Werror -D_GNU_SOURCE
OBJECTS=cpuusage.o cputemp.o memoryusage.o
LIBS=-lm

all: $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) $< $(LIBS) -o $@

clean:
	-rm -f *.o
