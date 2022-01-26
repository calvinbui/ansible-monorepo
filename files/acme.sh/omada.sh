#!/usr/bin/env bash

set -euo pipefail

CERT=$1
KEY=$2

mkdir -p /apps/omada/cert/

cp "$CERT" /apps/omada/cert/tls.crt
cp "$KEY" /apps/omada/cert/tls.key

# Restart Omada controller
docker restart omada
