FROM ubuntu:trusty
MAINTAINER Yuji ODA

# Installing Dependencies
RUN apt-get update; \
    apt-get -y install screen python-cherrypy3 rdiff-backup git openjdk-7-jre-headless uuid wget pwgen

# Installing MineOS scripts
RUN mkdir -p /usr/games /var/games/minecraft; \
    git clone git://github.com/hexparrot/mineos /usr/games/minecraft; \
    cd /usr/games/minecraft; \
    chmod +x server.py mineos_console.py generate-sslcert.sh

# Customize server settings
ADD mineos.conf /usr/games/minecraft/mineos.conf
RUN mkdir /usr/games/minecraft/ssl_certs; \
    mkdir /var/games/minecraft/log; \
    mkdir /var/games/minecraft/run

# Add start script
ADD start.sh /usr/games/minecraft/start.sh
RUN chmod +x /usr/games/minecraft/start.sh

# Add minecraft user and change owner files.
RUN useradd -s /bin/bash -d /usr/games/minecraft -m minecraft; \
    chown -R minecraft:minecraft /usr/games/minecraft /var/games/minecraft

VOLUME /var/games/minecraft
WORKDIR /usr/games/minecraft
EXPOSE 8443 25565

ENTRYPOINT ["./start.sh"]
