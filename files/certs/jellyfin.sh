#!/usr/bin/env bash

CERTIFICATE_DIR=$1
DOMAIN="$(basename $CERTIFICATE_DIR)"

OUT=$2
PFX=$CERTIFICATE_DIR/${DOMAIN}.pfx
KEY=${CERTIFICATE_DIR}/${DOMAIN}.key
CERT=${CERTIFICATE_DIR}/${DOMAIN}.cer
CA=${CERTIFICATE_DIR}/ca.cer

# convert to PKCS12
openssl pkcs12 \
-export -out "$PFX" \
-inkey "$KEY" \
-in "$CERT" \
-certfile "$CA" \
-password "pass:pass"

# move to jellyfin folder
cp $PFX $OUT
chmod +r $OUT
echo "The PFX cert is available at $OUT"

# restart jellyfin
if [ "$(docker ps -q -f name=jellyfin | wc -l)" -gt 0 ]; then
  docker restart jellyfin
fi
