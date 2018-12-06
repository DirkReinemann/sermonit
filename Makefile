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

service: install
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

docker-build:
	-sudo docker build -t sermonit:jessie .

docker-run:
	-sudo docker run --name sermonitvm -d sermonit:jessie
	-$(shell echo "sudo docker inspect sermonitvm | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress'")

docker-stop:
	-sudo docker container stop sermonitvm
	-sudo docker container rm sermonitvm

docker-ssh:
	-$(shell sudo docker inspect sermonitvm | jq -r '.[].NetworkSettings.Networks.bridge.IPAddress' | xargs -I'{}' printf "sshpass -p root ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@%s\n" "{}")

debian-build: compile mods
	-mkdir -p debian/usr/share/sermonit
	-mkdir -p debian/DEBIAN
	-cp control debian/DEBIAN
	-cp index.html debian/usr/share/sermonit
	-cp sermonit.bin /debianusr/bin/sermonit
	-cp sermonit debian/usr/share/sermonit
	-cp sermonit.sh debian/usr/share/sermonit
	-cp -r static debian/usr/share/sermonit
	-cp -r config debian/usr/share/sermonit
	-mkdir -p debian/usr/share/sermonit/modules
	-cp -r modules/applicationversion debian/usr/share/sermonit/modules
	-cp modules/*.sh debian/usr/share/sermonit/modules
	-cp modules/*.o debian/usr/share/sermonit/modules
	-dpkg-deb --build debian sermonit.deb

debian-clean:
	-rm -r debian
	-rm sermonit.deb

hash-create: debian-clean
	-find . -type f | grep -v 'sum$$' | grep -v 'git' | xargs -I'{}' shasum '{}' | tee sermonit.shasum
	-find . -type f | grep -v 'sum$$' | grep -v 'git' | xargs -I'{}' md5sum '{}' | tee sermonit.md5sum

hash-check:
	-shasum -c sermonit.shasum
	-md5sum -c sermonit.md5sum
