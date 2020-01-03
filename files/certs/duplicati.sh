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

# move to duplicati folder
cp $PFX $OUT
chmod +r $OUT
echo "The PFX cert is available at $OUT"

# restart duplicati
if [ "$(docker ps -q -f name=duplicati | wc -l)" -gt 0 ]; then
  docker restart duplicati
fi
