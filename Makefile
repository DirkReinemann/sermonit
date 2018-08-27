CC=gcc
CFLAGS=-g3 -std=c11 -Wall -Wextra -Werror -D_GNU_SOURCE -Wno-format-truncation -Wno-unused-function -DMG_ENABLE_BROADCAST -DMG_ENABLE_THREADS -lpthread
SOURCES=sermonit.c mongoose.c
BIN=sermonit

all: compile mods

compile:
	$(CC) $(CFLAGS) $(SOURCES) -o $(BIN)

clean: mods-clean
	-rm -f *.o $(BIN) *~ *.out *.log *.zip

run: compile mods
	./sermonit

mods:
	$(MAKE) -C modules

mods-clean:
	$(MAKE) clean -C modules

test: compile mods
	./sermonit.sh -t

install: compile mods
	-mkdir -p /usr/share/sermonit
	-cp index.html /usr/share/sermonit
	-cp sermonit.bin /usr/bin/sermonit
	-cp sermonit /usr/share/sermonit
	-cp sermonit.sh /usr/share/sermonit
	-cp -r static /usr/share/sermonit
	-cp -r config /usr/share/sermonit
	-mkdir -p /usr/share/sermonit/modules
	-cp -r modules/applicationversion /usr/share/sermonit/modules
	-cp modules/*.sh /usr/share/sermonit/modules
	-cp modules/*.o /usr/share/sermonit/modules

service:
	-useradd -r -s /usr/bin/nologin -U sermonit
	-chown -R sermonit:sermonit /usr/share/sermonit
	-cp sermonit.service /etc/systemd/system
	-systemctl enable sermonit.service
	-systemctl start sermonit.service

uninstall:
	-rm -rf /usr/share/sermonit
	-rm -f /usr/bin/sermonit

unservice:
	-userdel sermonit
	-groupdel sermonit
	-systemctl stop sermonit.service
	-systemctl disable sermonit.service
	-rm -f /etc/systemd/system/sermonit.service
