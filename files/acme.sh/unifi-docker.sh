#!/usr/bin/env bash

FULLCHAIN=$1
KEYFILE=$2
WORKDIR=$3

# Backup previous keystore
docker exec unifi bash -c 'cp /usr/lib/unifi/data/keystore /usr/lib/unifi/data/keystore.backup'

# Convert cert to PKCS12 format
# Ignore warnings
openssl pkcs12 -export -inkey "$KEYFILE" -in "$FULLCHAIN" -out "$WORKDIR"/fullchain.p12 -name unifi -password pass:unifi

# Install certificate
# Ignore warnings
docker exec unifi bash -c 'keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /usr/lib/unifi/data/keystore -srckeystore /usr/lib/unifi/data/fullchain.p12 -srcstoretype PKCS12 -srcstorepass unifi -alias unifi -noprompt'

#Restart UniFi controller
docker restart unifi
