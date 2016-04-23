FROM ubuntu:wily
MAINTAINER Yuji ODA

# Installing Dependencies
RUN apt-get update; \
    apt-get -y install supervisor screen python-cherrypy3 rdiff-backup git sudo openjdk-8-jre-headless; \
    apt-get -y install openssh-server uuid pwgen

# Installing MineOS scripts
RUN mkdir -p /usr/games /var/games/minecraft; \
    git clone git://github.com/hexparrot/mineos /usr/games/minecraft; \
    cd /usr/games/minecraft; \
    chmod +x server.py mineos_console.py generate-sslcert.sh; \
    ln -s /usr/games/minecraft/mineos_console.py /usr/local/bin/mineos

# Customize server settings
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD mineos.conf /usr/games/minecraft/mineos.conf
ADD supervisor_conf.d/mineos.conf /etc/supervisor/conf.d/mineos.conf
ADD supervisor_conf.d/sshd.conf /etc/supervisor/conf.d/sshd.conf
RUN mkdir /var/games/minecraft/ssl_certs; \
    mkdir /var/games/minecraft/log; \
    mkdir /var/games/minecraft/run; \
    mkdir /var/run/sshd

# Add start script
ADD start.sh /usr/games/minecraft/start.sh
RUN chmod +x /usr/games/minecraft/start.sh

# Add minecraft user and change owner files.
RUN useradd -s /bin/bash -d /usr/games/minecraft -m minecraft; \
    usermod -G sudo minecraft; \
    sed -i 's/%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers; \
    chown -R minecraft:minecraft /usr/games/minecraft /var/games/minecraft

# Cleaning
RUN apt-get clean

VOLUME /var/games/minecraft
WORKDIR /usr/games/minecraft
EXPOSE 22 8443 25565

ENTRYPOINT ["./start.sh"]
