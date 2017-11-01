CC=gcc
CFLAGS=-g3 -std=c11 -Wall -Wextra -Werror -lm -D_GNU_SOURCE
OBJECTS=cpuusage.o cputemp.o memoryusage.o
LIBS=

all: $(OBJECTS)

%.o: %.c
	$(CC) $(CFLAGS) $< $(LIBS) -o $@

clean:
	rm *.o
