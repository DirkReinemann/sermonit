# sermonit

## commands

### makefile

| command | description |
| - | - |
| make | compile source files and mods |
| make compile | compile source files |
| make clean | remove compiled files, logs, temp files |
| make run | start sermonit |
| make mods | compile modules |
| make install | install sermonit to /usr/share/sermonit and /usr/bin |
| make uninstall | removes sermonit files from /usr/share/sermonit and /usr/bin |
| make service | creates a systemd service and system user and group |
| make unservice | removes systemd service and system user and group |
| docker-build | build docker image |
| docker-run | start docker container |
| docker-stop | stop running docker container |
| docker-ssh | ssh into running docker container |
| debian-build | create debian package |
| debian-clean | remove debian package files |
| hash-create | create sha and md5 hashsum files |
| hash-check | check sha and md5 hashsum files |

### sermonit.sh

| command | description |
| - | - |
| -s | sort applications in bash modules |
| -t | test all modules |
| -u | list bash modules and their unused applications |
| -i | list applications and their install state |
| -a | generate markdown list with bash applications |
| -m | generate markdown table with bash modules and applications |
| -c | generate markdown list with c modules |
| -z | create sermonit zip archive |

## installation

The bash modules of sermonit use other applications to collect information about the system. To see if the applications
are installed you can execute the following command.

```bash
./sermonit.sh -i
```

Now you can use the makefile to install the sermonit files to **/usr/share/sermonit**.

```bash
make install
```
To see if the modules are working correctly you can test them.

```bash
make test
```

If you want to start sermonit as a systemd service on boot as a sermonit user you can do that also with make.

```bash
make service
```

To use the apache modules you have to check whether the user that is running the application (default sermonit) has access
to the logfiles of apache (default /var/log/apache2) and can read the configuration file (default /etc/apache2/apache2.conf).

If you want to execute a script as the default user you can do this with.

```bash
sudo -u sermonit bash -c '. /usr/share/sermonit/modules/apacheaccess.sh'
```

## deinstallation

The makefile can also be used to uninstall sermonit.

```bash
make uninstall
```

If you installed the systemd service with **make service** you can undo that.

```bash
make unservice
```

## modules

### bash

| bash module                    | dependencies                                                                               |
|--------------------------------|--------------------------------------------------------------------------------------------|
| routeinfo.sh                   | awk, echo, route, sed, tr                                                                  |
| apachevirtualhosts.sh          | apachectl, awk, echo, sed, tr                                                              |
| memorystats.sh                 | awk, echo, free, grep, sed, tr                                                             |
| memoryinfo.sh                  | awk, cat, echo, sed, tr                                                                    |
| arpcache.sh                    | arp, awk, echo, sed, tr                                                                    |
| diskinfo.sh                    | awk, df, echo, grep, sed, tr                                                               |
| groupinfo.sh                   | awk, cat, echo, sed, tr                                                                    |
| interfacesinfo.sh              | awk, echo, grep, ip, sed, tr                                                               |
| scala.sh                       | echo, grep, scala                                                                          |
| go.sh                          | echo, go, grep                                                                             |
| java.sh                        | echo, grep, head, java                                                                     |
| rust.sh                        | echo, grep, rustc                                                                          |
| perl.sh                        | echo, grep, perl                                                                           |
| ruby.sh                        | awk, echo, ruby                                                                            |
| python.sh                      | echo, grep, python                                                                         |
| apacheinfo.sh                  | apachectl, awk, echo, grep, sed, tr                                                        |
| apachemodules.sh               | apachectl, awk, echo, sed, tr                                                              |
| cpuintensive.sh                | awk, echo, head, ps, sed, tr                                                               |
| apacherequests.sh              | apachectl, awk, date, echo, grep, wc                                                       |
| tcpconnections.sh              | awk, echo, netstat, sed, tr                                                                |
| applicationversion.sh          | echo, jq, sed, tr                                                                          |
| userinfo.sh                    | awk, cat, echo, sed, tr                                                                    |
| memoryintensive.sh             | awk, echo, head, ps, sed, tr                                                               |
| cpuinfo.sh                     | awk, echo, lscpu, sed, tr                                                                  |
| apacheaccess.sh                | apachectl, awk, cd, cp, date, echo, grep, gunzip, mkdir, rm, sed, sort, tr, uniq, xargs    |

### c

| c module                       | dependencies                             |
|--------------------------------|------------------------------------------|
| cputemp.c                      | /sys/class/thermal/thermal_zone[0-9]     |
| cpuusage.c                     | /proc/stat                               |
| memoryusage.c                  | /proc/meminfo                            |

## vagrant

You can test sermonit with vagrant before installing it.

```bash
# create zip archive
./sermonit.sh -z

# start vagrant
vagrant up
```

The port 8000 is forwarded to localhost. Open your browser and type http://localhost:8000.

## docker

You can create a docker image and start a docker container to test the application.

```bash
make docker-build
make docker-run
```

The port 8000 is exposed and the ip address of the container shown when executing *****make docker-run**.

## configuration

  * You can change the default ip ********0.0.0.0** and port **8000** in the **sermonit.c** file.
  * You can configure the modules and pages in the **config/config.json**.
