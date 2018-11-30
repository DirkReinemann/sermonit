FROM debian:jessie
MAINTAINER "Dirk Reinemann" <dirk.reinemann@gmx.de>
RUN apt-get update && apt-get install -y openssh-server vim make gcc net-tools jq apache2 golang default-jre scala rustc python ruby
RUN mkdir -p /root/sermonit
COPY config/ /root/sermonit/config/
COPY modules/ /root/sermonit/modules/
COPY static/ /root/sermonit/static/
COPY index.html /root/sermonit/
COPY Makefile /root/sermonit/
COPY mongoose.c /root/sermonit/
COPY mongoose.h /root/sermonit/
COPY sermonit /root/sermonit/
COPY sermonit.bin /root/sermonit/
COPY sermonit.c /root/sermonit/
COPY sermonit.service /root/sermonit/
COPY sermonit.sh /root/sermonit/
COPY docker-cmd.sh /root/
RUN /bin/bash -c 'cd /root/sermonit && make install'
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'root\nroot' | passwd
RUN mkdir -p /var/run/sshd
EXPOSE 22
EXPOSE 8000
CMD /root/docker-cmd.sh
