#!/bin/bash

/usr/sbin/apachectl start
/usr/sbin/sshd
nohup /usr/bin/dummyrequest &
/usr/bin/sermonit

exit 0
