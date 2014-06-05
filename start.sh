#!/bin/sh

SCRIPTPATH=/usr/games/minecraft
SERVER=server.py
CONSOLE=mineos_console.py
CONFIGFILE=/usr/games/minecraft/mineos.conf
DATAPATH=/var/games/minecraft
USER=minecraft
GROUP=minecraft

# Create dooes not exists directories
chown $USER:$GROUP $DATAPATH
if [ ! -d $DATAPATH/ssl_certs ]; then
    sudo -u $USER mkdir $DATAPATH/ssl_certs
fi
if [ ! -d $DATAPATH/log ]; then
    sudo -u $USER mkdir $DATAPATH/log
fi
if [ ! -d $DATAPATH/run ]; then
    sudo -u $USER mkdir $DATAPATH/run
fi

# Changing password
if [ ! -f $DATAPATH/.initialized ]; then
    if [ "$PASSWORD" = "" ]; then
        PASSWORD=`pwgen 10 1`
        echo "Login password is \"$PASSWORD\""
    fi
    echo "$USER:$PASSWORD" | chpasswd
    sudo -u $USER touch $DATAPATH/.initialized
fi

# Generate ssl certrificates
CERT_DIR=$DATAPATH/ssl_certs
if [ ! -f "$CERT_DIR/mineos.pem" ]; then
    sudo -u $USER CERTFILE=$CERT_DIR/mineos.pem CRTFILE=$CERT_DIR/mineos.crt KEYFILE=$CERT_DIR/mineos.key ./generate-sslcert.sh
fi

# Starting minecraft servers
sudo -u $USER python $SCRIPTPATH/$CONSOLE -d $DATAPATH restore
sudo -u $USER python $SCRIPTPATH/$CONSOLE -d $DATAPATH start

# Trap function
_trap() {
    kill $PID

    # Wait for shutdown
    ALIVE=1
    while [ $ALIVE != 0 ]; do
        ALIVE=`pgrep $PID | wc -l`
        sleep 1
    done

    sudo -u $USER python $SCRIPTPATH/$CONSOLE -d $DATAPATH stop
}
trap '_trap' 15

# Starting Web UI
sudo -u $USER python $SCRIPTPATH/$SERVER -c $CONFIGFILE & PID=$!

wait $PID