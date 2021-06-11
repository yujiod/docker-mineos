# FROM ubuntu:impish
FROM ubuntu:focal
MAINTAINER Yuji ODA

ENV MINEOS_VERSION 1.3.0
ENV DEBIAN_FRONTEND=noninteractive

# Installing Dependencies
RUN apt-get update; \
    apt-get -y install git rdiff-backup screen build-essential gcc g++ make openjdk-16-jre-headless uuid pwgen curl rsync

# Installing MineOS scripts
RUN mkdir -p /usr/games/minecraft /var/games/minecraft; \
    curl -L https://github.com/hexparrot/mineos-node/archive/refs/tags/${MINEOS_VERSION}.tar.gz | tar xz -C /usr/games/minecraft --strip=1; \
    cd /usr/games/minecraft; \
    chmod +x service.js mineos_console.js generate-sslcert.sh webui.js; \
    ln -s /usr/games/minecraft/mineos_console.js /usr/local/bin/mineos

WORKDIR /usr/games/minecraft

# install node and node modules
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash; \
    export NVM_DIR="$HOME/.nvm"; \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; \
    nvm install 8.17.0; \
    npm install

# Customize server settings
ADD mineos.conf /etc/mineos.conf

# Add start script
ADD start.sh /usr/games/minecraft/start.sh
RUN chmod +x /usr/games/minecraft/start.sh

# Add minecraft user and change owner files.
RUN useradd -M -s /bin/bash -d /usr/games/minecraft minecraft

# Cleaning
RUN apt-get -y remove build-essential; \
    apt -y autoremove; \
    apt-get clean

VOLUME /var/games/minecraft
EXPOSE 8443 25565 25566 25567 25568 25569 25570

CMD ["./start.sh"]
