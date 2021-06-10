#!/bin/sh

SCRIPTPATH=/usr/games/minecraft
SERVER=server.js
CONSOLE=mineos_console.js
CONFIGFILE=/usr/games/minecraft/mineos.conf
DATAPATH=/var/games/minecraft
USER=minecraft
GROUP=minecraft

# Create does not exists directories
chown $USER:$GROUP $DATAPATH
if [ ! -d $DATAPATH/ssl_certs ]; then
    mkdir $DATAPATH/ssl_certs
fi
if [ ! -d $DATAPATH/log ]; then
    mkdir $DATAPATH/log
fi
if [ ! -d $DATAPATH/run ]; then
    mkdir $DATAPATH/run
fi

# Changing password
if [ ! -f $SCRIPTPATH/.initialized ]; then
    if [ "$PASSWORD" = "" ]; then
        PASSWORD=`pwgen 10 1`
        echo "Login password is \"$PASSWORD\""
    fi
    echo "$USER:$PASSWORD" | chpasswd
    touch $SCRIPTPATH/.initialized
fi

# Generate ssl certrificates
CERT_DIR=$DATAPATH/ssl_certs
if [ ! -f "$CERT_DIR/mineos.pem" ]; then
    CERTFILE=$CERT_DIR/mineos.pem CRTFILE=$CERT_DIR/mineos.crt KEYFILE=$CERT_DIR/mineos.key ./generate-sslcert.sh
fi

# Trap function
_trap() {
    kill $PID

    # Wait for shutdown
    ALIVE=1
    while [ $ALIVE != 0 ]; do
        ALIVE=`pgrep $PID | wc -l`
        sleep 1
    done
}
trap '_trap' 15

# Starting mineos
/root/.nvm/versions/node/v8.17.0/bin/node webui.js & PID=$!

wait $PID